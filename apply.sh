#!/bin/bash

apply_patch() {
  PATCHNAME=$(basename $1)
  curl -L -o $PATCHNAME -O -L $1
  cat $PATCHNAME |patch -p1
  rm $PATCHNAME
}

# Change directory verbose
cdv() {
  echo
  echo "*****************************"
  echo "Current Directory: $1"
  echo "*****************************"
  cd $BASEDIR/$1
}

# Change back to base directory
cdb() {
  cd $BASEDIR
}

# Sanity check
if [ -d ../.repo ]; then
  cd ..
fi
if [ ! -d .repo ]; then
  echo "ERROR: Must run this script from the base of the repo."
  exit 255
fi

# Save Base Directory
BASEDIR=$(pwd)

# Abandon auto topic branch
repo abandon auto

################ Apply Patches Below ####################

repo start auto vendor/cm/
cdv vendor/cm/
echo "### Patching Boot Animation ###"
curl -L -o ./prebuilt/common/bootanimation.zip -O -L http://togami.com/~warren/temp/bootani-cm9-ver1-looponly-halfframe-16fps.zip
git add prebuilt/common/bootanimation.zip
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### Debug disappearing sdcard ringtones"
apply_patch http://www.club.cc.cmu.edu/~mkasick/patches/frameworks_base_debug.diff
git add media/java/android/media/MediaScanner.java
git add media/libmedia/MediaScanner.cpp
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto packages/providers/MediaProvider
cdv packages/providers/MediaProvider
echo "### Debug disappearing sdcard ringtones"
apply_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug.diff
git add src/com/android/providers/media/MediaScannerService.java
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
echo "### Patching make-kexec-cwm-test-zip.sh http://review.cyanogenmod.com/#change,13090"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/90/13090/1 && git cherry-pick FETCH_HEAD
cdb

