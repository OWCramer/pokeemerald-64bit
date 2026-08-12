package com.owcramer.pokeemerald;

import android.content.Context;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.graphics.Point;
import android.os.CancellationSignal;
import android.os.Handler;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.os.Process;
import android.provider.DocumentsContract.Document;
import android.provider.DocumentsContract.Root;
import android.provider.DocumentsProvider;

import java.io.File;
import java.io.FileNotFoundException;

/**
 * Publishes the save file so it can be reached from the Files app, without
 * moving it.
 *
 * The save is a 128 KB image of cartridge flash and is worth very little if it
 * cannot be copied to mGBA, to a PC, or off a dying phone -- but Android 11
 * removed Android/data from file managers and from MTP, and Auto Backup only
 * covers app-private directories, so moving it somewhere reachable would give up
 * Google One. Publishing it instead keeps the file exactly where it is and
 * brings the Files app to it.
 *
 * Only the save is exposed. controls.cfg is editable text that a player can
 * break in ways the game will not explain.
 *
 * See docs/ANDROID_SAVE_LOCATION.md.
 */
public class SaveDocumentsProvider extends DocumentsProvider {

    private static final String ROOT_ID = "saves";
    private static final String DOC_ID_ROOT = "root";
    private static final String DOC_ID_SAVE = "save";
    private static final String SAVE_NAME = "pokeemerald.sav";
    private static final String SAVE_MIME = "application/octet-stream";

    private static final String[] DEFAULT_ROOT_PROJECTION = {
        Root.COLUMN_ROOT_ID,
        Root.COLUMN_DOCUMENT_ID,
        Root.COLUMN_TITLE,
        Root.COLUMN_FLAGS,
        Root.COLUMN_ICON,
        Root.COLUMN_MIME_TYPES,
    };

    private static final String[] DEFAULT_DOCUMENT_PROJECTION = {
        Document.COLUMN_DOCUMENT_ID,
        Document.COLUMN_DISPLAY_NAME,
        Document.COLUMN_MIME_TYPE,
        Document.COLUMN_FLAGS,
        Document.COLUMN_SIZE,
        Document.COLUMN_LAST_MODIFIED,
    };

    private File saveFile() {
        Context context = getContext();
        if (context == null) {
            return null;
        }
        File dir = context.getExternalFilesDir(null);
        return dir == null ? null : new File(dir, SAVE_NAME);
    }

    @Override
    public boolean onCreate() {
        return true;
    }

    @Override
    public Cursor queryRoots(String[] projection) {
        MatrixCursor result =
            new MatrixCursor(projection == null ? DEFAULT_ROOT_PROJECTION : projection);
        MatrixCursor.RowBuilder row = result.newRow();

        row.add(Root.COLUMN_ROOT_ID, ROOT_ID);
        row.add(Root.COLUMN_DOCUMENT_ID, DOC_ID_ROOT);
        row.add(Root.COLUMN_TITLE, "Pokémon Emerald");
        // LOCAL_ONLY keeps it out of cloud-only pickers; the rest is what lets
        // the Files app show it under Browse and allow a paste in.
        row.add(Root.COLUMN_FLAGS, Root.FLAG_LOCAL_ONLY | Root.FLAG_SUPPORTS_CREATE);
        row.add(Root.COLUMN_ICON, R.mipmap.ic_launcher);
        row.add(Root.COLUMN_MIME_TYPES, SAVE_MIME);
        return result;
    }

    @Override
    public Cursor queryDocument(String documentId, String[] projection)
            throws FileNotFoundException {
        MatrixCursor result =
            new MatrixCursor(projection == null ? DEFAULT_DOCUMENT_PROJECTION : projection);

        if (DOC_ID_ROOT.equals(documentId)) {
            MatrixCursor.RowBuilder row = result.newRow();
            row.add(Document.COLUMN_DOCUMENT_ID, DOC_ID_ROOT);
            row.add(Document.COLUMN_DISPLAY_NAME, "Pokémon Emerald");
            row.add(Document.COLUMN_MIME_TYPE, Document.MIME_TYPE_DIR);
            row.add(Document.COLUMN_FLAGS, 0);
            return result;
        }

        if (!DOC_ID_SAVE.equals(documentId)) {
            throw new FileNotFoundException(documentId);
        }

        File save = saveFile();
        if (save == null || !save.exists()) {
            throw new FileNotFoundException(documentId);
        }
        addSaveRow(result, save);
        return result;
    }

