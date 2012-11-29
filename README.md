Epic Build Instructions
=======================
```
mkdir -p android/CM
cd android/CM
repo init -u git://github.com/CyanogenMod/android.git -b ics
```

Modify your `.repo/local_manifest.xml` as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
  <manifest>
    <project name="EpicCM/d710tools.git" path="d710tools" remote="github" revision="ics" />
    <project name="EpicCM/android_device_samsung_d710" path="device/samsung/d710" remote="github" revision="smdk" />
    <project name="CyanogenMod/android_hardware_samsung" path="hardware/samsung" remote="github" revision="ics" />
    <project name="EpicAOSP/android_kernel_samsung_smdk4210_new" path="kernel/samsung/smdk4210" remote="github" revision="ics" />
    <project name="mcrosson/android_packages_apps_CMFileManager" path="packages/apps/CMFileManager" remote="github" revision="ics" />
    <project name="CyanogenMod/android_packages_apps_SamsungServiceMode" path="packages/apps/SamsungServiceMode" remote="github" revision="ics" />
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
d710tools/apply.sh
```

Build
=====
```
. build/envsetup.sh && brunch d710
```
