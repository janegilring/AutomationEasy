function Send-UMNewUserEmailNotification {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $UserData,
        $DepartmentData,
        $MailFrom = 'User Automation <userautomation@contoso.com>',
        $SmtpServer ='smtp.office365.com',
        $SmtpPort = '587',
        $MailEncoding = 'Unicode'
    )

    if ($global:WorkflowStatus -eq 'In progress') {

    $UserData | Add-Member -MemberType NoteProperty -Name 'Initial password' -Value $InitialPassword

    # Useful for debugging
    # $UserData | Export-Clixml -Path ($LogPath.Replace('log','xml'))

    $head = @'

    <style>

    body { background-color:#FDFEFE;

           font-family:Tahoma;

           font-size:12pt; }

    td, th { border:1px solid black;

             border-collapse:collapse; }

    th { color:white;

         background-color:black; }

    table, tr, td, th { padding: 2px; margin: 0px }

    table { margin-left:50px; }

    </style>

'@

    $ListItems = Get-PnPListItem -List $SharePointAutomationEmailContentListName
    $MailTemplate = $ListItems.FieldValues | Where-Object Title -eq 'New User - Notification to requester'
    $EmailHeader = $MailTemplate.Top_x0020_Content -replace 'status:',"status: $Status"
    $EmailFooter = $MailTemplate.Bottom_x0020_Content
    $EmailSubject = $MailTemplate.Subject + " - $($UserData.DisplayName)"

    if ($Status -eq 'User creation completed') {

        $HTMLUserData = $UserData | ConvertTo-Html -As LIST -Fragment | Out-String

    }

    $HTMLBody = ConvertTo-HTML -Head $head -Body "$EmailHeader $HTMLUserData $EmailFooter" | Out-String

        $MailParameters = @{
            From       = $MailFrom
            Subject    = $EmailSubject
            SmtpServer = $SmtpServer
            Port       = $SmtpPort
            Credential = $ExchangeOnlineCredential
            Encoding    = $MailEncoding
            UseSsl     = $true
            Body        = $HTMLBody
            BodyAsHTML  = $true
            Attachments = $LogPath
            ErrorAction = 'Stop'
        }

        $To = @()
        $To += $UserData.Manager

        if ($UserData.Manager -ne $UserData.Requester) {

            $To += $UserData.Requester

        }

        $MailParameters.Add('To', $To)

        try {

            Send-MailMessage @MailParameters

        }

        catch {

            Write-Log -LogEntry "An error occured when trying to send e-mail notification to requester : $($_.Exception.Message)" -LogType Error -PassThru

        }

        $global:WorkflowStatus = 'In progress'

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}