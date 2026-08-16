package com.owcramer.pokeemerald

import android.os.Bundle
import android.util.Log
import java.io.File
import org.libsdl.app.SDLActivity

/**
 * The game. A plain SDLActivity apart from the save mirror.
 *
 * SDLActivity does not start the native thread from onCreate -- it waits for the
 * surface to be created and focused (see its NativeState.RESUMED transition) --
 * so work done here is guaranteed to finish before main() runs and reads the
 * save. That is why the mirror is reconciled here rather than in
 * [SaveSetupActivity]: a task resumed from Recents comes straight back to this
 * activity, and the setup activity never runs at all.
 */
class GameActivity : SDLActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Before super, so the ordering above does not depend on anything inside
        // SDLActivity.onCreate staying the way it is today. The context is
        // attached by this point, which is all this needs.
        if (!synced) {
            synced = true
            try {
                migrateExternalFiles()
                SaveMirror.sync(this)
            } catch (t: Throwable) {
                // The internal save is authoritative and untouched on failure;
                // never let a storage problem stop the game from starting.
                Log.w(TAG, "save mirror sync failed", t)
            }
        }

        super.onCreate(savedInstanceState)
    }

    /**
     * Called from native code after the game writes its save; see
     * Platform_StoreSaveFile in src/platform/sdl3.c. Runs on the SDL thread.
     */
    fun pushSaveToMirror() {
        try {
            SaveMirror.push(this)
        } catch (t: Throwable) {
            Log.w(TAG, "save mirror push failed", t)
        }
    }

    /**
     * One-time move for files left in Android/data/<pkg>/files by a development
     * build that briefly kept them there. That build was never released, so this
     * only matters to testers -- but it is the difference between their save
     * carrying over and appearing to vanish.
     */
    private fun migrateExternalFiles() {
        // null while no external storage is mounted; nothing to migrate from.
        val external = getExternalFilesDir(null) ?: return

        migrate(File(external, SaveMirror.SAVE_NAME), SaveMirror.internalSave(this))
        migrate(File(external, BINDINGS_NAME), File(filesDir, BINDINGS_NAME))
    }

    companion object {
        private const val TAG = "GameActivity"
        private const val BINDINGS_NAME = "controls.cfg"

        /**
         * The reconcile is once per process, not once per onCreate. If the
         * activity is destroyed and re-created while the native thread is still
         * alive, the game already holds the save in memory and pulling the
         * mirror over it would be writing under its feet.
         */
        private var synced = false

        /**
         * The newer file wins. Both locations can hold one at once -- the dev
         * build copied rather than moved -- and picking by mtime is what stops
         * the stale copy it left behind from shadowing real progress.
         */
        private fun migrate(from: File, to: File) {
            if (!from.isFile || from.length() == 0L) return
            if (to.isFile && to.lastModified() >= from.lastModified()) return

            // Via a temp file, so a copy that dies part way through cannot leave
            // a truncated save where a working one used to be.
            val temp = File(to.parentFile, "${to.name}.tmp")
            try {
                from.inputStream().use { input ->
                    temp.outputStream().use { output ->
                        input.copyTo(output)
                        output.fd.sync()
                    }
                }
                check(temp.renameTo(to)) { "rename to $to failed" }
                Log.i(TAG, "migrated ${from.name} out of the external files directory")
            } catch (e: Exception) {
                Log.w(TAG, "could not migrate $from", e)
                temp.delete()
            }
        }
    }
}
