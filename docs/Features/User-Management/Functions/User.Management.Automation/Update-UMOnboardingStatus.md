---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Update-UMOnboardingStatus

## SYNOPSIS

Updates the WorkflowStatus or the Status fields for a given list item in a given Sharepoint list

## SYNTAX

```powershell
Update-UMOnboardingStatus [[-SharePointSiteURL] <String>] [[-SharePointListName] <String>]
 [[-SharepointListItemID] <String>] [[-WorkflowStatus] <String>] [[-Status] <String>]
 [[-SPOCredential] <PSCredential>]
```

## DESCRIPTION

This function updates the WorkflowStatus or the Status fields for a given list item in a given Sharepoint list.
The function is used to track status during automated user management tasks.
The function is intended to be used from an automated process, hence credentials and URLs is dynamically retrieved from Azure Automation variables in a parent runbook.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-UMOnboardingStatus -SharePointSiteURL $SharePointAutomationSiteURL -SharePointListName $SharePointOnboardingListName -SharepointListItemID $SharepointListNewEmployeeId -WorkflowStatus $WorkflowStatus -Status $Status -SPOCredential $SharepointOnlineCredential
```

## PARAMETERS

### -SPOCredential

Credential for Sharepoint Online

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharePointListName

Name of the Sharepoint-list

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharePointSiteURL

The site URL to the Sharepoint-site hosting the Sharepoint-list to update status fields in

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharepointListItemID

Item ID for the item to update status fields in

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status

String containing the new value for the Status field

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WorkflowStatus

String containing the new value for the WorkflowStatus field

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
