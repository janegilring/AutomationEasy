function Add-UMAzureADGroupBasedLicensingMember {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification = "By design - used to track workflow status")]
    param (
        $DepartmentData,
        $UserData
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            $AzureADConnection = Connect-AzureAD -Credential $AzureADCredential -ErrorAction Stop

        }

        catch {

            Write-Log -LogEntry "An error occured when trying to connect to Azure AD for adding user to Azure AD Group Based Licensing groups : $($_.Exception.Message)" -LogType Error -PassThru

        }

        if ($AzureADConnection) {

            Write-Log -LogEntry 'Waiting for Azure AD Connect to syncronize new user to Azure AD' -PassThru

            $UserPrincipalName = $UserData.UserPrincipalName

            #Loop while waiting for Azure AD Connect to syncronize new user to Azure AD
            $counter = 0
            Do {
                $finished = $false
                $AzureADUser = Get-AzureADUser -Filter "userprincipalname eq '$UserPrincipalName'"
                if ($AzureADUser) {
                    $Finished = $true
                }


                if (($counter -lt 10) -and ($counter -gt 0)) {
                    Start-Sleep -Seconds 30
                } Else {
                    Start-Sleep -Seconds 60
                }

                if ($counter -gt 30) {

                    $Finished = $true

                }

                $counter ++
                Write-Log -LogEntry "Wait loop: $counter" -PassThru

            }
            until ($finished -eq $true)


            if ($AzureADUser) {

                Write-Log -LogEntry 'Adding user to Azure AD group GBL Azure Active Directory Premium P1' -PassThru

                try {

                    $AzureADGroupID = Get-AutomationVariable -Name GBL_AzureAD_P1 -ErrorAction Stop
                    $AzureADGroup = Get-AzureADGroup -ObjectId $AzureADGroupID -ErrorAction Stop
                    $null = Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -RefObjectId $AzureADUser.ObjectId -ErrorAction Stop

                }

                catch {

                    Write-Log -LogEntry "An error occured while adding user to Azure AD group GBL Azure Active Directory Premium P1: $($_.Exception.Message)" -LogType Error -PassThru

                }

                Write-Log -LogEntry 'Adding user to Azure AD group GBL Office 365 E3' -PassThru

                try {

                    $AzureADGroupID = Get-AutomationVariable -Name GBL_Office365_E3 -ErrorAction Stop
                    $AzureADGroup = Get-AzureADGroup -ObjectId $AzureADGroupID -ErrorAction Stop
                    $null = Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -RefObjectId $AzureADUser.ObjectId -ErrorAction Stop

                }

                catch {

                    Write-Log -LogEntry "An error occured while adding user to Azure AD group GBL Office 365 E3: $($_.Exception.Message)" -LogType Error -PassThru

                }

                Write-Log -LogEntry 'Adding user to Azure AD group GBL Microsoft 365 Business' -PassThru

                try {

                    $AzureADGroupID = Get-AutomationVariable -Name GBL_Microsoft365_Business -ErrorAction Stop
                    $AzureADGroup = Get-AzureADGroup -ObjectId $AzureADGroupID -ErrorAction Stop
                    $null = Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -RefObjectId $AzureADUser.ObjectId -ErrorAction Stop

                }

                catch {

                    Write-Log -LogEntry "An error occured while adding user to Azure AD group GBL Microsoft 365 Business: $($_.Exception.Message)" -LogType Error -PassThru

                }

            } else {

                Write-Log -LogEntry 'User not added to Azure AD Group Based Licensing groups' -PassThru

            }

        }

        $global:WorkflowStatus = 'In progress'

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}