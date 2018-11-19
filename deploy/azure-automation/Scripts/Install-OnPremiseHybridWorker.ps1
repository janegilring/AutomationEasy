[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "By design - used in script intended for interactive use.")]
param()

<#

 NAME: Install-OnPremiseHybridWorker.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to configure a Windows Server (2012 R2 or later) as an Azure Automation Hybrid Runbook Worker

 #>

 if (Get-Module -ListAvailable -Name Az) {

    Import-Module -Name Az


} else {

    Write-Warning "Missing prerequisite Az PowerShell module, exiting..."
    Write-Host "You may install the module from PowerShell Gallery using PowerShellGet: Install-Module -Name Az" -ForegroundColor Yellow

    break

}

#region Install and configure Azure Automation Hybrid Runbook Worker

    Install-Script -Name New-OnPremiseHybridWorker

    $AutomationAccountResourceGroup = 'RG-Infrastructure-Automation'
    $AutomationAccountName = 'Infrastructure-Automation'
    $HybridGroupName = $env:COMPUTERNAME
    $OMSWorkspaceName = 'Infrastructure-Automation'
    $OMSResourceGroupName = 'RG-Infrastructure-Automation'
    $SubscriptionId = 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'

    .\New-OnPremiseHybridWorker.ps1 -AutomationAccountName $AutomationAccountName -AAResourceGroupName $AutomationAccountResourceGroup `
    -OMSResourceGroupName $OMSResourceGroupName -HybridGroupName $HybridGroupName `
    -SubscriptionId $SubscriptionId -WorkspaceName $OMSWorkspaceName

#endregion

#region Enable Automation account logging to Log Analytics - makes it possible to create alerts (e-mail, webhook, etc) for runbook failures.

    # Find the ResourceId for the Automation Account
    $AutomationAccountId = (Get-AzResource -ResourceType "Microsoft.Automation/automationAccounts" | Out-GridView -PassThru).Id

    # Find the ResourceId for the Log Analytics workspace
    $WorkspaceId = (Get-AzResource -ResourceType "Microsoft.OperationalInsights/workspaces" | Out-GridView -PassThru).Id

    Set-AzDiagnosticSetting -ResourceId $automationAccountId -WorkspaceId $workspaceId -Enabled $true

    Get-AzDiagnosticSetting -ResourceId $automationAccountId

#endregion