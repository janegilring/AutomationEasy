function Get-UMDepartmentData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $SharePointSiteURL,
        $SharePointDepartmentListName,
        $CompanyName,
        $DepartmentName
    )

    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE

    #>

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            Connect-PnPOnline -Url $SharePointSiteURL -Credentials $SharepointOnlineCredential -ErrorAction Stop

            $DepartmentSourceData = (Get-PnPListItem -List  $SharePointDepartmentListName -ErrorAction Stop |
                    Where-Object {
                    $PSItem.FieldValues.Title -eq $DepartmentName -and
                    $PSItem.FieldValues.Company.LookupValue -eq $CompanyName
                }).FieldValues

            $ADGroups = $DepartmentSourceData.ADGroups -split "`n"
            $ADGroups = $ADGroups | Where-Object {$PSItem.Length -ne 0}

            $AADGroups = $DepartmentSourceData.AADGroups -split "`n"
            $AADGroups = $AADGroups | Where-Object {$PSItem.Length -ne 0}

            [pscustomobject]@{
                Name               = $DepartmentSourceData.Title
                UserDirectory      = $DepartmentSourceData.UserDirectory
                OUPath             = $DepartmentSourceData.OUPath
                OnboardingApproval = $DepartmentSourceData.OnboardingApproval
                Approver           = $DepartmentSourceData.Approver.Email
                Applications       = $DepartmentSourceData.Applications
                ADGroups           = $ADGroups
                AADGroups          = $AADGroups
            }

            $global:WorkflowStatus = 'In progress'
            $global:Status = "List item for department $CompanyName found in Sharepoint list $SharePointDepartmentListName"

            Write-Log -LogEntry $Status

        }

        catch {

            $global:WorkflowStatus = 'Completed'
            $global:Status = "List item for department $CompanyName not found in Sharepoint list $SharePointDepartmentListName - aborting. Error message: $($_.Exception.Message)"

            Write-Log -LogEntry $Status -LogType Error

        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}