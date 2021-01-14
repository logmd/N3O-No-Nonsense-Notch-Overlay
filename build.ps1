$version = (Get-Date).ToString("yyMMdd__HH-mm-ss");
wsl rm "module.version.*.ps1"
wsl touch "module.version.$version.ps1"
wsl ./build.sh $version
adb push ../g_$version.zip /sdcard/a_mods/g_$version.zip
# Start-Sleep -s 3
# adb shell su -c magisk --install-module /sdcard/a_mods/g_$version.zip
# Start-Sleep -s 5
# adb reboot