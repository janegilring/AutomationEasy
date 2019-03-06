# Runbook: Update-AAModules

AUTHOR          : Automation Team  
CONTRIBUTOR     : Morten Lerudjordet, Joel Bennett  
Original URL    : [Runbook](https://github.com/azureautomation/runbooks/blob/master/Utility/ARM/Update-ModulesInAutomationToLatestVersion.ps1)  

.SYNOPSIS  
    This Azure/OMS Automation runbook imports the latest version on PowerShell Gallery of all modules in an
    Automation account.If a new module to import is specified, it will import that module from the PowerShell Gallery
    after all other modules are updated from the gallery.

.DESCRIPTION  
    This Azure/OMS Automation runbook imports the latest version on PowerShell Gallery of all modules in an
    Automation account. By connecting the runbook to an Automation schedule, you can ensure all modules in
    your Automation account stay up to date.
    If a new module to import is specified, it will import that module from the PowerShell Gallery
    after all other modules are updated from the gallery.

.PARAMETER ResourceGroupName  
    Optional. The name of the Azure Resource Group containing the Automation account to update all modules for.
    If a resource group is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.PARAMETER AutomationAccountName  
    Optional. The name of the Automation account to update all modules for.
    If an automation account is not specified, then it will use the current one for the automation account
    if it is run from the automation service

.PARAMETER NewModuleName  
    Optional. The name of a module in the PowerShell gallery to import after all existing modules are updated

.EXAMPLE  
    Update-AAModules -ResourceGroupName "MyResourceGroup" -AutomationAccountName "MyAutomationAccount" -NewModuleName "AzureRM.Batch"
