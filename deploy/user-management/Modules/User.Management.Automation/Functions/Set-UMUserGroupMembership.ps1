function Set-UMUserGroupMembership {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="By design - function is not intended for interactive use - hence ShouldProsess is not of any value")]
    param (
        $DepartmentData,
        $UserData
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        $UserPrincipalName = $UserData.UserPrincipalName

        #region Azure AD Groups

        try {

            $AzureADConnection = Connect-AzureAD -Credential $AzureADCredential -ErrorAction Stop

        }

        catch {

            Write-Log -LogEntry "An error occured when trying to connect to Azure AD for adding user to Azure AD Groups: $($_.Exception.Message)" -LogType Error -PassThru

        }

        if ($AzureADConnection) {

            $AzureADGroups = Get-AzureADGroup -All $true
            $AzureADUser = Get-AzureADUser -Filter "userprincipalname eq '$UserPrincipalName'"

            if ($AzureADUser.Count -eq 1) {

                $AADGroups = @()
                $AADGroups += $DepartmentData.AADGroups

                foreach ($AzureADGroupName in $AADGroups) {

                    Write-Log -LogEntry "Adding user to Azure AD group $AzureADGroupName" -PassThru

                    try {

                        $AzureADGroup = $AzureADGroups.Where{$PSItem.DisplayName -eq $AzureADGroupName}
                        $AzureADGroupCount = $AzureADGroup.Count

                        if ($AzureADGroupCount -eq 1) {

                            $null = Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -RefObjectId $AzureADUser.ObjectId -ErrorAction Stop

                        } else {

                            Write-Log -LogEntry "Adding user to Azure AD group $ADGroupName skipped - found $AzureADGroupCount groups with this name, should be 1" -PassThru -LogType Warning

                        }

                    }

                    catch {

                        Write-Log -LogEntry "An error occured while adding user to Azure AD group $AzureADGroupName : $($_.Exception.Message)" -LogType Error -PassThru

                    }

                }

            }

        }

        #endregion

        #region AD Groups


        $ADUser = Get-ADUser -Filter 'userprincipalname -eq $UserPrincipalName'

        if (@($ADUser).Count) {

            $ADGroups = @()
            $ADGroups += $DepartmentData.ADGroups

            foreach ($ADGroupName in $ADGroups) {

                Write-Log -LogEntry "Adding user to AD group $ADGroupName" -PassThru

                try {

                    $ADGroup = Get-ADGroup -Filter 'Name -eq $ADGroupName'
                    $ADGroupCount = ($ADGroup | Measure-Object).Count

                    if ($ADGroupCount -eq 1) {

                        Add-ADGroupMember -Identity $ADGroup -Members $ADUser -Credential $ActiveDirectoryCredential -ErrorAction Stop

                    } else {

                        Write-Log -LogEntry "Adding user to AD group $ADGroupName skipped - found $ADGroupCount groups with this name, should be 1" -PassThru -LogType Warning

                    }

                }

                catch {

                    Write-Log -LogEntry "An error occured while adding user to AD group $ADGroupName : $($_.Exception.Message)" -LogType Error -PassThru

                }

            }

        }

        #endregion

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}