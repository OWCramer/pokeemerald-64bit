package com.owcramer.pokeemerald

import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.util.Log
import java.io.File
import java.io.InputStream

/**
 * Keeps the save file in two places at once.
 *
 * The game itself only ever touches the copy in the app's internal storage
 * (`filesDir/pokeemerald.sav`, see ResolveSavePath in sdl3.c). That directory is
 * private to the app and unreachable without root, which is what makes it the
 * copy Android's Auto Backup captures: it is what Google One lists as this app's
 * data, and what a new phone restores.
 *
 * Being unreachable is also its problem. A save nobody can copy out cannot be
 * moved to mGBA, backed up by hand, or replaced with one from elsewhere. So a
 * second copy -- the mirror -- is kept in a folder the user picks once through
 * the storage access framework, somewhere they can actually browse. Only the
 * save is mirrored; controls.cfg stays internal.
 *
 * The two are reconciled at startup ([sync]) and the mirror is refreshed after
 * every in-game save ([push], called from native code via [GameActivity]):
 *
 *  - the mirror holds a save -> it wins, and is copied over the internal one.
 *    This is how a save is replaced: drop a file in the folder.
 *  - the mirror is empty -> it is seeded from the internal save. This is the
 *    first-run case, and the restored-onto-a-new-phone case.
 *
 * Everything here fails soft. If the folder is gone, the permission was revoked,
 * or the provider errors, the internal save is still authoritative and the game
 * plays exactly as it would with no mirror at all.
 */
object SaveMirror {
    private const val TAG = "SaveMirror"

    /** Must match sSavePath's basename in src/platform/sdl3.c. */
    const val SAVE_NAME = "pokeemerald.sav"

    /** FLASH_BACKING_SIZE: the full 128 KB flash image the game reads and writes. */
    private const val SAVE_SIZE = 131072

    private const val PREFS = "save_mirror"
    private const val KEY_TREE = "tree_uri"
    private const val KEY_DOC = "doc_uri"

    const val TREE_FLAGS =
        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION

    /**
     * [sync] runs on the main thread at startup and [push] on the SDL thread
     * after a save; they must not interleave.
     */
    private val lock = Any()

    // ---------------------------------------------------------------- folder

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /**
     * The folder the user picked, or null if there is not a usable one.
     *
     * The stored string is not trusted on its own. SharedPreferences are part of
     * Auto Backup, so a phone restored from another device comes up with the old
     * device's folder recorded and none of its permissions. Checking the live
     * grant list is what turns that -- and a permission revoked in Settings --
     * back into "ask again".
     */
    fun tree(context: Context): Uri? {
        val stored = prefs(context).getString(KEY_TREE, null) ?: return null
        val tree = Uri.parse(stored)

        val granted = context.contentResolver.persistedUriPermissions.any {
            it.isWritePermission && it.uri == tree
        }
        if (!granted) {
            Log.i(TAG, "no live permission for $tree; will ask again")
            return null
        }
        return tree
    }

    fun isConfigured(context: Context) = tree(context) != null

    /**
     * Records the folder the picker returned. Returns false if the grant could
     * not be made persistent, in which case nothing is stored and the user is
     * asked again next launch rather than being handed a mirror that quietly
     * stops working once the process dies.
     */
    fun setTree(context: Context, tree: Uri): Boolean {
        try {
            context.contentResolver.takePersistableUriPermission(tree, TREE_FLAGS)
        } catch (e: Exception) {
            Log.w(TAG, "could not persist permission for $tree", e)
            return false
        }

        // commit(), not apply(): the very next thing that happens is starting
        // the game, and an async write that lost the race would leave the app
        // holding a grant with no record of which folder it is for.
        prefs(context).edit().putString(KEY_TREE, tree.toString()).remove(KEY_DOC).commit()
        return true
    }

    // ----------------------------------------------------------------- files

    fun internalSave(context: Context) = File(context.filesDir, SAVE_NAME)

    /**
     * The save inside the picked folder, or null if there is not one yet.
     *
     * Looked up by name on every call rather than cached, because replacing the
     * save is a supported thing to do and a file dropped in by a file manager is
     * a different document than the one that was there before.
     */
    private fun findMirror(context: Context, tree: Uri): Uri? {
        val resolver = context.contentResolver
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(
            tree, DocumentsContract.getTreeDocumentId(tree)
        )
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
        )

        try {
            resolver.query(children, columns, null, null, null)?.use { cursor ->
                while (cursor.moveToNext()) {
                    if (cursor.getString(1) == SAVE_NAME)
                        return DocumentsContract.buildDocumentUriUsingTree(tree, cursor.getString(0))
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "could not list $tree", e)
        }

        // Nothing by that name. A provider is allowed to rename a document it
        // creates (usually by appending an extension), so fall back to the one
        // this app made, if it is still there.
        val created = prefs(context).getString(KEY_DOC, null) ?: return null
        val doc = Uri.parse(created)
        return if (documentExists(resolver, doc)) doc else null
    }

