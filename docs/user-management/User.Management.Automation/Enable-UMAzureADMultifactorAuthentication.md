---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Enable-UMAzureADMultifactorAuthentication

## SYNOPSIS
Enables Azure AD Multifactor Authentication

## SYNTAX

```
Enable-UMAzureADMultifactorAuthentication [[-UserData] <Object>]
```

## DESCRIPTION
This function enables Azure AD Multifactor Authentication for the user object in $UserData.
The function is intended to be used from an automated process, hence the  Azure AD Credential is dynamically retrieved from Azure Automation variables.

## EXAMPLES

### Example 1
```powershell
PS C:\> Enable-UMAzureADMultifactorAuthentication -UserData $UserData
```


## PARAMETERS

### -UserData
An object which is the output of New-UMUserData.

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
