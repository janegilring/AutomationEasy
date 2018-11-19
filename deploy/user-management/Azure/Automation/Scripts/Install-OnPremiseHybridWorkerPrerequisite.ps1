<#

 NAME: Install-OnPremiseHybridWorkerPrerequisite.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to manually install prerequsites for User Management Automation on an Azure Automation Hybrid Runbook Worker

 #>

#region Install required modules from PowerShell Gallery

    Install-Module -Name Az # Azure Resource Manager
    Install-Module -Name AzureAD # Azure Active Directory
    Install-Module -Name MSOnline # Legacy Azure Active Directory module, required for enabling MFA
    Install-Module -Name Communary.Logger # Logging module
    Install-Module -Name SharePointPnPPowerShellOnline # Sharepoint module
    Install-Module -Name User.Management.Automation.Core # Requires an internal module repository to be registered (Register-PSRepository). Alternative methods: Manual or automated via release pipeline.
    Install-Module -Name User.Management.Automation # Requires an internal module repository to be registered (Register-PSRepository). Alternative methods: Manual or automated via release pipeline.

#endregion

#region Install required RSAT Tools

    Install-WindowsFeature -Name RSAT-AD-Tools

#endregion