# Configuration parameters

*Template for documenting parameters used to configure an Azure Automation account*

## Azure subscriptions

| Tenant ID | Subscription ID | Subscription name |
|-----------|-----------------|-------------------|
|           |                 |                   |


## Azure resources

| Name | Resource Type | Resource Group | Subscription name |
|------|---------------|----------------|-------------------|
|      |     Automation Account          |                |                   |
|      |     Log Analytics workspace          |                |                   |

## Hybrid Runbook Workers

| Name | Operatingsystem | Memory | CPU cores | Operating system disk |
|------|-----------------|--------|-----------|-----------------------|
|      |                 |        |           |                       |
|      |                 |        |           |                       |
|      |                 |        |           |                       |

## Azure Automation variables

| Name | Type | Value | Description |
|------|------|-------|-------------|
|   SharepointAutomationSiteURL *(example)*   |   string   |    https://contoso.sharepoint.com/ITAutomation   |      Sharepoint-site used to store metadata used in automation processes       |
|      |      |       |             |
|      |      |       |             |

*The recommended approach is to store variables in source control and synchronize them to the Automation account using a Release Pipeline.*

## Azure Automation credentials

| Name | Username | Description |
|------|----------|-------------|
|   User Automation service account *(example)*   |    _svc.userautomation@contoso.com      |      Delegated admin in local AD, access to AAD Connect server, member of IT Automation Sharepoint list, Azure User Administrator directory role       |
|      |          |             |
|      |          |             |

*The recommended approach is to store credentials either directly in Azure Automation, or in a secret vault such as Azure Key Vault - making it possible to retrieve the secrets at runtime.*