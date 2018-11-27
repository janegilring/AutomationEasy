---
external help file: User.Management.Automation.Core-help.xml
Module Name: User.Management.Automation.Core
online version:
schema: 2.0.0
---

# Get-NextBusinessDay

## SYNOPSIS
Returns the next business day.

## SYNTAX

```
Get-NextBusinessDay [[-Hour] <Object>] [[-Minute] <Object>] [[-Second] <Object>]
```

## DESCRIPTION
This function will return a date/time object containing the next business day (skips Saturday/Sunday).

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-NextBusinessDay
```

Will return the next business day

### Example 2
```powershell
PS C:\> Get-NextBusinessDay -Hour 9 -Minute 0 -Seconds 0
```

Will return the next business day at 9 AM

## PARAMETERS

### -Hour
The "hour" value for the datetime object to be returned

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Minute
The "minute" value for the datetime object to be returned

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Second
The "second" value for the datetime object to be returned

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES
Source for code/logic: https://stackoverflow.com/questions/1018873/powershell-golf-next-business-day

## RELATED LINKS
