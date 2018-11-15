function Send-UMTeamsNotification {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $UserData,
        $DepartmentData,
        $Title = 'Contoso',
        $Text = 'User Onboarding',
        $TargetURI = 'https://portal.azure.com/#@contoso.com/resource/subscriptions/5a523ff1-eee9-4bc4-bec0-ea190c8ba333/resourceGroups/RG-Automation/providers/Microsoft.Automation/automationAccounts/Automation-Prod/runbooks/New-User/jobs'
    )

    Import-Module -Name MSTeams

    $MSTeamsWebhookURL = Get-AutomationVariable -Name MSTeamsUserManagementNotificationsWebhookURL

    switch ($Status) {

        'User creation completed' {$Color = 'green'}
        default {

            $Color = 'red'

            Send-MGTeamsWarningNotification -Message "An error occured in User Onboarding: $Status" -Color Red

        }

    }


    $Facts = @{}
    foreach ( $property in $UserData.psobject.properties.name ) {
        $Facts[$property] = $UserData.$property
    }

    $params = @{
        Title            = $Title
        Text             = $Text
        ActivityTitle    = "Onboarding status for user $($UserData.DisplayName)"
        ActivitySubtitle = "Status: $Status"
        Facts            = $Facts
        color            = $Color
        webhookuri       = $MSTeamsWebhookURL
    }

    New-TeamsMessage @params -Button {
        Button -ButtonType OpenURI -ButtonName 'Azure Automation Job' -TargetURI $TargetURI
    }

}