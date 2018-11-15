---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Send-UMTeamsWarningNotification

## SYNOPSIS
Sends a warning notification to a Microsoft Teams channel

## SYNTAX

```
Send-UMTeamsWarningNotification [[-UserData] <Object>] [[-Message] <Object>] [[-Color] <Object>]
```

## DESCRIPTION
This function sends a notification to a Microsoft Teams channel.
The function is intended to be used from an automated process, hence the webhook URL is dynamically retrieved from Azure Automation variables in a parent runbook.

## EXAMPLES

### Example 1
```powershell
PS C:\> Send-UMTeamsNotification -Message 'User creation failed. Error message: Insufficient number of Office 365 licenses available'
```


## PARAMETERS

### -Color
Color for the text to be sent

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

### -Message
Text for the message to be sent

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

### -UserData
The UserData parameter expects the output that is created by the function New-UMUserData

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

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
