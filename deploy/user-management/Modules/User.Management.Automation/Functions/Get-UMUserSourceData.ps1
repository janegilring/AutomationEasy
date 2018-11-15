function Get-UMUserSourceData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $SharePointSiteURL,
        $SharePointOnboardingListName,
        $SharepointListNewEmployeeId
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            Connect-PnPOnline -Url $SharePointSiteURL -Credentials $SharepointOnlineCredential -ErrorAction Stop

            $NewUserSourceData = Get-PnPListItem -List  $SharePointOnboardingListName -Id $SharepointListNewEmployeeId -ErrorAction Stop

            $NewUserSourceData.FieldValues

            $global:WorkflowStatus = 'In progress'
            $global:Status = "User object with Id $SharepointListNewEmployeeId found in Sharepoint list $SharePointOnboardingListName"

            if (Get-Command -Name Write-Log -ErrorAction SilentlyContinue) {

                Write-Log -LogEntry $Status

            }

        }

        catch {

            $global:WorkflowStatus = 'Completed'
            $global:Status = "User object with Id $SharepointListNewEmployeeId not found in Sharepoint list $SharePointOnboardingListName - aborting. Error message: $($_.Exception.Message)"

            if (Get-Command -Name Write-Log -ErrorAction SilentlyContinue) {

                Write-Log -LogEntry $Status

            }

        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}