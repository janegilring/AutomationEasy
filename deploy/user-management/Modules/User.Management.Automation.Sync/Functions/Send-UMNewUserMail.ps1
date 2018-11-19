function Send-UMNewUserMail{

    [cmdletbinding(SupportsShouldProcess=$True)]


    param(
        [Parameter(Mandatory=$true)]
        $NewUser,
        [Parameter(Mandatory=$true)]
        [string]$Subject
    )

    $smtpserver = $settings.smtpserver
    $from = $settings.smtpfrom
    $To = $settings.smtpto

    $body = $NewUser | Out-String


    If($PSCmdlet.ShouldProcess("..")) {
        try{
            Send-MailMessage -SmtpServer $smtpserver -Subject $subject -To $To -Body $body -From $from -Encoding default
        }
        catch{
            Write-Log -LogEntry "Failed to send e-mail notification to $To - $($_.Exception.Message)" -PassThru -LogType Error
        }
    }
    else{
        #Send-MailMessage -SmtpServer $smtpserver -Subject $subject -To $To -Body $body -From $from -Encoding default
    }


}
