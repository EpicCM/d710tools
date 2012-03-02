Epic Build Instructions
=======================
```
mkdir cm9
cd cm9
repo init -u git://github.com/CyanogenMod/android.git -b ics
```

Modify your `.repo/local_manifest.xml` as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
  <manifest>
    <project name="EpicCM/epictools.git" path="epictools" remote="github" revision="ics" />
    <project name="CyanogenMod/android_kernel_samsung_victory" path="kernel/samsung/victory" remote="github" revision="ics" />
    <project name="CyanogenMod/android_device_samsung_epicmtd" path="device/samsung/epicmtd" remote="github" />
  </manifest>
```

```
repo sync
vendor/cm/get-prebuilts
```

Auto Apply Patches
==================
This script will remove any topic branches named auto, then apply all patches under topic branch auto.

```
epictools/apply.sh
```

Build
=====
```
. build/envsetup.sh
breakfast cm_epicmtd-userdebug
make -j4 bacon
```
