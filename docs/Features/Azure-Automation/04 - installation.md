# Installation

## Azure Automation account

### Manual

Step-by-step instructions for creating an Azure Automation account via the Azure Portal is available [here](https://docs.microsoft.com/en-us/azure/automation/automation-quickstart-create-account#create-automation-account).

### Scripted

The [New-AzureAutomationAccount.ps1](https://github.com/CrayonAS/AutomationEasy/blob/master/deploy/azure-automation/Scripts/New-AzureAutomationAccount.ps1) script can be used to script the creation of an Azure Automation account.
<!-- markdownlint-disable MD024 -->

### Azure Resource Manager Template

<!-- markdownlint-disable MD036 -->
*Coming*
<!-- markdownlint-enable MD036 -->

## Log Analytics workspace

### Manual

Step-by-step instructions for creating a Log Analytics workspace via the Azure Portal is available [here](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-quick-create-workspace?toc=/azure/azure-monitor/toc.json#create-a-workspace).

### Scripted

<!-- markdownlint-disable MD036 -->
*Coming*
<!-- markdownlint-enable MD036 -->

### Azure Resource Manager Template

<!-- markdownlint-disable MD036 -->
*Coming*
<!-- markdownlint-enable MD036 -->

## Hybrid Runbook Worker

### Manual

Step-by-step instructions for installing and configuring a Hybrid Runbook Worker is available [here](https://docs.microsoft.com/en-us/azure/automation/automation-windows-hrw-install#manual-deployment).

### Scripted

The [Install-OnPremiseHybridWorker.ps1](https://github.com/CrayonAS/AutomationEasy/blob/master/deploy/azure-automation/Scripts/Install-OnPremiseHybridWorker.ps1) script can be used to script the configuration of a Hybrid Runbook Worker.

<!-- markdownlint-disable MD036 -->
*Coming*
<!-- markdownlint-enable MD036 -->

### PowerShell Desired State Configuration

<!-- markdownlint-disable MD036 -->
*Coming*
<!-- markdownlint-enable MD036 -->

## Locks

Since the Azure Automation account and Log Analytics workspace might host critical services for automation in the environment, a recommended practice is to implement a CanNotDelete lock on the Azure resources to prevent accidental deletion.

More information is available [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-lock-resources).
<!-- markdownlint-enable MD024 -->