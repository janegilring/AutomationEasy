Param(
    [string]$SharePointSiteURL = 'https://crayondemos.sharepoint.com/ITAutomation',
    [string]$SharePointOnboardingListName = 'User Onboarding',
    [string]$SharePointCompanyListName = 'Company',
    [string]$SharePointAutomationEmailContentListName = 'Email Content',
    [string]$SharepointListNewEmployeeId
)

<#

    NAME: New-User.ps1

    AUTHOR: Jan Egil Ring
    EMAIL: jan.egil.ring@crayon.com

    DESCRIPTION: PowerShell runbook to create a new user account based on input from a Sharepoint-list.

    PREREQUISITES:
    -A custom SharePoint list
    -A service account that have permissions to the SharePoint list that will be used to write back status and information
    -A service account that have permissions to provision users
    -An Azure Automation Account with a Hybrid Worker registered

    RUNBOOK LOGIC:

        1) Initialize-Logging

        2) Perform Pester tests and retrieve assets from Azure Automation
            -Validate credentials
            -Validate available Office 365 E3 licences based on threshold and notify Teams channel if below threshold
            -Validate prerequisites (PowerShell modules)
                -ActiveDirectory
                -SharePointPnPPowerShellOnline
                -User.Management.Automation.Core
                -User.Management.Automation

        3) Get user data from Sharepoint list

        4) Get company, department and team data from Sharepoint lists

        5) Build user object with calculated properties (username 3+3, password, etc)

        6) Create user in AD (on-prem or Azure AD, based on department settings)

        7) Add Exchange alias: firstname.middlename.lastname@companydomain.com

        8) Trigger Azure AD Connect Sync

        9) Add user to internal systems
            -VS TS/Azure DevOps

        10) Add user to Azure AD / AD groups

        11) Send notification to Teams channel IT Ops User Automation

        12) Send notification to requester

        13) Send welcome e-mail to new user

        14) Configure Azure AD properties
             -Enforce Multifactor Authentication

        15 Update status in Sharepoint-list

#>

Write-Output -InputObject "Runbook started $(Get-Date) on Azure Automation Runbook Worker $($env:computername)"

#region 1 - Logging

    Write-Output 'Step 1 - Initialize logging'

        Initialize-Logging -LogHeader 'Contoso - User Onboarding' -LogFolder 'C:\Azure Automation\Logs\New-UMUser' -LogFileNameSuffix "_id_$($SharepointListNewEmployeeId).log"

        Import-Module -Name Communary.Logger

    Write-Output 'Step 1 - completed'

#endregion

#region 2 - Perform Pester tests and retrieve assets from Azure Automation

Write-Output "Step 2 - Perform Pester tests and retrieve assets from Azure Automation"

    Invoke-UMPrerequisiteTest

    $ActiveDirectoryCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $AzureADCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $AzureADConnectServerCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $ExchangeOnlineCredential = Get-AutomationPSCredential -Name 'User Automation service account'
    $SharepointOnlineCredential = Get-AutomationPSCredential -Name 'User Automation service account'

    $AzureADConnectServer = Get-AutomationVariable -Name AzureADConnectServer
    $AzureDevOpsAccountName = Get-AutomationVariable -Name AzureDevOpsAccountName
    $AzureDevOpsAccessToken = Get-AutomationVariable -Name AzureDevOpsAccessToken
    $SharePointAutomationSiteURL = Get-AutomationVariable -Name SharePointAutomationSiteURL
    $SharePointDepartmentListName = Get-AutomationVariable -Name SharePointDepartmentListName
    $SharePointCompanyListName = Get-AutomationVariable -Name SharePointCompanyListName
    $SharePointAutomationEmailContentListName = Get-AutomationVariable -Name SharePointAutomationEmailContentListName

Write-Output 'Step 2 - completed'

#endregion

#region 3 - Get user data from Sharepoint list

    Write-Output 'Step 3 - Get user data from Sharepoint list'

        $UserSourceData = Get-UMUserSourceData -SharePointSiteURL $SharePointAutomationSiteURL -SharePointOnboardingListName $SharePointOnboardingListName -SharepointListNewEmployeeId $SharepointListNewEmployeeId

    Write-Output 'Step 3 - completed'

#endregion

