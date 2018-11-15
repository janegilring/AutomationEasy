function Invoke-UMAzureADSynchronization {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param()

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            Invoke-Command -ComputerName $AzureADConnectServer -ScriptBlock {

                do {

                    $SyncCycleInProgress = (Get-ADSyncScheduler).SyncCycleInProgress

                    Write-Output 'Sync already in progress - waiting for scheduler to be finished before initiating new sync'
                    Start-Sleep 10

                }
                until (

                    $SyncCycleInProgress -ne $true

                )

                Start-ADSyncSyncCycle -PolicyType Initial

            } -Credential $AzureADConnectServerCredential -ErrorAction Stop

            Write-Log -LogEntry "Successfully triggered synchronization on Azure AD Connect Server $AzureADConnectServer" -PassThru

            Write-Log -LogEntry "Sleeping for 1 minute to allow user synchronization to complete" -PassThru

            Start-Sleep -Seconds 60

            $global:WorkflowStatus = 'In progress'

        }

        catch {

            Write-Log -LogEntry "An error occured when trying to trigger synchronization on Azure AD Connect Server $AzureADConnectServer : $($_.Exception.Message)" -LogType Error -PassThru

            $global:WorkflowStatus = 'In progress'

        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}