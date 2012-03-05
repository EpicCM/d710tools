#!/bin/bash

http_patch() {
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
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_vendor_cm refs/changes/67/13267/5 && git cherry-pick FETCH_HEAD
cdb

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### removes cflag defines ### http://review.cyanogenmod.com/#change,13035"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/35/13035/6 && git cherry-pick FETCH_HEAD
echo "### epicmtd: use ics mfc driver for caching (improves performance of encoder and decoder) part: 2/2 http://review.cyanogenmod.com/#change,13287"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/87/13287/2 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### SamsungRIL: Fixes for CDMA data reconnection failures due to stale pppd. http://review.cyanogenmod.com/13230"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/30/13230/1 && git cherry-pick FETCH_HEAD
echo "### Debug disappearing sdcard ringtones"
http_patch http://www.club.cc.cmu.edu/~mkasick/patches/frameworks_base_debug.diff
git add media/java/android/media/MediaScanner.java
git add media/libmedia/MediaScanner.cpp
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
echo "### Test Patch: CDMA 1 signal bar threshold s/100/105/ to match Samsung"
http_patch http://asgard.ancl.hawaii.edu/~warren/testonly-cdma-1bar-105-dBm-v2.patch
git add telephony/java/android/telephony/SignalStrength.java
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto packages/providers/MediaProvider
cdv packages/providers/MediaProvider
echo "### Check external storage volume ID to ensure media is actually mounted. http://review.cyanogenmod.com/13251"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_providers_MediaProvider refs/changes/51/13251/1 && git cherry-pick FETCH_HEAD
echo "### Fix deletion of least-recently-used external databases. http://review.cyanogenmod.com/13280"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_providers_MediaProvider refs/changes/80/13280/2 && git cherry-pick FETCH_HEAD
echo "### Debug disappearing sdcard ringtones"
http_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug.diff
http_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug3.diff
git add src/com/android/providers/media/MediaScannerService.java
git add src/com/android/providers/media/MediaProvider.java
rm -f src/com/android/providers/media/MediaProvider.java.orig
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
echo "### epicmtd: free unused mmap memory from older samsung powervr driver for gingerbread. result: 13 mb free http://review.cyanogenmod.com/#change,13284"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/84/13284/1 && git cherry-pick FETCH_HEAD
echo "### DockAudio: Add support for audio redirection to samsung docks with the help of the "Galaxy Dock Sound Redirector" market app. http://review.cyanogenmod.com/#change,13288"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/88/13288/1 && git cherry-pick FETCH_HEAD
echo "### epicmtd: change MFC driver to Crespo and enable Samsung MFC caching. http://review.cyanogenmod.com/#change,13286"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/86/13286/1 && git cherry-pick FETCH_HEAD
echo "### Compress epicmtd kernel with xz, saves ~1MB storage. Refactored code from crespo kernel-3.0.23. http://review.cyanogenmod.com/#change,13295"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/95/13295/2 && git cherry-pick FETCH_HEAD
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
