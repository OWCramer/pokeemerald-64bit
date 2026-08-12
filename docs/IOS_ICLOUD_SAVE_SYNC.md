# iOS: syncing the save between devices

**Status: design. Nothing is implemented.** Branch `owen/ios-icloud-sync`, on top
of the change that moved the save into `Documents/`.

## What exists today

The save is `Documents/pokeemerald.sav` in the app sandbox: a 128 KB image of
cartridge flash, visible in the Files app, and included in the device's iCloud
*backup*. Backup is not sync — it restores to the same device after a wipe, and
never moves a save from a phone to an iPad.

The game reads it once at startup into `FLASH_BASE` and writes the whole thing
back at defined points (`StoreSaveFile`): entering the background, low memory,
soft reset, and quit. There is no per-in-game-save write, which is convenient
here: the sync points are already few and already known.

## Goals

* A save made on one device is what the other device loads next time it starts.
* No save is ever destroyed, including when two devices diverge.
* iCloud being off, signed out, or unreachable changes nothing about how the
  game plays.
* The Files-app copy keeps working.

## Non-goals

* Mid-session sync. Adopting a save while the player is standing in a cave is
  worse than not syncing at all.
* Save states, multiple slots, or per-slot merge.
* Android or desktop. The sync layer sits behind a C interface so those keep
  building with a no-op.

## The model: local master, mirrored

The game keeps reading and writing `Documents/pokeemerald.sav` exactly as it
does now. A separate layer copies that file to and from the iCloud ubiquity
container at three moments. The cloud copy is a mirror, never the live file.

The alternative -- making the ubiquity file *the* save -- was rejected:

* Every write would need `NSFileCoordinator`, on the game thread, which is the
  thread that must never block.
* A ubiquity file may not be materialised locally at launch. The game reads its
  save once, very early, and has no way to wait.
* If iCloud is unavailable the game would have no save at all rather than a
  local one.

Mirroring costs a 128 KB copy at three moments a session and keeps every failure
mode local.

## Resolving which save is newer

**Not by modification time.** iCloud rewrites timestamps on download, and a
device with a wrong clock would win every argument.

The save file says it itself. Each of the 32 sectors carries a footer:

| offset in sector | field |
|---|---|
| `0xFF4` | sector id |
| `0xFF6` | checksum |
| `0xFF8` | signature, `0x08012025` |
| `0xFFC` | save counter |

The counter increments with every full save the game writes. So:

```
newness(file) = max(counter of every sector whose signature is 0x08012025)
```

Higher counter wins. This is the game's own notion of "later", it survives
timestamp mangling, and it costs 32 reads of 4 bytes.

Ties (equal counters) mean the same save, or two saves that diverged from the
same point without either advancing. Prefer local and upload nothing.

## The three sync points

**Launch, before the game reads the save.** Ask the container for the item;
if it exists but is not downloaded, start the download and wait, with a timeout.
Compare counters and adopt the cloud file only if it is strictly newer. This is
the only moment a save is ever replaced.

**Entering the background**, right after the existing `StoreSaveFile()`. Upload
if our counter is greater than or equal to the cloud's. iOS gives a few seconds
here, so the upload needs `beginBackgroundTaskWithName:` to avoid being cut off
mid-write.

**Returning to the foreground.** Do *not* adopt. Note the cloud counter; if it
is higher than ours, we are the stale device and must not overwrite it -- see
below.

## The dangerous cases, and what happens

**Fresh install, cloud has a save.** The failure to avoid: the game starts, sees
no local save, offers a new game, the player saves, and that upload replaces
their real save. So the launch check must complete *before* the game reads its
save, and when no local save exists at all the timeout is the only thing
standing between the player and losing their file. Nothing is uploaded until the
launch check has resolved one way or the other.

**Both devices played offline.** Two saves, both real, neither derived from the
other. The counter picks the newer to load, and the loser is *kept*, copied
beside it as `pokeemerald-conflict-<device>-<counter>.sav`. It stays in
`Documents/`, so the player can see it in Files and swap it back. Nothing is
deleted, ever.

**Stale device resumes.** Device A is open with an older save in memory; device B
has since played and uploaded. A must not upload on its next background, or B's
progress is gone. Rule: upload only when our counter is greater than or equal to
the cloud's; otherwise write the conflict copy and leave the cloud alone.

**iCloud off or signed out.** `URLForUbiquityContainerIdentifier` returns nil.
Everything degrades to exactly today's behaviour, silently. This is the common
case for anyone sideloading, and it must not look like an error.

## What this costs outside the code

This is the part that is not just programming:

* **Entitlements.** `com.apple.developer.icloud-container-identifiers` and
  `com.apple.developer.ubiquity-container-identifiers`, both
  `iCloud.com.ocramer.pokeemerald`, plus `com.apple.developer.icloud-services`
  = `CloudDocuments`.
* **The App ID needs the iCloud capability** enabled in the developer portal,
  and the container created. Xcode's automatic signing can do this, but it
  changes the provisioning profile, so the first TestFlight build after this
  will be the test of whether it went through cleanly.
* **`NSUbiquitousContainers`** in the plist if the save should also appear under
  iCloud Drive rather than only syncing invisibly.
* **An Objective-C file.** `NSFileManager`, `NSFileCoordinator` and
  `NSMetadataQuery` have no C interface. That means `src/platform/ios_icloud.m`
  behind a small C header, and a Makefile rule for `.m` under `IOS=1` -- the
  build currently compiles C only.

## Threading

Everything iCloud touches happens on the main thread or a dispatch queue it
owns. The game thread's `StoreSaveFile` is untouched. The background handler
already runs on the main thread, so the upload hangs off the existing
`SDL_EVENT_WILL_ENTER_BACKGROUND` case with no new synchronisation.

The launch check is the one blocking wait, and it happens before the game thread
is created, so there is nothing to race with.

## Sequencing problem at launch

`main()` currently does `ResolveSavePath(); ReadSaveFile(...)` as its first two
statements, before `SDL_Init`. The cloud check has to sit between them, and it
can take seconds on a cold install.

That means either blocking on a black screen, or moving `SDL_Init` and window
creation ahead of the save read so there is something to draw on. The second is
better and is a small reordering: nothing between them touches the save. A plain
"Syncing save…" frame is enough; it only ever appears when a download is
actually pending.

## Testing

Two devices is the only real test, but most of it can be forced on one:

* Write a file with a lower counter into the container by hand and check it is
  not adopted.
* Write one with a higher counter and check it is.
* Delete the local save with a cloud save present -- the fresh-install case.
* Sign out of iCloud entirely and confirm the game behaves exactly as it does
  today.
* Airplane mode across a background/foreground cycle.
* Kill the app during the background upload.

## Open questions

1. **Silent or asked?** Adopting a strictly newer cloud save at launch without
   telling the player is the simplest thing that works, and the counter makes it
   safe in the ordinary case. Showing a choice needs UI the game does not have.
   Silent, with conflicts preserved as files, is the recommendation.
2. **Visible in iCloud Drive**, or only synced? Answered, by the Android design
   next door: keep it invisible. The mirror works here precisely because nobody
   manages this container's files by hand -- "newest counter wins" settles a
   race between devices. Surface it in iCloud Drive and it inherits the bug that
   design was rewritten to remove: a file the player deletes comes back on the
   next save, and an older save they deliberately restored is refused for having
   a lower counter. A file the player can see is a file they will manage, and
   that wants the single-file model instead. See `ANDROID_SAVE_LOCATION.md`.
3. **Does the conflict copy belong in `Documents/` or the container?**
   `Documents/` makes it visible in Files on the device that lost, which is
   where someone would look for it.
