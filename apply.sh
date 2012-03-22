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
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_vendor_cm refs/changes/79/13579/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### epicmtd: enable enable_vmnotif_option http://review.cyanogenmod.com/#change,13739"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/39/13739/1 && git cherry-pick FETCH_HEAD
echo "### epicmtd: epicmtd: CM9 beta1 kernel (excluding disable mdnie) http://review.cyanogenmod.com/#change,13842"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/42/13842/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### Test Patch: CDMA 1 signal bar threshold s/100/105/ to match Samsung"
http_patch http://asgard.ancl.hawaii.edu/~warren/testonly-cdma-1bar-105-dBm-v2.patch
git add telephony/java/android/telephony/SignalStrength.java
git commit -m "DO NOT COMMIT TO GERRIT - Temporary Patch"
cdb

#repo start auto kernel/samsung/victory
#cdv kernel/samsung/victory
#echo "### Epicmtd: add missing encyrpting support to kernel for device encyrption http://review.cyanogenmod.com/#change,13374"
#git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/74/13374/1 && git cherry-pick FETCH_HEAD
#cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
cdb
