# Operations

## Backup

An Azure Automation Hybrid Worker does not typically contain any data, and is considered stateless. The exception might be a runbook storing data locally, but that is not considered a best practice.
Hence, a backup of the worker servers might not be needed. However, if there is a desire to restore the service in a short amount of time, a VM backup might be considered.

## Monitoring

Typical measurements such as CPU, memory and disk usage is recommended for the worker servers.

In addition, it is recommended to configure monitoring of failed runbook jobs. The procedure to configure this is available in the article [Forward job status and job streams from Automation to Log Analytics](https://docs.microsoft.com/en-us/azure/automation/automation-manage-send-joblogs-log-analytics).

## Source control

While it is possible to edit runbooks and variables manually in the Azure portal, the recommended approach in an enterprise environment is to store runbooks in source control and configure a Release Pipeline to publish runbooks to an Azure Automation account after a set of pre-defined tests has passed. This makes it possible to keep track of changes, and also enhances the overall quality with regards to the requirement to pass the company`s set of pre-defined tests.

For those using Azure DevOps, a sample [azure-pipelines.yml](https://github.com/CrayonAS/AutomationEasy/blob/master/deploy/user-management/Azure/DevOps/azure-pipelines.yml) file is available in Automation Easy.

The [Sync-Runbooks.ps1](https://github.com/CrayonAS/AutomationEasy/blob/master/deploy/user-management/Azure/DevOps/Sync-Runbooks.ps1) script can be leveraged either locally or in any Continous Integration/Continous Delivery service to perform the actual synchronization of runbooks from a repository.