---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Set-UMUserGroupMembership

## SYNOPSIS
Adds a user to groups in Azure and on-prem Active Directory based on values retrieved from the Sharepoint list containing metadata about each department in the company.

## SYNTAX

```
Set-UMUserGroupMembership [[-DepartmentData] <Object>] [[-UserData] <Object>]
```

## DESCRIPTION
This function adds a user to groups in Azure and on-prem Active Directory based on values retrieved from the Sharepoint list containing metadata about each department in the company.
The Sharepoint list is expected to have these two properties: ADGroups and AADGroups.

## EXAMPLES

### Example 1
```powershell
PS C:\> Set-UMUserGroupMembership -UserData $UserData -DepartmentData $DepartmentData
```

$UserData contains the output of New-UMUserData. $DepartmentData contains the output of Get-UMDepartmentData.

## PARAMETERS

### -DepartmentData
The DepartmentData parameter expects the output that is created by the function Get-UMDepartmentData

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
The UserData parameter expects the output that is created by the function New-UMUserData

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
