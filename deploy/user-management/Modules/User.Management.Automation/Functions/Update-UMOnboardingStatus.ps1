function Update-UMOnboardingStatus {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="By design - function is not intended for interactive use - hence ShouldProsess is not of any value")]
    Param(
        [string]$SharePointSiteURL,
        [string]$SharePointListName,
        [string]$SharepointListItemID,
        [string]$WorkflowStatus,
        [string]$Status,
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SPOCredential = [System.Management.Automation.PSCredential]::Empty
    )

    try {

        Import-Module -Name SharePointPnPPowerShellOnline -ErrorAction Stop -WarningAction SilentlyContinue -Verbose:$false


    }

    catch {

        Write-Output 'Prerequisites not installed (SharePointPnPPowerShellOnline PowerShell module not installed'

        break

    }


    try {

        Connect-PnPOnline -Url $SharePointSiteURL -Credentials $SPOCredential

    }

    catch {

        Write-Output "Failed to connect to Sharepoint Online: $($_.Exception.Message)"

        break

    }

    $StatusData = @{
    }

    if ($Status) {

        $StatusData.Add('Status', $Status)

    }

    if ($WorkflowStatus) {

        $StatusData.Add('Workflow_x0020_Status', $WorkflowStatus)

    }


    try {

        $null = Set-PnPListItem -List $SharePointListName -Identity $SharepointListItemID -Values $StatusData -ContentType Item -ErrorAction Stop

        Write-Log -LogEntry "Successfully updated onboarding status in Sharepoint list $SharePointListName" -PassThru

    }

    catch {

        Write-Log -LogEntry "Failed to update onboarding status in Sharepoint list $SharePointListName : $($_.Exception.Message)" -LogType Error -PassThru

    }

}