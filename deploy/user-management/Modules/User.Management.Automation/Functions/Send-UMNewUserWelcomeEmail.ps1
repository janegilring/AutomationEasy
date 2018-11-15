function Send-UMNewUserWelcomeEmail {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $UserData,
        $DepartmentData,
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $ExchangeOnlineCredential = [System.Management.Automation.PSCredential]::Empty,
        $MailFrom = 'User Automation <userautomation@contoso.com>',
        $SmtpServer = 'smtp.office365.com',
        $SmtpPort = '587',
        $MailEncoding = 'Unicode'
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        Write-Log -LogEntry "Connecting to Exchange Online to wait for mailbox provisioning" -PassThru

        try {

            $ExchangeOnlineSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'https://outlook.office365.com/powershell-liveid/' -Credential $ExchangeOnlineCredential -Authentication Basic -AllowRedirection -ErrorAction Stop

            $null = Import-PSSession -Session $ExchangeOnlineSession -CommandName Get-Mailbox -ErrorAction Stop

        }

        catch {

            Write-Log -LogEntry "An error occured while connecting to Exchange Online: $($_.Exception.Message)" -LogType Error -PassThru

        }

        if ($ExchangeOnlineSession) {

            #Loop while waiting for Exchange provisioning
            $counter = 0
            Do {
                $finished = $false
                $ExchangeMailbox = Get-Mailbox -Identity $UserData.UserPrincipalName -ErrorAction Ignore
                if ($ExchangeMailbox) {
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

            Write-Log -LogEntry "Disconnecting from Exchange Online" -PassThru

            Remove-PSSession $ExchangeOnlineSession

            if ($ExchangeMailbox) {

                Write-Log -LogEntry 'Mailbox found - sending welcome e-mail' -PassThru

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
                $MailTemplate = $ListItems.FieldValues | Where-Object Title -eq 'New User - Welcome e-mail'
                $EmailHeader = $MailTemplate.Top_x0020_Content
                $EmailFooter = $MailTemplate.Bottom_x0020_Content
                $EmailSubject = $MailTemplate.Subject

                $HTMLBody = ConvertTo-HTML -Head $head -Body "$EmailHeader $EmailFooter"  | Out-String

                $MailParameters = @{
                    From        = $MailFrom
                    Subject     = $EmailSubject
                    SmtpServer  = $SmtpServer
                    Port        = $SmtpPort
                    Credential  = $ExchangeOnlineCredential
                    Encoding    = $MailEncoding
                    UseSsl      = $true
                    Body        = $HTMLBody
                    BodyAsHTML  = $true
                    ErrorAction = 'Stop'
                }

                $To = @()
                $To += $UserData.UserPrincipalName

                $MailParameters.Add('To', $To)
                $MailParameters.Add('Bcc', $($UserData.Manager))

                try {

                    Send-MailMessage @MailParameters

                }

                catch {

                    Write-Log -LogEntry "An error occured when trying to send e-mail notification to new user : $($_.Exception.Message)" -LogType Error -PassThru

                }

            } else {

                Write-Log -LogEntry "Mailbox $($UserData.UserPrincipalName) not found in Exchange Online, skipping welcome e-mail" -LogType Error -PassThru

            }

        } else {

            Write-Log -LogEntry "Unable to connect to Exchange Online - welcome e-mail not sent" -LogType Error -PassThru

        }

        $global:WorkflowStatus = 'In progress'

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}