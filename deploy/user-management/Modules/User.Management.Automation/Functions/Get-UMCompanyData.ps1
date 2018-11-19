function Get-UMCompanyData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $SharePointSiteURL,
        $SharePointCompanyListName,
        $CompanyName
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            Connect-PnPOnline -Url $SharePointSiteURL -Credentials $SharepointOnlineCredential -ErrorAction Stop

            $CompanySourceData = (Get-PnPListItem -List  $SharePointCompanyListName -ErrorAction Stop |
                    Where-Object {$PSItem.FieldValues.Title -eq $CompanyName}).FieldValues

            [pscustomobject]@{
                Name                = $CompanySourceData.Title
                Country             = $CompanySourceData.Country
                Domain              = $CompanySourceData.Domain
                CompanyAbbriviation = $CompanySourceData.Company_x0020_abbriviation
                CountryAbbriviation = $CompanySourceData.Country_x0020_abbriviation
                CountryCode         = $CompanySourceData.Country_x0020_code
                City                = $CompanySourceData.City
                StreetAddress       = $CompanySourceData.StreetAddress
                PostalCode          = $CompanySourceData.PostalCode
                RegNumber           = $CompanySourceData.CompanyRegNumber
                CEO                 = $CompanySourceData.CEO
            }

            $global:WorkflowStatus = 'In progress'

        }

        catch {

            $global:WorkflowStatus = 'Completed'
            $global:Status = "List item for company $CompanyName not found in Sharepoint list $SharePointCompanyListName - aborting. Error message: $($_.Exception.Message)"

            Write-Log -LogEntry $Status -LogType Error

        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}