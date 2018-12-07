---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Invoke-UMAzureADSynchronization

## SYNOPSIS

Triggers Azure AD synchronization.

## SYNTAX

```powershell
Invoke-UMAzureADSynchronization
```

## DESCRIPTION

This function connects to an Azure AD Connect servers to trigger Azure AD synchronization.
The function is intended to be used from an automated process, hence the credentials and server name is dynamically retrieved from Azure Automation variables in a parent runbook.
If an existing synchronization is already running, the function will wait for it to finish before triggering a new synchronization.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-UMAzureADSynchronization
```

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
