. _buildScripts\base36.ps1
$version = "1.00"
$versionNo = 100
$date = Get-Date
$buildTime = convertTo-Base36 ([decimal]($date).ToString("ddHHmmss"))
$buildDate = convertTo-Base36 ([decimal]($date).ToString("yyMM"))
$buildNo = "$buildDate.$buildTime"
$build = "N3O_v$version.$buildNo.zip"
$buildName = "N3O v$version revision $buildNo"

"building $buildName"

$modProp = "./src/module.prop"
copy-item -path module.prop.template -destination $modProp
((Get-Content -path $modProp -Raw) -replace '_version_', "$buildName") | Set-Content -Path $modProp
((Get-Content -path $modProp -Raw) -replace '_versioncode_', "$versionNo") | Set-Content -Path $modProp

 wsl 7z a _release/$build ./src/*
 adb push _release/$build /sdcard/a_mods/$build