    @Override
    public Cursor queryChildDocuments(String parentDocumentId, String[] projection,
                                      String sortOrder) throws FileNotFoundException {
        MatrixCursor result =
            new MatrixCursor(projection == null ? DEFAULT_DOCUMENT_PROJECTION : projection);

        if (!DOC_ID_ROOT.equals(parentDocumentId)) {
            throw new FileNotFoundException(parentDocumentId);
        }

        File save = saveFile();
        if (save != null && save.exists()) {
            addSaveRow(result, save);
        }
        return result;
    }

    private void addSaveRow(MatrixCursor result, File save) {
        MatrixCursor.RowBuilder row = result.newRow();
        row.add(Document.COLUMN_DOCUMENT_ID, DOC_ID_SAVE);
        row.add(Document.COLUMN_DISPLAY_NAME, SAVE_NAME);
        row.add(Document.COLUMN_MIME_TYPE, SAVE_MIME);
        // Deleting means deleting the save, and writing means replacing it.
        // Both are honoured literally -- there is one file and no second copy
        // to reconcile against, which is the point of publishing rather than
        // mirroring.
        row.add(Document.COLUMN_FLAGS, Document.FLAG_SUPPORTS_DELETE
                                     | Document.FLAG_SUPPORTS_WRITE);
        row.add(Document.COLUMN_SIZE, save.length());
        row.add(Document.COLUMN_LAST_MODIFIED, save.lastModified());
    }

    @Override
    public ParcelFileDescriptor openDocument(String documentId, String mode,
                                             CancellationSignal signal)
            throws FileNotFoundException {
        if (!DOC_ID_SAVE.equals(documentId)) {
            throw new FileNotFoundException(documentId);
        }

        File save = saveFile();
        if (save == null) {
            throw new FileNotFoundException(documentId);
        }

        int flags = ParcelFileDescriptor.parseMode(mode);
        boolean writing = (flags & ParcelFileDescriptor.MODE_WRITE_ONLY) != 0
                       || (flags & ParcelFileDescriptor.MODE_READ_WRITE) != 0;

        if (!writing) {
            return ParcelFileDescriptor.open(save, flags);
        }

        // The save was replaced from outside. A running game holds the previous
        // one in memory and would write it straight back over this at its next
        // save point, so the process goes away as soon as the writer is done.
        //
        // It has to be killed rather than asked to quit: every orderly exit path
        // -- backgrounding, quitting, soft reset -- ends in StoreSaveFile, which
        // is precisely the write that would undo the paste.
        return ParcelFileDescriptor.open(save, flags, new Handler(Looper.getMainLooper()),
            new ParcelFileDescriptor.OnCloseListener() {
                @Override
                public void onClose(java.io.IOException e) {
                    stopTheGame();
                }
            });
    }

    @Override
    public void deleteDocument(String documentId) throws FileNotFoundException {
        if (!DOC_ID_SAVE.equals(documentId)) {
            throw new FileNotFoundException(documentId);
        }

        File save = saveFile();
        if (save == null || !save.delete()) {
            throw new FileNotFoundException(documentId);
        }
        // Same reasoning as a write: a running game would recreate this from
        // memory at its next save point, which is not what deleting a save
        // means.
        stopTheGame();
    }

    /**
     * Ends the process without running any of the game's shutdown, which would
     * save over the file that was just changed. If the game is not running --
     * the provider is often the only reason this process exists -- this is a
     * no-op in effect, and the next launch reads whatever is now on disk.
     */
    private void stopTheGame() {
        Process.killProcess(Process.myPid());
    }

    @Override
    public String getDocumentType(String documentId) throws FileNotFoundException {
        if (DOC_ID_ROOT.equals(documentId)) {
            return Document.MIME_TYPE_DIR;
        }
        if (DOC_ID_SAVE.equals(documentId)) {
            return SAVE_MIME;
        }
        throw new FileNotFoundException(documentId);
    }

    @Override
    public boolean isChildDocument(String parentDocumentId, String documentId) {
        return DOC_ID_ROOT.equals(parentDocumentId) && DOC_ID_SAVE.equals(documentId);
    }

    @Override
    public Point getDocumentThumbnail(String documentId, Point sizeHint,
                                      CancellationSignal signal) {
        return null;
    }
}
