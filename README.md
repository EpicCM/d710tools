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
    <project name="noobnl/e4gttools.git" path="e4gttools" remote="github" revision="ics" />
    <project name="EpicCM/android_device_samsung_epic4gtouch" path="device/samsung/epic4gtouch" remote="github" />
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
breakfast cm_epic4gtouch-userdebug
make -j4 bacon
```
