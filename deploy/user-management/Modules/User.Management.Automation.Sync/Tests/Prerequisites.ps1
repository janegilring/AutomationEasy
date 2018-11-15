Describe 'Prerequisites' {

    It 'Active DirectoryPowerShell Module' {
        Get-Module -Name 'ActiveDirectory' -ListAvailable | Should Not BeNullOrEmpty
    }

    It 'User.Management.Automation.Core Module' {
        Get-Module -Name 'User.Management.Automation.Core' -ListAvailable | Should Not BeNullOrEmpty
    }

    It 'User.Management.Automation.Sync' {
        Get-Module -Name 'User.Management.Automation.Sync' -ListAvailable | Should Not BeNullOrEmpty
    }

    It 'Communary.Logger PowerShell Module' {
        Get-Module -Name 'Communary.Logger' -ListAvailable | Should Not BeNullOrEmpty
    }

    It 'PowerShell version' {
        $PSVersionTable.PSVersion.Major | Should BeGreaterThan 4
    }

}