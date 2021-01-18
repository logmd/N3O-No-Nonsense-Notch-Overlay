# No Nonsense Notch Overlay Mod (N3O Mod)

This mod is intended for oneplus devices with a holepunch cutout.

## What does it do

- It allows apps to span behind the camera in landscape
- It maintaining the contents of your status bar in portrait respecting the cameras position

## Mods

- Oneplus 8 Pro (cant get around the resolution change atm)
  - FHD
  - QHD
- Oneplus 8T

## Device Support

### android 11

- Oneplus 8
  - untested
  - may work with 8T Mod
- Oneplus 8 Pro
  - tested working on all variants
  - tested on 11.0.2.2
  - tested on 11.0.3.3
- Oneplus 8T
  - untested

### android 10

- some bootloops/sysui crash (TRY AT YOUR OWN RISK)
- please test a backup method of removing magisk or restoring via adb before trying

## How does it work

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

## Customisation

- create a file called `custom.txt`
- populate it with an svg path value like so `M 0 0 h 170 v 1 h -170 Z`
- put it on the sdcard in the location `/sdcard/com.logmd.n3o/custom.txt`
- install a build of `v0.1MD.APWH8` or above and it will create a cutout called __LOGMD N3O Custom__ in display cutout developer settings

### change custom value
- use a site like [svg path editor](https://yqnn.github.io/svg-path-editor/) and paste in `M 0 0 h 170 v 1 h -170 Z` to view and visually modify the cutout created.
- the values are alighned from the left top edge of the device
- the values `170` and `-170` must stay in sync and represent the number of pixels width of your "virtual" cutout.
- simply recreate the `custom.txt`file and reinstall the latest module and it should be updated after a reboot


## Credits

- <a href="https://github.com/Gnonymous7">Gnonymous7</a> for Script base and install logic
- <a href="https://github.com/Zackptg5">Zackptg5</a> for MMT-Ex template.
- <a href="https://github.com/topjohnwu">topjohnwu</a> for entire Magisk universe.
- <a href="https://github.com/skittles9823">skittles9823</a> for helping me.
- All the testers.
