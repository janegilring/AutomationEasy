---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Send-UMTeamsNotification

## SYNOPSIS

Sends a notification to a Microsoft Teams channel

## SYNTAX

```powershell
Send-UMTeamsNotification [[-UserData] <Object>] [[-DepartmentData] <Object>] [[-Title] <Object>]
 [[-Text] <Object>] [[-TargetURI] <Object>]
```

## DESCRIPTION

This function sends a notification to a Microsoft Teams channel.
-TargetURI should contain the URI to the Azure Automation runbook which provisions new users. The URI will be the target for a button in Microsoft Teams in order for the IT Operations team to easily access the runbook from the notification.

## EXAMPLES

### Example 1

```powershell
PS C:\> Send-UMTeamsNotification -UserData $UserData
```

$UserData is the output of New-UMUser.

## PARAMETERS

### -DepartmentData

The DepartmentData parameter expects the output that is created by the function Get-UMDepartmentData

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

### -TargetURI

Webhook URI for a Microsoft Teams channel

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text

Text for the message to be sent

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title

Title for the message to be sent

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
