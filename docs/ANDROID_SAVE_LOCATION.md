# Android: where the save lives

**Status: design. Nothing is implemented.** Branch `owen/android-saf-save`.

## Where it stands

The save is `Android/data/<pkg>/files/pokeemerald.sav`. Android 11 removed that
directory from file managers and from MTP, so nothing but the app and Auto
Backup can reach it. It is backed up -- Google One lists it -- but it cannot be
copied to mGBA, to a PC, or off a dying phone, which was the point.

Reaching it needs the Storage Access Framework: the player picks a location, the
app is granted persistable access to it, and reads and writes go through a
`content://` URI rather than a path.

## The model: one file, and it is the player's

The player picks a folder. `pokeemerald.sav` inside it **is** the save. There is
no second copy anywhere.

An earlier draft made it a mirror -- app-private save, copy in the chosen
folder, adopt whichever had the higher save counter at launch. That is the right
design for iCloud (see `IOS_ICLOUD_SAVE_SYNC.md`, where it stays) and the wrong
one here, and the case that shows why is deleting the file: the next save would
put it back, with the old contents. The player says remove this and the app says
no.

The deeper mistake was carrying a *sync* policy into an *export* context.
"Newest counter wins" settles a race between two devices that nobody is managing
by hand. In a folder the player chose, identical file events mean different
things:

| what they did | what a mirror does | what one file does |
|---|---|---|
| deleted it | recreates it next save | the save is gone |
| dropped in a save from mGBA | adopts it only if its counter is higher | loads it |
| restored an older backup | **refuses it** -- counter is lower | loads it |
| moved it elsewhere | recreates it, so now there are two | it is gone; pick again |

Only the last column is what the player meant. The rule the mirror broke: **if a
deliberate action can be silently undone, the design has assumed intent instead
of reading it.**

So: no counters, no adoption, no resurrection. Deleting a save file deletes the
save, exactly as it would on a cartridge.

## The trade-off this forces, which is not optional

Auto Backup only covers app-private directories. A file in a folder the player
chose is outside all of them, so **moving the save out of app storage gives up
Google One backup.** There is no configuration that gets both; the two goals are
genuinely opposed.

Rather than pick for them, the choice is the act of choosing a folder:

* **Default, nothing chosen:** the save stays at
  `Android/data/<pkg>/files/pokeemerald.sav`. Backed up, unreachable. This is
  today's behaviour and it stays the default.
* **A folder chosen:** the save moves there and lives there. Reachable,
  no longer backed up by Google -- though the player can pick a folder that
  something else syncs, which is their business and not the app's.

Picking a folder is the player saying they would rather manage it themselves.
Whatever prompt offers the choice has to say what it costs, in those terms.

## Mechanics

**The URI.** `ACTION_OPEN_DOCUMENT_TREE` for a folder, then
`takePersistableUriPermission` so it survives reboots, and the tree URI stored in
`SharedPreferences`. A folder rather than a single document: a single-document
URI dies with the file, so deleting the save would also lose the location and
force a re-pick, when what the player wants is a fresh save in the same place.

**Reaching it from C.** `ContentResolver.openFileDescriptor(uri, "rw")` gives a
`ParcelFileDescriptor`; `detachFd()` hands over a plain integer file descriptor,
and `fdopen(fd, "r+b")` turns that into the `FILE *` the save code already uses.
So `ReadSaveFile` and `StoreSaveFile` need no changes at all -- only the thing
that produces `sSaveFile` does. That is the whole reason this is affordable.

**Java.** A `MainActivity extends SDLActivity` to own the picker, the result,
the preference, and the dialogs. The manifest points at it instead of
`org.libsdl.app.SDLActivity`.

## What happens when things go wrong

**The folder is gone at launch** -- permission revoked, SD card pulled, folder
deleted. The one thing not to do is quietly open a different save: the player
would be looking at an old file, or a new game, with no idea why. Say so in a
dialog and offer to pick again or to fall back to internal storage for now.
Java dialogs are available before SDL starts, which is the natural place for
this.

**The file is gone but the folder is fine.** No save: the game starts fresh and
writes a new one there. That is what deleting a save means.

**A save dropped in while the game is running.** Not noticed. The file is read
once at launch, and the in-memory copy is written back over it at every save
point, so a file swapped underneath a running game is overwritten. Swap saves
with the game closed. Worth checking the document still exists when the app
returns to the foreground, and prompting if it does not.

**Deleted while the game is running.** The open descriptor may keep accepting
writes that go nowhere. The foreground check above is the mitigation.

## Migrating in

When a folder is first chosen, the existing save **moves**: copy it in, verify
the copy is 128 KB and its save counter matches, then delete the original. A
copy would leave two saves and no way to tell which is live, which is the
problem this design exists to avoid. The delete happens only after the
verification.

## What cannot be checked here

There is no Android SDK or NDK on this machine; CI builds the APK. The Java and
JNI will be compile-checked by CI and **not run by me at all**. Everything
touching the save has to fail closed: if the picker, the URI, the descriptor or
the migration fails, the app keeps using the app-private path it uses today and
loses nothing.

Worth testing on a device, in this order: pick a folder and confirm the save
moves and the old file is gone; kill and relaunch and confirm it loads from the
folder; copy the file to a PC and open it in mGBA; delete it and confirm a fresh
game rather than a resurrection; revoke the permission in Settings and confirm
the dialog rather than a silent second save.

## Open questions

1. **When to offer the folder.** On first launch, or only when the player goes
   looking for it? There is no menu to put it behind, and a picker on first
   launch before the game appears is heavy-handed. A one-time prompt seems the
   least bad, but it needs wording that makes the backup trade-off clear.
2. **Should the fallback be silent?** If a folder was chosen and is now
   unavailable, falling back to internal storage silently is the behaviour this
   design exists to avoid -- but a dialog on every launch while an SD card is
   out is its own problem.
