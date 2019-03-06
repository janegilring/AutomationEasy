function Invoke-UMPrerequisiteTest {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="By design - used to track global status")]
    param()

    # Todo: Add Pester Operational Validation tests

    #region Test for Office 365 E3 license status

    Write-Log -LogEntry "Test for Azure AD Premium and Office 365 E3 license availability" -PassThru

    try {

        $AzureADCredential = Get-AutomationPSCredential -Name 'User Automation service account'

        Connect-MsolService -Credential $AzureADCredential -ErrorAction Stop

        $Office365E3SkuID = Get-AutomationVariable -Name Office365E3SkuID
        $Office365E3LicenseStatus = Get-MsolAccountSku -ErrorAction Stop | Where-Object AccountSkuId -eq $Office365E3SkuID

        $Office365E3LicensesAvailable = $Office365E3LicenseStatus.ActiveUnits - $Office365E3LicenseStatus.ConsumedUnits

        Write-Log -LogEntry "Number of Office 365 E3 licenses available: $Office365E3LicensesAvailable" -PassThru

        if ($Office365E3LicenseStatus.ConsumedUnits -ge $Office365E3LicenseStatus.ActiveUnits) {

            $global:WorkflowStatus = 'Completed'
            $global:Status = "User creation failed. Error message: Insufficient number of Office 365 licenses available"

            Write-Log -LogEntry $Status -PassThru

        } else {

            $global:WorkflowStatus = 'In progress'

        }

        $AzureADPremiumLicenseWarningThreshold = Get-AutomationVariable -Name AzureADPremiumLicenseWarningThreshold
        $Office365E3LicenseWarningThreshold = Get-AutomationVariable -Name Office365E3LicenseWarningThreshold


        $AzureADPremiumSkuID = Get-AutomationVariable -Name AzureADPremiumSkuID
        $AzureADPremiumLicenseStatus = Get-MsolAccountSku -ErrorAction Stop | Where-Object AccountSkuId -eq $AzureADPremiumSkuID
        $AzureADPremiumLicensesAvailable = $AzureADPremiumLicenseStatus.ActiveUnits - $AzureADPremiumLicenseStatus.ConsumedUnits

        Write-Log -LogEntry "Number of Azure AD Premium licenses available: $AzureADPremiumLicensesAvailable" -PassThru



    }

    catch {

        $global:WorkflowStatus = 'Completed'
        $global:Status = "User creation failed. Unable to verify number of Office 365 licenses available - aborting. Error message: $($_.Exception.Message)"

        Write-Log -LogEntry $Status -PassThru

    }

    #region Send warnings to Teams channel if warning thresholds is reached

    if ($Office365E3LicensesAvailable -le $Office365E3LicenseWarningThreshold) {

        Send-UMTeamsWarningNotification -Message "Number of Office 365 licenses available ($Office365E3LicensesAvailable) is below the defined threshold of $Office365E3LicenseWarningThreshold" -Color yellow

    }

    if ($AzureADPremiumLicensesAvailable -le $AzureADPremiumLicenseWarningThreshold) {

        Send-UMTeamsWarningNotification -Message "Number of Azure AD Premium licenses available ($AzureADPremiumLicensesAvailable) is below the defined threshold of $AzureADPremiumLicenseWarningThreshold" -Color yellow

    }

    #endregion

    #endregion

}