    private fun documentExists(resolver: ContentResolver, doc: Uri): Boolean = try {
        resolver.query(
            doc, arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null
        )?.use { it.moveToFirst() } ?: false
    } catch (e: Exception) {
        false
    }

    private fun createMirror(context: Context, tree: Uri): Uri? {
        val parent = DocumentsContract.buildDocumentUriUsingTree(
            tree, DocumentsContract.getTreeDocumentId(tree)
        )
        return try {
            // application/octet-stream has no extension mapped to it, so the
            // provider has nothing to append and the name survives as given.
            val doc = DocumentsContract.createDocument(
                context.contentResolver, parent, "application/octet-stream", SAVE_NAME
            )
            if (doc != null)
                prefs(context).edit().putString(KEY_DOC, doc.toString()).commit()
            doc
        } catch (e: Exception) {
            Log.w(TAG, "could not create $SAVE_NAME in $tree", e)
            null
        }
    }

    // ------------------------------------------------------------- transfers

    /**
     * Reads a save-sized image, in the same forgiving way the game does: short
     * files are padded with 0xFF and long ones truncated (see ReadSaveFile in
     * sdl3.c). Returns null only when nothing at all could be read, which is
     * what separates "no save here" from "a save worth having".
     */
    private fun InputStream.readSaveImage(): ByteArray? {
        val image = ByteArray(SAVE_SIZE)
        var got = 0
        while (got < SAVE_SIZE) {
            val n = read(image, got, SAVE_SIZE - got)
            if (n < 0) break
            got += n
        }
        if (got == 0) return null
        if (got < SAVE_SIZE) {
            Log.w(TAG, "save is $got bytes, padding to $SAVE_SIZE")
            image.fill(0xFF.toByte(), got, SAVE_SIZE)
        }
        return image
    }

    /** mirror -> internal. */
    private fun pull(context: Context, doc: Uri, internal: File): Boolean {
        val image = try {
            context.contentResolver.openInputStream(doc)?.use { it.readSaveImage() }
        } catch (e: Exception) {
            Log.w(TAG, "could not read mirror $doc", e)
            return false
        }

        if (image == null) {
            // An empty file is how the folder looks after the save was deleted
            // by a file manager that leaves a stub behind. Treat it as no save
            // rather than wiping the internal one.
            Log.i(TAG, "mirror is empty; leaving the internal save alone")
            return false
        }

        // Written to a temp file and renamed, so a failure part way through
        // cannot leave the game with half a save. rename() within a directory
        // replaces atomically.
        val temp = File(internal.parentFile, "$SAVE_NAME.tmp")
        try {
            temp.outputStream().use {
                it.write(image)
                it.fd.sync()
            }
            check(temp.renameTo(internal)) { "rename to $internal failed" }
        } catch (e: Exception) {
            Log.w(TAG, "could not install the mirror save", e)
            temp.delete()
            return false
        }

        Log.i(TAG, "loaded the save from the mirror folder")
        return true
    }

    /** internal -> mirror, creating the document if the folder has none. */
    private fun pushLocked(context: Context, tree: Uri, internal: File): Boolean {
        if (!internal.isFile || internal.length() == 0L)
            return false   // nothing to mirror yet

        val image = try {
            internal.inputStream().use { it.readSaveImage() }
        } catch (e: Exception) {
            Log.w(TAG, "could not read the internal save", e)
            return false
        } ?: return false

        val doc = findMirror(context, tree) ?: createMirror(context, tree) ?: return false

        return try {
            // "rwt" truncates. Plain "w" is not required to, which on some
            // providers would leave the tail of a longer previous file behind.
            val out = context.contentResolver.openOutputStream(doc, "rwt") ?: return false
            out.use { it.write(image) }
            true
        } catch (e: Exception) {
            Log.w(TAG, "could not write mirror $doc", e)
            false
        }
    }

    // ---------------------------------------------------------------- public

    /**
     * Reconciles the two copies. Must finish before the game reads its save,
     * i.e. before SDL starts the native thread.
     */
    fun sync(context: Context) {
        synchronized(lock) {
            val tree = tree(context) ?: return
            val internal = internalSave(context)

            val doc = findMirror(context, tree)
            if (doc != null && pull(context, doc, internal))
                return

            // No mirror save, or one that could not be read: make the folder
            // match what the game is about to play.
            pushLocked(context, tree, internal)
        }
    }

    /** Called after every in-game save. Safe to call with no folder picked. */
    fun push(context: Context) {
        synchronized(lock) {
            val tree = tree(context) ?: return
            pushLocked(context, tree, internalSave(context))
        }
    }
}
