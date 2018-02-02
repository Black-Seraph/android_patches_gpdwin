#!/bin/bash

# determine the GPD Win patches folder location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# bundle the MagiskManager into the system
mkdir "out/target/product/x86_64/system/priv-app/MagiskManager"
cp -f "$DIR/magisk/MagiskManager.apk" "out/target/product/x86_64/system/priv-app/MagiskManager"

# delete all files we wish to rebuild
rm -f "out/target/product/x86_64/android_x86_64.iso"
rm -f "out/target/product/x86_64/system.sfs"
rm -f "out/target/product/x86_64/obj/PACKAGING/systemimage_intermediates/system.img"

# copy the magisk init binary into the ramdisk
# we need to go this roundabout way because android-x86 has three ramdisks...
# but we must only patch the android-x86 live system one, otherwise we bootloop!
#cd "out/target/product/x86_64"
#mkdir magisk
#cd magisk
#gzip -cd ../ramdisk.img | cpio -i
#cp "$DIR/magisk/init" .
#find . | cpio -o -H newc | gzip > ../ramdisk.img
#cd ..
#rm -rf magisk
#cd ../../../..

# workaround until I figure out what's wrong with the code above
cp "$DIR/magisk/ramdisk.img" "out/target/product/x86_64"

# setup the aosp build environment
. build/envsetup.sh

# pick our lunch
lunch android_x86_64-userdebug

# rebuild the image
m -j4 iso_img
