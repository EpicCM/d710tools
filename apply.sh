#!/bin/bash

unset SUCCESS
on_exit() {
  if [ -z "$SUCCESS" ]; then
    echo "ERROR: $0 failed.  Please fix the above error."
    exit 1
  else
    echo "SUCCESS: $0 has completed."
    exit 0
  fi
}
trap on_exit EXIT

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
  SUCCESS=true
  exit 255
fi

# Save Base Directory
BASEDIR=$(pwd)

# Abandon auto topic branch
repo abandon auto
set -e

################ Apply Patches Below ####################

repo start auto hardware/samsung
cdv hardware/samsung
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_hardware_samsung refs/changes/23/27023/14 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/av
cdv frameworks/av
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_av refs/changes/17/27017/11 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base
cdv frameworks/base
git reset --hard
git clean -fd
http_patch http://chris41g.devphone.org/patches/debug.patch
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/17/26917/5 && git cherry-pick FETCH_HEAD
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_base refs/changes/66/27066/1 && git cherry-pick FETCH_HEAD
#http_patch http://chris41g.devphone.org/patches/moar.patch
cdb

repo start auto device/samsung/galaxys2-common
cdv device/samsung/galaxys2-common
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_device_samsung_galaxys2-common refs/changes/33/27033/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Phone refs/changes/83/27183/1 && git cherry-pick FETCH_HEAD
git fetch http://review.cyanogenmod.org/CyanogenMod/android_packages_apps_Phone refs/changes/73/27073/2 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
