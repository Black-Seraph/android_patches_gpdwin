# android_patches_gpdwin
This repository builds on top of the oreo-x86 branch of the Android-x86 project and provides all required patches to make Android-x86 work reliably on a GPD Win handheld gaming device.

# Build instructions
* repo init -u git://git.osdn.net/gitroot/android-x86/manifest.git -b oreo-x86
* git clone https://github.com/Black-Seraph/android_patches_gpdwin.git patches
* cp -rf patches/local_manifests .repo
* repo sync --no-tags --no-clone-bundle --force-sync
* ./patches/build.sh
* ./patches/importmagisk.sh

Your build will be in out/target/product/x86_64/android_x86_64.iso
