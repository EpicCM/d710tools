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
repo start auto frameworks/native
echo "samsung stuff"
cdv frameworks/native
git reset --hard
git fetch http://review.cyanogenmod.org/CyanogenMod/android_frameworks_native refs/changes/61/26961/3 && git cherry-pick FETCH_HEAD
cdb

repo start auto prebuilt
echo "fix prebuilt"
cdv prebuilt
git reset --hard
rm -rf android* sdk ndk common windows
cdb
##### SUCCESS ####
SUCCESS=true
exit 0
