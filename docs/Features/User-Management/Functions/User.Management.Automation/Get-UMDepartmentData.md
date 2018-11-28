---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Get-UMDepartmentData

## SYNOPSIS
Builds a PowerShell custom object containing department data

## SYNTAX

```
Get-UMDepartmentData [[-SharePointSiteURL] <Object>] [[-SharePointDepartmentListName] <Object>]
 [[-CompanyName] <Object>] [[-DepartmentName] <Object>]
```

## DESCRIPTION
This function builds a PowerShell custom object containing department data based on the specified Sharepoint parameters

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-UMDepartmentData -SharePointSiteURL $SharePointAutomationSiteURL -SharePointDepartmentListName $SharePointDepartmentListName -CompanyName Contoso -DepartmentName HR
```

## PARAMETERS

### -CompanyName
The name of the company the department to retrieve data for is located

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

### -DepartmentName
The name of the department to retrieve metadata for

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

### -SharePointDepartmentListName
The name of the Sharepoint-list containing department metadata

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
The site URL to the Sharepoint-site hosting the Sharepoint-list containing department metadata

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
