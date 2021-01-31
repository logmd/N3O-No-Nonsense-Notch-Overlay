param (
    [switch]$release = $false
)

. _buildScripts\base36.ps1

$majorVersion = 1
$version = "$majorVersion"
$versionNo = 100
$date = Get-Date
$buildTime = (($date).ToString("HH-mm-ss"))
$buildDate = convertTo-Base36 ([decimal]($date).ToString("yyMMdd"))
$buildStamp = $buildDate
$buildNo = "$buildDate.$($buildTime)_EXP"
$magiskGit = './_release/N3O-No-Nonsense-Notch-Overlay-Release'

if ($release) {
    $vcodeFile = "$magiskGit\_vcode"
    [int]$i = Get-Content $vcodeFile
    $i++
    Set-Content $vcodeFile $i

    $versionNo = $i
    $buildNo = '{0:d3}' -f [int]$versionNo
    $buildNo = "$buildStamp.$buildNo"
}

$build = "N3O_v$version.$buildNo.zip"
$buildName = "N3O v$version revision $buildNo"
"building $buildName"

$modProp = "./src/module.prop"
copy-item -path module.prop.template -destination $modProp
((Get-Content -path $modProp -Raw) -replace '_version_', "$buildName") | Set-Content -Path $modProp
((Get-Content -path $modProp -Raw) -replace '_versioncode_', "$versionNo") | Set-Content -Path $modProp

if ($release) {
    $releasePath = "$magiskGit";
    copy-item -path ./src/* -destination $releasePath -recurse -Force
    copy-item -path ./README.md -destination $releasePath
    wsl 7z a _release/$build "$releasePath/*"
}
else {
    wsl 7z a _release/$build ./src/*
}
 
adb push _release/$build /sdcard/a_mods/$build

