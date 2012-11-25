Epic Build Instructions
=======================
```
mkdir cm10
cd cm10
repo init -u git://github.com/CyanogenMod/android.git -b jellybean
```

Modify your `.repo/local_manifest.xml` as follows:

```xml
?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="EpicCM/d710tools.git" path="d710tools" remote="github" revision="jellybean" />
  <project name="EpicCM/android_device_samsung_d710" path="device/samsung/d710" remote="github" revision="jellybean" />
  <project name="CyanogenMod/android_device_samsung_galaxys2-common" path="device/samsung/galaxys2-common" remote="github" revision="jellybean" />
  <project name="CyanogenMod/android_hardware_samsung" path="hardware/samsung" remote="github" revision="jellybean" />
  <project name="EpicAOSP/android_kernel_samsung_smdk4210_new" path="kernel/samsung/smdk4210" remote="github" revision="jb-dev" />
  <project name="CyanogenMod/android_packages_apps_SamsungServiceMode" path="packages/apps/SamsungServiceMode" remote="github" revision="jellybean" />
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
