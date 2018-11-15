function Send-UMTeamsWarningNotification {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $UserData,
        $Message,
        $Color = 'red'
    )

    Import-Module -Name MSTeams

    $MSTeamsWebhookURL = Get-AutomationVariable -Name MSTeamsUserManagementWarningNotificationsWebhookURL

    $params = @{
        message    = $Message
        color      = $Color
        webhookuri = $MSTeamsWebhookURL
    }

    New-TeamsMessage @params

}