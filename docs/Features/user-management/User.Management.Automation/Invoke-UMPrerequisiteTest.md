---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Invoke-UMPrerequisiteTest

## SYNOPSIS
Performs prerequisite tests to ensure a new user account can be provisioned

## SYNTAX

```
Invoke-UMPrerequisiteTest
```

## DESCRIPTION
This function performs prerequisite tests to ensure a new user account can be provisioned.
It will be converted to Pester tests, but initially manual tests is created to ensure a sufficient number of licenses is available in Azure AD and Office 365.
The IT Operations team will be notified via Microsoft Teams based on a defined threshold if there is a low number of licenses available.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-UMPrerequisiteTest
```

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
