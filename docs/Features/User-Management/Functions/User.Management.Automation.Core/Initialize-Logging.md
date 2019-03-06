---
external help file: User.Management.Automation.Core-help.xml
Module Name: User.Management.Automation.Core
online version:
schema: 2.0.0
---

# Initialize-Logging

## SYNOPSIS

{{Initializes logging based on the Communary.Logger PowerShell module}}

## SYNTAX

```powershell
Initialize-Logging [[-LogHeader] <Object>] [[-LogFolder] <Object>] [[-LogFileNameSuffix] <Object>]
 [[-Culture] <Object>]
```

## DESCRIPTION

{{This function will initialize logging for the running script based on the Communary.Logger PowerShell module.}}

## EXAMPLES

### Example 1

```powershell
PS C:\> {{Initialize-Logging -LogFolder C:\Logs -Culture en-US}}
```

{{Will initialize logging to the C:\Logs folder and ensure culture is set to en-US}}

## PARAMETERS

### -Culture

{{Culture string (for example "en-US"}}

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

### -LogFileNameSuffix

{{Suffix for the filename - for example "_onboarding"}}

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

### -LogFolder

{{Path to the folder the log generated log file will be created in}}

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

### -LogHeader

{{Header in the generated log file}}

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
