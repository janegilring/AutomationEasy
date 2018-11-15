[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "By design - used in script intended for interactive use.")]
param (
    $RootSiteUrl = 'https://crayondemos.sharepoint.com',
    $NewSiteUrl = 'https://crayondemos.sharepoint.com/sites/ITAutomation/',
    $SiteTitle = 'IT Automation',
    $SiteDescription = 'Sharepoint lists for configuration-, meta- and staging data used in automated IT processes',
    $TemplatePath = "$PSScriptRoot\Templates\user_management_default_lists.xml"
)

<#

 NAME: New-SharepointAutomationSite.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to provision a new site in Sharepoint Online for configuration-, meta- and staging data used in automated IT processes
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

$SPOConnection = Connect-PnPOnline -Url $RootSiteUrl -UseWebLogin -ReturnConnection

$SiteParameters = @{
    Url = $SiteUrl
    Title = $SiteTitle
    Type = 'CommunicationSite'
    Description = $SiteDescription
    Connection = $SPOConnection
}

New-PnPSite @SiteParameters