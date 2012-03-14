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
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch - Boot Animation"
cdb

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### epicmtd: omx: mfc mmap buffer reduction to 22MB (included in beta0) http://review.cyanogenmod.com/#change,13319"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/19/13319/2 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
#echo "### Debug disappearing sdcard ringtones"
#http_patch http://www.club.cc.cmu.edu/~mkasick/patches/frameworks_base_debug.diff
#git add media/java/android/media/MediaScanner.java
#git add media/libmedia/MediaScanner.cpp
#git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
echo "### Test Patch: CDMA 1 signal bar threshold s/100/105/ to match Samsung"
http_patch http://asgard.ancl.hawaii.edu/~warren/testonly-cdma-1bar-105-dBm-v2.patch
git add telephony/java/android/telephony/SignalStrength.java
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch - CDMA signal bar"
echo "### Test Patch: VM"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/01/13501/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Mms
cdv packages/apps/Mms
echo "### Mms: Remove SMS Split option and reset user preference to default http://review.cyanogenmod.com/#change,13504" 
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Mms refs/changes/04/13504/1 && git cherry-pick FETCH_HEAD
cdb

#repo start auto packages/providers/MediaProvider
#cdv packages/providers/MediaProvider
#echo "### Debug disappearing sdcard ringtones"
#http_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug.diff
#http_patch http://www.club.cc.cmu.edu/~mkasick/patches/packages_providers_MediaProvider_debug3.diff
#git add src/com/android/providers/media/MediaScannerService.java
#git add src/com/android/providers/media/MediaProvider.java
#rm -f src/com/android/providers/media/MediaProvider.java.orig
#git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
#cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
echo "### epicmtd: decrease mmap usage to provide more ram to userspace. (included in beta0) http://review.cyanogenmod.com/#change,13318"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/18/13318/4 && git cherry-pick FETCH_HEAD
echo "### Free more RAM by disabling FIMC1 mmap and reduce mmap usage for JPEG driver. 1.9 MB is freed. http://review.cyanogenmod.com/#change,13369"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/69/13369/2 && git cherry-pick FETCH_HEAD
echo "### Epicmtd: add missing encyrpting support to kernel for device encyrption http://review.cyanogenmod.com/#change,13374"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/74/13374/1 && git cherry-pick FETCH_HEAD
echo "### epicmtd: disable mdnie and disable useless devices that don't exist for this SOC. http://review.cyanogenmod.com/#change,13433"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/33/13433/2 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Make it possible to dismiss the waiting voicemail notification. http://review.cyanogenmod.com/#change,13592"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/92/13592/2 && git cherry-pick FETCH_HEAD
cdb
