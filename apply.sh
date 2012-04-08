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

repo start auto device/samsung/epicmtd
cdv device/samsung/epicmtd
echo "### epicmtd: enable enable_vmnotif_option http://review.cyanogenmod.com/#change,13739"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_device_samsung_epicmtd refs/changes/39/13739/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto frameworks/base 
cdv frameworks/base
echo "### Patch: CDMA 1 signal bar threshold s/100/105/ to match Samsung"
http_patch http://asgard.ancl.hawaii.edu/~warren/testonly-cdma-1bar-105-dBm-v3.patch
git add telephony/java/android/telephony/SignalStrength.java
git commit -m "DO NOT COMMIT TO GERRIT - need to make into config.xml option for upstream"
echo "### Test gcc http://review.cyanogenmod.com/#change,14549"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/49/14549/1 && git cherry-pick FETCH_HEAD
echo "### Sensor: Add RotationVectorSensor2 http://review.cyanogenmod.com/#change,14609"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_frameworks_base refs/changes/09/14609/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto external/srec
cdv external/srec
echo "### Test gcc http://review.cyanogenmod.com/#change,14548"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_external_srec refs/changes/48/14548/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto kernel/samsung/victory
cdv kernel/samsung/victory
#echo "### Epicmtd: reduce framebuffer NR size to 2 and frees 7mb to userspace http://review.cyanogenmod.com/#change,14386"
#git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/86/14386/1 && git cherry-pick FETCH_HEAD
#echo "### Test with CONFIG_FB_S3C_NR_BUFFERS=6 since =2 was rejected (read above gerrit)"
#http_patch http://asgard.ancl.hawaii.edu/~warren/test-CONFIG_FB_S3C_NR_BUFFERS-6.patch
#git add Kernel/arch/arm/configs/cyanogenmod_epicmtd_defconfig
#git commit -m "DO NOT COMMIT TO GERRIT - test CONFIG_FB_S3C_NR_BUFFERS=6"
echo "### Adjust external-speaker playback-gain levels to match EL30. http://review.cyanogenmod.com/#change,14593"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_kernel_samsung_victory refs/changes/93/14593/1 && git cherry-pick FETCH_HEAD
cdb

repo start auto packages/apps/Phone
cdv packages/apps/Phone
echo "### Phone: add voicemail notification setting http://review.cyanogenmod.com/#change,13706"
git fetch http://review.cyanogenmod.com/p/CyanogenMod/android_packages_apps_Phone refs/changes/06/13706/6 && git cherry-pick FETCH_HEAD
cdb

##### SUCCESS ####
SUCCESS=true
exit 0
