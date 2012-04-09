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

repo start auto frameworks/base
cdv frameworks/base
echo "### Test gcc http://review.cyanogenmod.com/#change,14549"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/49/14549/1 && git cherry-pick FETCH_HEAD
echo "### Dock audio settings Part 1 http://review.cyanogenmod.com/#change,14046"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/46/14046/4 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Settings
cdv packages/apps/Settings
echo "### Dock audio settings Part 2 http://review.cyanogenmod.com/#change,14262"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Settings refs/changes/62/14262/6 && git cherry-pick FETCH_HEAD
echo "### patch for cpufreq to point to our freq table"
git reset --hard
http_patch http://darchstar.shabbypenguin.com/CM9/patch/cpufreq.patch
cdb

repo start auto external/srec
cdv external/srec
echo "### Test gcc http://review.cyanogenmod.com/#change,14548"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_external_srec refs/changes/48/14548/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
cdb


##### SUCCESS ####
SUCCESS=true
exit 0
