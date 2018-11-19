function Enable-UMAzureADMultifactorAuthentication {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $UserData
    )

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE

    #>

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            $null = Connect-MsolService -Credential $AzureADCredential -ErrorAction Stop
            $MsolServiceConnected = $true

        }

        catch {

            Write-Log -LogEntry "An error occured when trying to connect to Azure AD for adding user to Azure AD Group Based Licensing groups : $($_.Exception.Message)" -LogType Error -PassThru

        }


        if ($MsolServiceConnected) {

            Write-Log -LogEntry 'Verify that Azure AD Connect has syncronized new user to Azure AD'

            $UserPrincipalName = $UserData.UserPrincipalName

            #Loop while waiting for Azure AD Connect to syncronize new user to Azure AD
            $counter = 0
            Do {
                $finished = $false
                $MsolUser = Get-MsolUser -UserPrincipalName $UserPrincipalName -ErrorAction SilentlyContinue
                if ($MsolUser) {
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

            if ($MsolUser.Count -eq 1) {

                Write-Log -LogEntry 'Sleep for 5 minutes to avoid the error "Unable to update parameter" due to sync/timing issue'
                Start-Sleep -Seconds 300

                Write-Log -LogEntry 'Enabling AzureAD Multifactor Authentication' -PassThru

                try {

                    # Create the StrongAuthenticationRequirement object
                    $StrongAuthenticationRequirement = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                    $StrongAuthenticationRequirement.RelyingParty = '*'
                    $MFA = @($StrongAuthenticationRequirement)

                    $MsolUser | Set-MsolUser -StrongAuthenticationRequirements $MFA -ErrorAction Stop

                }

                catch {

                    Write-Log -LogEntry "An error occured while enabling AzureAD Multifactor Authentication: $($_.Exception.Message)" -LogType Error -PassThru

                }
            }

        }

        $global:WorkflowStatus = 'Completed'

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}