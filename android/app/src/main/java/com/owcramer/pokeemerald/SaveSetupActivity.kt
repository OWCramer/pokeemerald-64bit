package com.owcramer.pokeemerald

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.provider.DocumentsContract
import android.util.Log
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.color.DynamicColors
import com.google.android.material.dialog.MaterialAlertDialogBuilder

/**
 * The launcher activity, and nothing but a doorway: it makes sure the save
 * mirror has a folder to write to, then hands over to [GameActivity] and
 * finishes.
 *
 * It is a separate activity because the folder question needs an answer *before*
 * the game reads its save, and SDL cannot usefully be paused mid-startup to wait
 * for one. Asking here means the game process starts with it already settled.
 *
 * In the normal case -- a folder already picked -- nothing is drawn: the window
 * is transparent and the game starts immediately. It is excluded from Recents,
 * so the only task the user ever sees is the game's.
 */
class SaveSetupActivity : AppCompatActivity() {

    /**
     * OpenDocumentTree with the write and persistable flags spelled out. The
     * picker sets them itself, but [SaveMirror.setTree] fails without them, and
     * that is not a dependency worth leaving implicit.
     */
    private val pickFolder = registerForActivityResult(
        object : ActivityResultContracts.OpenDocumentTree() {
            override fun createIntent(context: Context, input: Uri?): Intent =
                super.createIntent(context, input)
                    .addFlags(SaveMirror.TREE_FLAGS or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        }
    ) { uri ->
        if (uri != null)
            SaveMirror.setTree(this, uri)

        // Either way the game starts. A cancelled or failed grant is the same as
        // "Not now": play on the internal save, and ask again next launch.
        startGame()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        DynamicColors.applyToActivityIfAvailable(this)

        if (SaveMirror.isConfigured(this))
            startGame()
        else
            askForFolder()
    }

    /**
     * The picker on its own is baffling -- a file browser appears with nothing
     * to say what it wants -- so explain what the folder is for first. "Not now"
     * is a real answer: the game plays fine without a mirror, and the question
     * comes back next launch, which is the only way back to it given there is no
     * settings screen.
     */
    private fun askForFolder() {
        MaterialAlertDialogBuilder(this)
            .setTitle(R.string.save_folder_title)
            .setMessage(R.string.save_folder_message)
            .setPositiveButton(R.string.save_folder_choose) { _, _ -> launchPicker() }
            .setNegativeButton(R.string.save_folder_skip) { _, _ -> startGame() }
            // Back dismisses it, and dismissing means "Not now" -- being stuck
            // behind a dialog would be worse than having no mirror.
            .setOnCancelListener { startGame() }
            .show()
    }

    private fun launchPicker() {
        // Open on Documents. Android 11 and up refuse a grant on the root of
        // internal storage and on Android/data, so landing somewhere that can
        // actually be picked saves the user a rejection they cannot explain.
        val documents = DocumentsContract.buildDocumentUri(
            "com.android.externalstorage.documents",
            "primary:" + Environment.DIRECTORY_DOCUMENTS,
        )

        try {
            pickFolder.launch(documents)
        } catch (e: Exception) {
            // No document picker on this device (some TV and kiosk images).
            Log.w(TAG, "no folder picker available", e)
            startGame()
        }
    }

    private fun startGame() {
        // NO_ANIMATION so the handoff does not read as two apps opening.
        startActivity(
            Intent(this, GameActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
        )
        finish()
    }

    private companion object {
        const val TAG = "SaveSetup"
    }
}
