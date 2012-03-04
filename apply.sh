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
echo "### Modular backuptool.sh. Executes backup and restore methods defined in arbitrary /system/addon.d/*.sh scripts. http://review.cyanogenmod.com/#change,13267"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_vendor_cm refs/changes/67/13267/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### removes cflag defines ### http://review.cyanogenmod.com/#change,13035"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/35/13035/6 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### SamsungRIL: Fixes for CDMA data reconnection failures due to stale pppd. http://review.cyanogenmod.com/13230"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/30/13230/1 && git cherry-pick FETCH_HEAD
echo "### Debug disappearing sdcard ringtones"
apply_patch http://www.club.cc.cmu.edu/~mkasick/patches/frameworks_base_debug.diff
git add media/java/android/media/MediaScanner.java
git add media/libmedia/MediaScanner.cpp
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
echo "### Test Patch: CDMA 1 signal bar threshold s/100/105/ to match Samsung"
apply_patch http://asgard.ancl.hawaii.edu/~warren/testonly-cdma-1bar-105-dBm-v2.patch
git add telephony/java/android/telephony/SignalStrength.java
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto packages/providers/MediaProvider
cdv packages/providers/MediaProvider
echo "### Check external storage volume ID to ensure media is actually mounted. http://review.cyanogenmod.com/13251"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_providers_MediaProvider refs/changes/51/13251/1 && git cherry-pick FETCH_HEAD
echo "### Debug disappearing sdcard ringtones"
apply_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug.diff
apply_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug3.diff
git add src/com/android/providers/media/MediaScannerService.java
git add src/com/android/providers/media/MediaProvider.java
rm -f src/com/android/providers/media/MediaProvider.java.orig
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
echo "### Ignore IOCTL_MFC_BUF_CACHE requests, fixes decoded video artifacts. http://review.cyanogenmod.com/#change,13149"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/49/13149/4 && git cherry-pick FETCH_HEAD
cdb

repo start auto build
cdv build
echo "### Modular backuptool.sh. Executes backup and restore methods defined in arbitrary /system/addon.d/*.sh scripts. http://review.cyanogenmod.com/#change,13265"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_build refs/changes/65/13265/2 && git cherry-pick FETCH_HEAD
cdb

repo start auto system/core
cdv system/core
echo "### Modular backuptool.sh. Executes backup and restore methods defined in arbitrary /system/addon.d/*.sh scripts. http://review.cyanogenmod.com/#change,13266"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_system_core refs/changes/66/13266/2 && git cherry-pick FETCH_HEAD
cdb