#region 4 - Get company, department and team data from Sharepoint lists

    Write-Output 'Step 4 - Get company, department and team data from Sharepoint lists'

        $CompanyData = Get-UMCompanyData -SharePointSiteURL $SharePointAutomationSiteURL -SharePointCompanyListName $SharePointCompanyListName -CompanyName $UserSourceData.Company.LookupValue
        $DepartmentData = Get-UMDepartmentData -SharePointSiteURL $SharePointAutomationSiteURL -SharePointDepartmentListName $SharePointDepartmentListName -CompanyName $UserSourceData.Company.LookupValue -DepartmentName $UserSourceData.Department.LookupValue

        Write-Output 'Company data:'
        $CompanyData

        Write-Output 'Department data:'
        $DepartmentData

    Write-Output 'Step 4 - completed'

#endregion

#region 5 - Build user object with calculated properties

    Write-Output 'Step 5 - Build user object with calculated properties'

        $UserData = New-UMUserData -SourceData $UserSourceData

        Write-Output 'User data:'
        $UserData

    Write-Output 'Step 5 - completed'

#endregion

#region 6 Create user in AD

    Write-Output 'Step 6 - Create user in AD'

        $ADUser = New-UMUser -UserData $UserData -DepartmentData $DepartmentData -CompanyData $CompanyData

        Write-Output 'AD user:'
        $ADUser

    Write-Output 'Step 6 - completed'

#endregion

#region 7 Add Exchange alias

    Write-Output 'Step 7 Add Exchange alias'

        Add-UMUserExchangeAlias -UserData $UserData -DepartmentData $DepartmentData

    Write-Output 'Step 7 - completed'

#endregion

#region 8 Trigger Azure AD Connect Sync

    Write-Output 'Step 8 Trigger Azure AD Connect Sync'

        Invoke-UMAzureADSynchronization

    Write-Output 'Step 8 - completed'

#endregion

#region 9 Add user to internal systems

    Write-Output 'Step 9 Add user to internal systems'

    # VS TS/Azure DevOps
    if ($DepartmentData.Applications -contains 'Azure DevOps') {

        Add-UMAzureDevOpsUser -UserData $UserData -DepartmentData $DepartmentData

    }

    # Azure AD Licensing Groups
    if ($DepartmentData.Applications -contains 'Microsoft 365 Business' -or $DepartmentData.Applications -contains 'Office 365 E3' -or $DepartmentData.Applications -contains 'Azure Active Directory Premium P1') {

        Add-UMAzureADGroupBasedLicensingMember -UserData $UserData -DepartmentData $DepartmentData

    }

    Write-Output 'Step 9 - completed'

#endregion

#endregion

#region 10 Add user to Azure AD / AD groups

    Write-Output '10 Add user to Azure AD / AD groups'

        Set-UMUserGroupMembership -UserData $UserData -DepartmentData $DepartmentData

    Write-Output 'Step 10 - completed'

#endregion

#region 11 Send notification to Teams channel IT Ops User Automation

    Write-Output 'Step 11 Send notification to Teams channel IT Ops User Automation'

        Send-UMTeamsNotification -UserData $UserData

    Write-Output 'Step 11 - completed'

#endregion

#region 12 Send notification to requester

    Write-Output 'Step 12 Send notification to requester'

         Send-UMNewUserEmailNotification -UserData $UserData

    Write-Output 'Step 12 - completed'

#endregion

#region 13 Send welcome e-mail to new user

    Write-Output 'Step 13 Send welcome e-mail to new user'

         Send-UMNewUserWelcomeEmail -UserData $UserData -ExchangeOnlineCredential $ExchangeOnlineCredential

    Write-Output 'Step 13 - completed'

#endregion

#region 14 Configure Azure AD properties

    Write-Output 'Step 14 Configure Azure AD properties'

         Write-Output 'Enforce Multifactor Authentication'

         Enable-UMAzureADMultifactorAuthentication -UserData $UserData

    Write-Output 'Step 14 - completed'

#region 15 Update status in Sharepoint-list

    Write-Output 'Step 15 Update status in Sharepoint-list'

         Update-UMOnboardingStatus -SharePointSiteURL $SharePointAutomationSiteURL -SharePointListName $SharePointOnboardingListName -SharepointListItemID $SharepointListNewEmployeeId -WorkflowStatus $WorkflowStatus -Status $Status -SPOCredential $SharepointOnlineCredential

    Write-Output 'Step 15 - completed'

#endregion


$NonInformationLogEntries = Get-Content $LogPath | Select-String -NotMatch Information

if ($NonInformationLogEntries) {

    Write-Output "Errors and warnings logged to $LogPath :"

    $NonInformationLogEntries

}

Write-Log -LogEntry "Runbook finished $(Get-Date)"  -PassThru