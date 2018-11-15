---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Get-UMCompanyData

## SYNOPSIS
Builds a PowerShell custom object containing company data from metadata in a Sharepoint-list

## SYNTAX

```
Get-UMCompanyData [[-SharePointSiteURL] <Object>] [[-SharePointCompanyListName] <Object>]
 [[-CompanyName] <Object>]
```

## DESCRIPTION
This function builds a PowerShell custom object containing company data from metadata in a Sharepoint-list based on the specified Sharepoint parameters

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-UMCompanyData -SharePointSiteURL $SharePointAutomationSiteURL -SharePointCompanyListName $SharePointCompanyListName -CompanyName Contoso
```

## PARAMETERS

### -CompanyName
The name of the company to retrieve metadata from

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

### -SharePointCompanyListName
The name of the Sharepoint-list containing company metadata

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
The site URL to the Sharepoint-site hosting the Sharepoint-list containing company metadata

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
