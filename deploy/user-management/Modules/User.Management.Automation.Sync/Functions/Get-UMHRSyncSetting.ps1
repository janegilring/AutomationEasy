function Get-UMHRSyncSetting {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $SharePointSiteURL,
        $SharePointHRSyncSettingsListName,
        $SharePointAutomationDataSourcesListName,
        $SharePointHRSyncAttributeMappingsListName,
        $Environment
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        try {

            Connect-PnPOnline -Url $SharePointSiteURL -Credentials $SharepointOnlineCredential -ErrorAction Stop

            $HRSyncSettingsSourceData = (Get-PnPListItem -List $SharePointHRSyncSettingsListName -ErrorAction Stop |
                    Where-Object {$PSItem.FieldValues.Environment -eq $Environment}).FieldValues

            $AutomationDataSourcesSourceData = (Get-PnPListItem -List $SharePointAutomationDataSourcesListName -ErrorAction Stop |
                    Where-Object {$PSItem.FieldValues.Environment -eq $Environment}).FieldValues

            $AttributeMappings = @()

            $HRSyncAttributeMappingsSourceData = (Get-PnPListItem -List $SharePointHRSyncAttributeMappingsListName -ErrorAction Stop).FieldValues

            $ObjectMappings = $HRSyncAttributeMappingsSourceData | Where-Object ObjectMapping -eq $true | Select-Object -First 1

            $ObjectMappings = [pscustomobject]@{
                Source = $ObjectMappings.Title
                Target = $ObjectMappings.Target
            }

            $HRSyncAttributeMappings = $HRSyncAttributeMappingsSourceData | Where-Object ObjectMapping -eq $false

            foreach ($HRSyncAttributeMapping in $HRSyncAttributeMappings) {

                $AttributeMappings += [pscustomobject]@{
                    Source = $HRSyncAttributeMapping.Title
                    Target = $HRSyncAttributeMapping.Target
                    Type = $HRSyncAttributeMapping.AttributeType
                    Rule = $HRSyncAttributeMapping.Rule
                    IgnoreEmpty = $HRSyncAttributeMapping.IgnoreEmpty
                }

            }

            $HRDataSource = [pscustomobject]@{
                Type = $AutomationDataSourcesSourceData.Title
                ConnectionString = $AutomationDataSourcesSourceData.ConnectionString
                Query = $AutomationDataSourcesSourceData.Query
            }

            [pscustomobject]@{
                Environment           = $HRSyncSettingsSourceData.Environment
                LogType               = $HRSyncSettingsSourceData.LogType
                LogPath               = $HRSyncSettingsSourceData.LogPath
                VerboseLogging        = $HRSyncSettingsSourceData.VerboseLogging
                ExchangeServer        = $HRSyncSettingsSourceData.ExchangeServer
                Exchangeonlinedomain  = $HRSyncSettingsSourceData.Exchangeonlinedomain
                Smtpserver  = $HRSyncSettingsSourceData.Smtpserver
                SmtpFrom  = $HRSyncSettingsSourceData.SmtpFrom
                SmtpTo  = $HRSyncSettingsSourceData.SmtpTo
                WhatIf  = $HRSyncSettingsSourceData.WhatIf
                Actions  = $HRSyncSettingsSourceData.Actions
                SoftMapping  = $HRSyncSettingsSourceData.SoftMapping
                DisabledUsersOU  = $HRSyncSettingsSourceData.DisabledUsersOU
                NewUsersOU  = $HRSyncSettingsSourceData.NewUsersOU
                AttributeMappings = $AttributeMappings
                ObjectMapping = $ObjectMappings
                HRDataSource = $HRDataSource
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