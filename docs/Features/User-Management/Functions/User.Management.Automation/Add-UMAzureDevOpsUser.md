---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Add-UMAzureDevOpsUser

## SYNOPSIS

Adds the user object in $UserData as a user in Azure DevOps.

## SYNTAX

```powershell
Add-UMAzureDevOpsUser [[-UserData] <Object>]
```

## DESCRIPTION

This function will add the ser object in $UserData as a user in Azure DevOps by leveraging the VSTeam PowerShell module.
The function is intended to be used from an automated process, hence the Azure DevOps AccessToken is dynamically retrieved from Azure Automation variables.

## EXAMPLES

### Example 1

```powershell
PS C:\> Add-UMAzureDevOpsUser -UserData $UserData
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
