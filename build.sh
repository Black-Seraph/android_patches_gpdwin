#!/bin/bash

# determine the GPD Win patches folder location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# patch the source code
bash "$DIR/patch.sh"

# setup the aosp build environment
. build/envsetup.sh

# pick our lunch
lunch android_x86_64-userdebug

if [ "$1" == "installclean" ]
then
	# clean the build directory (soft-rebuild)
	make installclean
else
	# clean the build directory (full-rebuild)
	make clean
fi

# build the image
m -j4 iso_img
