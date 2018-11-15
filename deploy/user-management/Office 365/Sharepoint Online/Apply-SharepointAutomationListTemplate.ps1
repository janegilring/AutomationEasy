[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "By design - used in script intended for interactive use.")]
param (
    $SiteUrl = 'https://crayondemos.sharepoint.com/sites/ITAutomation/',
    $TemplatePath = "$PSScriptRoot\Templates\user_management_default_lists.xml"
)
<#

 NAME: Apply-SharepointAutomationListTemplate.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to provision default Sharepoint-lists from a provisioning template
          Requires SharePoint PnP PowerShell CmdLets: https://github.com/SharePoint/PnP-PowerShell


 VERSION HISTORY:
 1.0 31.10.2018 - Initial release

 #>


 if (Get-Module -ListAvailable -Name SharePointPnPPowerShellOnline) {

    Import-Module -Name SharePointPnPPowerShellOnline

} else {

    Write-Warning "Missing prerequisite SharePointPnPPowerShellOnline PowerShell module, exiting..."
    Write-Host "You may install the module from PowerShell Gallery using PowerShellGet: Install-Module -Name SharePointPnPPowerShellOnline" -ForegroundColor Yellow

    break

}

Connect-PnPOnline -Url $SiteUrl -UseWebLogin

Apply-PnPProvisioningTemplate -Handlers Lists -Path $TemplatePath