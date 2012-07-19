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

repo start auto packages/apps/Settings
echo "### apply cpufreq patch so processor settings reads our cpufreq table properly... i should commit this to gerrit sometime soon"
echo "### updated by nivron"
cdv packages/apps/Settings
git reset --hard
http_patch http://chris41g.org/patches/processor.patch
cdb

repo start auto build
echo "### modify CM build script"
cdv build
git reset --hard
http_patch http://chris41g.org/patches/build.patch
cdb

repo start auto bootable/recovery
cdv bootable/recovery
echo "### Add support for using an update-binary that is included in recovery http://review.cyanogenmod.com/#/c/17576/"
git fetch http://review.cyanogenmod.com/CyanogenMod/android_bootable_recovery refs/changes/76/17576/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base
echo "### modify CM framework to test ril"
cdv frameworks/base
git reset --hard
http_patch http://chris41g.org/patches/RIL.patch
cdb
##### SUCCESS ####
SUCCESS=true
exit 0
