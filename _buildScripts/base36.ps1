# https://stackoverflow.com/a/48942964
function convertTo-Base36
{
    [CmdletBinding()]
    param (
        [parameter(valuefrompipeline=$true, HelpMessage="Integer number to convert")]
        [uint64]$DecimalNumber=""
    )

    $alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    do
    {
        $remainder = ($DecimalNumber % 36)
        $char = $alphabet.Substring($remainder, 1)
        $base36Num = "$char$base36Num"
        $DecimalNumber = ($DecimalNumber - $remainder) / 36
    }
    while ($DecimalNumber -gt 0)

    $base36Num
}