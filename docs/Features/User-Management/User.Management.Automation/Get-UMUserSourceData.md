---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Get-UMUserSourceData

## SYNOPSIS
Retrieves source data for creating a new user object from a Sharepoint-list

## SYNTAX

```
Get-UMUserSourceData [[-SharePointSiteURL] <Object>] [[-SharePointOnboardingListName] <Object>]
 [[-SharepointListNewEmployeeId] <Object>]
```

## DESCRIPTION
This function retrieves source data for creating a new user object from a Sharepoint list

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-UMUserSourceData -SharePointSiteURL $SharePointAutomationSiteURL -SharePointOnboardingListName $SharePointOnboardingListName -SharepointListNewEmployeeId $SharepointListNewEmployeeId
```

## PARAMETERS

### -SharePointOnboardingListName
The name of the Sharepoint-list containing staging data for new user objects. The Sharepoint list is typically populated from a PowerApp where managers requests users for new employees.

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

### -SharePointSiteURL
The site URL to the Sharepoint-site hosting the Sharepoint-list containing staging data for new users

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

### -SharepointListNewEmployeeId
The Sharepoint list item ID for the user to retrieve data for

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

## RELATED LINKS
