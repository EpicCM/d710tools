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

cdv device/samsung/epic4gtouch
echo "### patching config.xml for vmnotif in overlay/packages/apps/Phone/res/values/config.xml"
git reset --hard
http_patch http://darchstar.shabbypenguin.com/CM9/patch/vmnotif.patch
cdb

repo start auto packages/apps/Settings
echo "### apply cpufreq patch so processor settings reads our cpufreq table properly... i should commit this to gerrit sometime soon"
cdv packages/apps/Settings
git reset --hard
http_patch http://darchstar.shabbypenguin.com/CM9/patch/cpufreq.patch
cdb

repo start auto frameworks/base
cdv frameworks/base
echo "### telephony: CDMA signal bar threshold s/100/105/ to match Samsung's behavior (DO NOT COMMIT) http://review.cyanogenmod.com/#/c/15580/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/80/15580/5 && git cherry-pick FETCH_HEAD
echo "### Phone: Sprint MWI Quirk: Phantom message wait indicator workaround (2/2) http://review.cyanogenmod.com/#/c/16983/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_frameworks_base refs/changes/83/16983/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/9 && git cherry-pick FETCH_HEAD
cdb


##### SUCCESS ####
SUCCESS=true
exit 0
