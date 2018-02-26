#!/bin/bash

# determine the GPD Win patches folder location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# fix the screen rotation (portrait -> landscape)
cd frameworks/base
git reset --hard
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/frameworks_base_rotate_screen.diff"
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/frameworks_base_swallow_gapps_connection_error.diff"
cd ../..

# grant wificond the required capabilities to control wifi
cd system/connectivity/wificond
git reset --hard
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/system_connectivity_wificond_wifi_capability.diff"
cd ../../..

# patch the device tree to fix a whole bunch of GPD Win related problems
cd device/generic/common
git reset --hard
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/device_generic_common_gpdwin.diff"
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
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/system_vold_fix_micro_sd_internal_storage.diff"
cd ../..

# remove outdated AOSP packages and disable the bionic ld warning
cd build/make
git reset --hard
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/build_make_remove_aosp_packages.diff"
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/build_make_disable_bionic_ld_warning.diff"
cd ../..

# change the launcher shortcuts
cd packages/apps/Launcher3
git reset --hard
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/packages_apps_Launcher3_shortcuts.diff"
cd ../../..

# swap the default wallpaper
cd frameworks/base/core/res/res
cp "$DIR/blob/default_wallpaper.png" drawable-nodpi
cd ../../../../..

# configure and patch the kernel so the GPD Win and GPD Pocket will work with Android Oreo
cd kernel
git reset --hard
git clean -qfdx
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/pocket/d53a5e45c19db77c901ac6ea731cfcaffdd4a74d.diff"
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/pocket/7e23c812de8cee1b6ee5ad22a0252cb054617b6d.diff"
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/pocket/6c599d00a453db32daf189b1e788d2d713d4b57d.diff"
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/pocket/10f45aa5416d1b605c2e6609320df881a63a0469.diff"
cp "$DIR/blob/android-x86_64_defconfig" arch/x86/configs/android-x86_64_defconfig
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/kernel_disable_werror.diff"
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/kernel_enable_monotonic_bss_tsf.diff"
cd ..

# patch the installer to boot off an older pre-built kernel (to avoid the vesamenu backlight bug)
cd bootable/newinstaller
git reset --hard
git clean -qfdx
cp "$DIR/blob/vesakernel" boot/install
git apply --ignore-space-change --ignore-whitespace "$DIR/diff/bootable_newinstaller_backlight_bug_workaround.diff"
rm -f .git/shallow 2>/dev/null
cd ../..

# remove the su binary (as we will bundle magisk later)
cd system/extras
git reset --hard
git clean -qfdx
rm -rf su
cd ../..

# we are running in WSL
if grep -q Microsoft /proc/version
then
	# patch the build tools
	cd build/tools
	git reset --hard
	git clean -qfdx
	git apply --ignore-space-change --ignore-whitespace "$DIR/diff/build_tools_wsl.diff"
	cd ../..

	# replace the prebuilt ijar with 64bit version
	cd prebuilts/build-tools
	cp "$DIR/blob/wsl/ijar" "linux-x86/bin"
	cp "$DIR/blob/wsl/ckati_stamp_dump" "linux-x86/asan/bin"
	cd ../..

	# replace bison and flex with 64bit versions
	cd prebuilts/misc
	git reset --hard
	git clean -qfdx
	git apply --ignore-space-change --ignore-whitespace "$DIR/diff/prebuilts_misc_wsl.diff"
	cd common/android-support-test/espresso
	cp "$DIR/blob/wsl/espresso-contrib-2.3-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/espresso-contrib-2.3-beta-2-release.jar" .
	cp "$DIR/blob/wsl/espresso-core-2.3-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/espresso-core-2.3-beta-2-release.jar" .
	cp "$DIR/blob/wsl/espresso-idling-resource-2.3-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/espresso-intents-2.3-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/espresso-intents-2.3-beta-2-release.jar" .
	cp "$DIR/blob/wsl/espresso-web-2.3-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/espresso-web-2.3-beta-2-release.jar" .
	cp "$DIR/blob/wsl/exposed-instrumentation-api-publish-0.6-beta-2-release-no-dep.jar" .
	cd ../rules
	cp "$DIR/blob/wsl/rules-0.6-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/rules-0.6-beta-2-release.jar" .
	cd ../runner
	cp "$DIR/blob/wsl/runner-0.6-beta-2-release-no-dep.jar" .
	cp "$DIR/blob/wsl/runner-0.6-beta-2-release.jar" .
	cd ../../../linux-x86/bison
	cp "$DIR/blob/wsl/bison" .
	cd ../flex
	cp "$DIR/blob/wsl/flex-2.5.39" .
	cd ..
	mkdir lib64 2>/dev/null
	cd lib64
	cp "$DIR/blob/wsl/libc++.so" .
	cd ../../../..

	# disable hostutil multilib support for mesa (this forces the build-tools to use the 64bit header generator)
	cd external/mesa
	git reset --hard
	git clean -qfdx
	git apply --ignore-space-change --ignore-whitespace "$DIR/diff/external_mesa_disable_hostutil_multilib.diff"
	cd ../..

	# disable dexpreopt for WSL builds
	cd device/generic/common
	git apply --ignore-space-change --ignore-whitespace "$DIR/diff/device_generic_common_disable_dexpreopt.diff"
	cd ../../..
fi
