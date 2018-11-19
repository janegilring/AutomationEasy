function Add-UMAzureDevOpsUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $UserData
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            #$null = Add-VSTeamAccount -Account $AzureDevOpsAccountName -PersonalAccessToken $AzureDevOpsAccessToken -ErrorAction Stop
            $AzureDevOpsConnection = $true

        }

        catch {

            Write-Log -LogEntry "An error occured when trying to connect to Azure DevOps (formerly VS TS) : $($_.Exception.Message)" -LogType Error -PassThru

        }

        <#
            Disable logic until adding users with MSDN license is possible, issue added here:
            https://github.com/DarqueWarrior/vsteam/issues/106
        #>
        Write-Log -LogEntry 'Command Add-MGAzureDevOpsUser not implemented yet'
        $AzureDevOpsConnection = $false


        if ($AzureDevOpsConnection) {

            $UserPrincipalName = $UserData.UserPrincipalName

            $AzureDevOpsUser = Get-VSTeamuser | Where-Object Email -eq $UserPrincipalName

            if (-not ($AzureDevOpsUser)) {


                try {

                    $AzureDevOpsNewUserRequest = Add-VSTeamUser -Email $UserPrincipalName -License None -ErrorAction Stop

                    if ($AzureDevOpsNewUserRequest.operationResult.isSuccess) {

                        Write-Log -LogEntry "Successfully added user $UserPrincipalName to Azure DevOps (formerly VS TS)"

                    } else {

                        throw $AzureDevOpsNewUserRequest.operationResult.errors.value

                    }

                }

                catch {

                    Write-Log -LogEntry "An error occured when trying to add user to Azure DevOps (formerly VS TS) : $($_.Exception.Message)" -LogType Error -PassThru

                }

            } else {

                Write-Log -LogEntry "Skipped adding user $UserPrincipalName to Azure DevOps (formerly VS TS): User already exists"

            }


        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}