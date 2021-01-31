# No Nonsense Notch Overlay Mod (N3O Mod)

This mod is for devices with a cutout camera in the display. Use the big beautiful display fully in landscape while respecting the cutout in portrait (no more clock behind camera)

__For android 11 only__, install on 10 at your own risk!

## What does it do

- Full screen apps on landscape
- It maintains the contents of your status bar in portrait respecting the cameras position

## Mod Presets

Presets for the following devices, but you can create a custom cutout for any device running AOSP based android 11. The presets below should work for most scenarios on other phones with a cutout on the left

- Oneplus 
  - 8 Pro QHD+ (cant get around the resolution change atm)
  - 8, 8 Pro FHD+, 8T 
- Google 
  - Pixel 5

## How to install
1. know how to recover device safely after failed magisk module!
2. install module via zip or magisk repo
3. select your presets
4. select if you want custom cutouts
5. reboot
5. go to settings and change `Display Cutout` from default to any of the `N3O` cutouts

## Customisation
- first installation will ask if you want custom files
- select yes if you wish to alter the cutout width OR if the presets above dont match your device and __DO NOT REBOOT__ (this just saves time)
- files will be located in `/sdcard/com.logmd.n3o/` use a file editor like "root explorer" or "es explorer" to edit them
  - for top left cutouts there are 2 files `custom1left.txt` and `custom2left.txt`
  - for top right cutouts there are 2 files named like above, but `right`
  - for center cutouts there is 1 file with `center` in its name, this is experimental and may not work
- only enter whole numbers e.g. 1, 3, 100.
- this number is in pixels
- reinstall the module then reboot :)

warning: Take care here, incorrect values can cause systemui failures, or worse bootloops. know how to get out of this BEFORE you try to install

## Compatibility

### Android 11
Should work on AOSP based android 11

### Android 10
HAS ISSUES!
- some bootloops/sysui crash (TRY AT YOUR OWN RISK)
- please test a backup method of removing magisk or restoring via adb before trying

# How does it work

Within each devices framework code, there are xml values for "drawing" the cutout location using svg draw paths.
now what i currently do is remove the camera cutout portion but leave a line of 1px at the top of the screen above the camera

e.g. for the 8T

```
M -407 68.5 A 34 34 0 0 1 -475 68.5 A 34 34 0 0 1 -407 68.5 Z M -475,0 L -407,0 Z M -540,0 L -540,102.5 Z
```

<img width="200" src="https://gist.githubusercontent.com/logmd/f60ee13ce55be71179b36106b0ccf2d1/raw/op8t-cutout.svg">

becomes

```
M -475 1 L -407 1 Z M -540 0 L -540 0 Z
```

<img width="200" src="https://gist.github.com/logmd/2ecc3ede43a7d3e318f4740c4a5f3c0c/raw/op8t-cutout-removed.svg">


#

i have simplified the above process but the gist is the same :)

# Credits

- <a href="https://github.com/Gnonymous7">Gnonymous7</a> for Script base and install logic
- <a href="https://github.com/Zackptg5">Zackptg5</a> for MMT-Ex template.
- <a href="https://github.com/topjohnwu">topjohnwu</a> for entire Magisk universe.
- <a href="https://github.com/skittles9823">skittles9823</a> for helping me.
- All the testers and xda for providing a platform to test on


