#!/bin/bash

# determine the GPD Win patches folder location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# fix the screen rotation (portrait -> landscape)
cd frameworks/base
git reset --hard
git apply "$DIR/diff/frameworks_base_rotate_screen.diff"
git apply "$DIR/diff/frameworks_base_swallow_gapps_connection_error.diff"
cd ../..

# grant wificond the required capabilities to control wifi
cd system/connectivity/wificond
git reset --hard
git apply "$DIR/diff/system_connectivity_wificond_wifi_capability.diff"
cd ../../..

# patch the device tree to fix a whole bunch of GPD Win related problems
cd device/generic/common
git reset --hard
git apply "$DIR/diff/device_generic_common_gpdwin.diff"
mkdir media 2>/dev/null
cp -f "$DIR/blob/bootanimation.zip" media
mkdir bin 2>/dev/null
cp -f "$DIR/blob/headphone-listener" bin
mkdir etc 2>/dev/null
cp -f "$DIR/blob/houdini8_y.sfs" etc
chmod 775 bin/headphone-listener
cd ../../..

# patch the volatile storage daemon to use ext4 instead of f2fs for mmc devices
# this fixes the micro-sd card compatibility issue @ https://github.com/Black-Seraph/android_patches_gpdwin/issues/4
cd system/vold
git reset --hard
git apply "$DIR/diff/system_vold_fix_micro_sd_internal_storage.diff"
cd ../..

# remove outdated AOSP packages and disable the bionic ld warning
cd build/make
git reset --hard
git apply "$DIR/diff/build_make_remove_aosp_packages.diff"
git apply "$DIR/diff/build_make_disable_bionic_ld_warning.diff"
cd ../..

# change the launcher shortcuts
cd packages/apps/Launcher3
git reset --hard
git apply "$DIR/diff/packages_apps_Launcher3_shortcuts.diff"
cd ../../..

# swap the default wallpaper
cd frameworks/base/core/res/res
cp "$DIR/blob/default_wallpaper.png" drawable-nodpi
cd ../../../../..

# configure and patch the kernel so the GPD Win and GPD Pocket will work with Android Oreo
cd kernel
git reset --hard
git remote add goede https://github.com/jwrdegoede/linux-sunxi.git
git remote update
git fetch --all
git cherry-pick -n d53a5e45c19db77c901ac6ea731cfcaffdd4a74d
git cherry-pick -n 7e23c812de8cee1b6ee5ad22a0252cb054617b6d
git cherry-pick -n 6c599d00a453db32daf189b1e788d2d713d4b57d
git cherry-pick -n 10f45aa5416d1b605c2e6609320df881a63a0469
git reset HEAD
cp "$DIR/blob/android-x86_64_defconfig" arch/x86/configs/android-x86_64_defconfig
git apply "$DIR/diff/kernel_disable_werror.diff"
git apply "$DIR/diff/kernel_enable_monotonic_bss_tsf.diff"
cd ..

# patch the installer to boot off an older pre-built kernel (to avoid the vesamenu backlight bug)
cd bootable/newinstaller
git reset --hard
cp "$DIR/blob/vesakernel" boot/install
git apply "$DIR/diff/bootable_newinstaller_backlight_bug_workaround.diff"
rm -f .git/shallow 2>/dev/null
cd ../..

# remove the su binary (as we will bundle magisk later)
cd system/extras
git reset --hard
rm -rf su
cd ../..
