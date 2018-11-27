---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Add-UMAzureADGroupBasedLicensingMember

## SYNOPSIS
Adds the user object in $UserData to pre-defined Azure AD Group Based licensing groups.

## SYNTAX

```
Add-UMAzureADGroupBasedLicensingMember [[-DepartmentData] <Object>] [[-UserData] <Object>]
```

## DESCRIPTION
This function will add the user object in $UserData to pre-defined Azure AD Group.
The function is intended to be used from an automated process, hence the Azure AD group IDs is dynamically retrieved from Azure Automation variables.

## EXAMPLES

### Example 1
```powershell
PS C:\> Add-UMAzureADGroupBasedLicensingMember -UserData $UserData
```

## PARAMETERS

### -DepartmentData
An object which is the output of Get-UMDepartmentData.

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

### -UserData
An object which is the output of New-UMUserData.

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

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
