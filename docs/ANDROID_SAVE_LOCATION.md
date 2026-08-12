# Android: where the save lives

**Status: design. Nothing is implemented.** Branch `owen/android-saf-save`.

## Where it stands

The save is `Android/data/<pkg>/files/pokeemerald.sav`. Android 11 removed that
directory from file managers and from MTP, so nothing but the app and Auto
Backup can reach it. It is backed up -- Google One lists it -- but it cannot be
copied to mGBA, to a PC, or off a dying phone, which was the point.

The obvious fix -- have the player pick a folder and move the save there -- gets
it reachable and gives up the backup, because Auto Backup only covers
app-private directories. Both were asked for, and the design below gets both by
not moving the file at all.

## The model: one file, exposed rather than moved

The save stays exactly where it is -- `Android/data/<pkg>/files/pokeemerald.sav`
-- and the app publishes it through a **`DocumentsProvider`**. The app then
appears in the Files app under Browse, with the save inside it: copy it out,
paste one in, delete it.

There is one file. It does not move, it is not duplicated, and it stays in
app-private storage, so **Auto Backup keeps covering it** and Google One keeps
listing it.

An earlier draft said reachable and backed-up were mutually exclusive, because
Auto Backup only covers app-private directories and a folder the player picks is
not one. That is true, and it is also the wrong conclusion: the file does not
have to move to the player, the app can bring the player to the file. A
`DocumentsProvider` is the API for exactly that, it has existed since API 19,
and the app already targets far past it.

## What each action means

The draft before that made the exported file a mirror of an app-private
original, adopting whichever had the higher save counter. That is right for
iCloud (see `IOS_ICLOUD_SAVE_SYNC.md`, where it stays) and wrong here, and
deleting the file is the case that shows why. With one published file there is
nothing to reconcile:

| what they did | what a mirror does | what a published file does |
|---|---|---|
| deleted it | recreates it next save | the save is gone |
| pasted in a save from mGBA | adopts it only if its counter is higher | loads it |
| restored an older backup | **refuses it** -- counter is lower | loads it |
| copied it out | nothing, but now two exist | nothing; it was a copy |

Only the last column is what the player meant. The rule the mirror broke: **if a
deliberate action can be silently undone, the design has assumed intent instead
of reading it.** Deleting a save file deletes the save, exactly as on a
cartridge.

## Mechanics

**The provider.** A `DocumentsProvider` over the app's external files
directory, exposing `pokeemerald.sav` and `controls.cfg` and nothing else.
Declared with an authority of `com.owcramer.pokeemerald.saves`, an
intent-filter for `android.content.action.DOCUMENTS_PROVIDER`, and
`android:permission="android.permission.MANAGE_DOCUMENTS"` so only the system
can bind to it -- the standard shape, and what puts the app in the Files app's
Browse list.

The methods that matter are `queryRoots`, `queryDocument`,
`queryChildDocuments`, `openDocument` and `deleteDocument`. `openDocument`
returns a `ParcelFileDescriptor` straight onto the real file, so a copy out is
a read of the actual save and a paste in overwrites it in place.

**The C side does not change at all.** The save is the same path it is today,
opened the same way. That is the whole appeal: no JNI, no descriptor handed
across the boundary, no change to `ReadSaveFile` or `StoreSaveFile`, and nothing
new that can fail on the path between the game and its save.

## What happens when things go wrong

There is far less to go wrong than with a folder the app has to hold a
permission for, because nothing about loading the save depends on any of this.
If the provider is broken, missing, or never used, the game reads and writes the
same file it always did.

**The file is deleted through Files.** No save: the game starts fresh and writes
a new one. That is what deleting a save means.

**A save pasted in while the game is running.** Not noticed. The file is read
once at launch and the in-memory copy is written back at every save point, so a
file replaced underneath a running game is overwritten at the next save. Swap
saves with the game closed. Worth re-reading the file when the app returns to
the foreground, which would close this properly.

**A copy taken while the game is running.** A snapshot of the last save point,
which is the honest answer and needs no handling.

## Migrating in

Nothing to migrate. The file does not move.

## What cannot be checked here

There is no Android SDK or NDK on this machine; CI builds the APK. The provider
will be compile-checked by CI and **not run by me at all**. It fails closed by
construction: it is additive, and the game's own path to its save is untouched,
so the worst case is that the app does not appear in Files.

Worth testing on a device, in this order: find the app under Browse in Files;
copy the save to a PC and open it in mGBA; paste one back in and confirm it
loads on the next launch; delete it and confirm a fresh game rather than a
resurrection; confirm the save still appears in Google One's app data.

## Open questions

1. **Expose `controls.cfg` too, or only the save?** It is editable text and
   being able to fix a binding from a PC is useful, but it is also a file the
   player can break in ways the game will not explain.
2. **Re-read on foreground?** It would make pasting in a save work without
   closing the game, which is what most people will try first. It also means the
   game can have the world change under it if the file is touched while
   suspended, so it wants care about *when* the re-read happens.
