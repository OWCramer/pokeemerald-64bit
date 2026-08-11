// Placeholder so Xcode's app target has something to link. The real executable
// is produced by `make ios IOS_SDK_NAME=iphoneos` and copied over this one by
// the target's post-build script (see project.yml) -- Xcode only needs to
// produce *an* executable for the bundle to be signable and archivable.
int main(void) { return 0; }
