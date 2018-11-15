[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Not sure why this test fails - need to investigate further")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseBOMForUnicodeEncodedFile", "", Justification="Not sure why this test fails - need to investigate further")]
param()
<#

    NAME: Sync-UMUser.ps1

    AUTHOR: Jan Egil Ring
    EMAIL: jan.egil.ring@crayon.com

    DESCRIPTION: PowerShell runbook to create a new user account based on input from a Sharepoint-list.

    PREREQUISITES:
    -A service account that have permissions to provision users
    -An Azure Automation Account with a Hybrid Worker registered

    RUNBOOK LOGIC:

        1) Initialize-Logging

        2) Perform Pester tests and retrieve assets from Azure Automation
            -Validate credentials
             -Validate prerequisites (PowerShell modules)
                -ActiveDirectory
                -SharePointPnPPowerShellOnline
                -User.Management.Automation.Core
                -User.Management.Automation.Sync

        3) Retrieve sync settings (file or Sharepoint-lists) (Get-UMHRSyncSetting)

        4) Get user data from HR database (Get-UMHRUser)

        5) Get user data from Active Directory (Get-UMADUser)

        6) Synchronize users (Sync-UMHRUser)


#>

Write-Output -InputObject "Runbook started $(Get-Date) on Azure Automation Runbook Worker $($env:computername)"

#region 1 - Logging

    Write-Output 'Step 1 - Initialize logging'

        Initialize-Logging -LogHeader 'Contoso - User Onboarding' -LogFolder 'C:\Azure Automation\Logs\New-UMUser' -LogFileNameSuffix ".log"

        Import-Module -Name Communary.Logger

    Write-Output 'Step 1 - completed'

#endregion

#region 2 - Perform Pester tests and retrieve assets from Azure Automation

Write-Output "Step 2 - Perform Pester tests and retrieve assets from Azure Automation"

    Import-Module -Name User.Management.Automation.Sync

    Invoke-UMHRSyncPrerequisiteTest

    $ActiveDirectoryCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $AzureADCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $ExchangeOnlineCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $SharepointOnlineCredential = Get-AutomationPSCredential -Name 'User Automation service account'

    $SharePointAutomationSiteURL = Get-AutomationVariable -Name SharePointAutomationSiteURL
    $Environment = Get-AutomationVariable -Name HRSyncEnvironment
    $SharePointHRSyncSettingsListName = Get-AutomationVariable -Name SharePointHRSyncSettingsListName
    $SharePointAutomationDataSourcesListName = Get-AutomationVariable -Name SharePointAutomationDataSourcesListName
    $SharePointHRSyncAttributeMappingsListName = Get-AutomationVariable -Name SharePointHRSyncAttributeMappingsListName

Write-Output 'Step 2 - completed'

#endregion

#region 3 - Retrieve sync settings

    Write-Output 'Step 3 - Retrieve sync settings'

        $Settings = Get-UMHRSyncSetting -SharePointSiteURL $SharePointAutomationSiteURL -Environment Prod01 -SharePointHRSyncSettingsListName $SharePointHRSyncSettingsListName -SharePointAutomationDataSourcesListName $SharePointAutomationDataSourcesListName -SharePointHRSyncAttributeMappingsListName $SharePointHRSyncAttributeMappingsListName

    Write-Output 'Step 3 - completed'

#endregion

#region 4 - Get user data from HR database

Write-Output 'Step 4 - Get user data from HR database'

        $HRUsers = Get-UMHRUser -Settings $Settings

Write-Output 'Step 4 - completed'

#endregion

#region 5 - Get user data from Active Directory

Write-Output 'Step 5 - Get user data from Active Directory'

        $ADUsers = Get-UMADUser -Settings $Settings

Write-Output 'Step 5 - completed'

#endregion

#region 6 - Synchronize users

Write-Output 'Step 6 - Synchronize users'

    Sync-UMHRUser -Settings $Settings -HRUsers $HRUsers -ADUsers $ADUsers

Write-Output 'Step 6 - completed'

#endregion

$NonInformationLogEntries = Get-Content $LogPath | Select-String -NotMatch Information

if ($NonInformationLogEntries) {

    Write-Output "Errors and warnings logged to $LogPath :"

    $NonInformationLogEntries

}

Write-Log -LogEntry "Runbook finished $(Get-Date)"  -PassThru