[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "By design - used in script intended for interactive use.")]
param(
    $Name,
    $Location = 'West Europe',
    $ResourceGroupName,
    $Plan = 'Basic'
)
<#

 NAME: New-AzureAutomationAccount.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to provisioning a new Azure Automation account

 #>


 if (Get-Module -ListAvailable -Name Az.Automation) {

    Import-Module -Name Az.Automation

} else {

    Write-Warning "Missing prerequisite Az PowerShell module, exiting..."
    Write-Host "You may install the module from PowerShell Gallery using PowerShellGet: Install-Module -Name Az" -ForegroundColor Yellow

    break

}

#region Authenticate to Azure


Connect-AzAccount

$subscriptionId = (Get-AzSubscription | Out-GridView -Title 'Select an Azure subscription' -PassThru).SubscriptionId

Set-AzContext -SubscriptionId $subscriptionId

#endregion

#region Create Azure Automation account

    $AccountParameters = @{
        Name = $Name
        Location = $Location
        ResourceGroupName = $ResourceGroupName
        Plan = $Plan
    }

    New-AzAutomationAccount @AccountParameters

#endregion