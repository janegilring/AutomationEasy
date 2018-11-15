Function Format-AsName
{

PARAM ([string]$String)

    $TextInfo = (Get-Culture).TextInfo
    $TextInfo.ToTitleCase($string.ToLower())

}