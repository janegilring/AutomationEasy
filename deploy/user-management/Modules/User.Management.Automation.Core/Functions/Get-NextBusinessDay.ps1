function Get-NextBusinessDay {
    param (

        $Hour = 0,
        $Minute = 0,
        $Second = 0


    )

    $Date = (@(1..4) | ForEach-Object { if (([datetime]::Now.AddDays($_)).DayOfWeek -ne "Sunday" -and ([datetime]::Now.AddDays($_)).DayOfWeek -ne "Saturday") {[datetime]::Now.AddDays($_); }})[0]

    Get-Date -Date $Date -Hour $Hour -Minute $Minute -Second $Second

}