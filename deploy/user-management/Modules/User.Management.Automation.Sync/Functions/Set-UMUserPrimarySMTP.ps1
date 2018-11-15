function Set-UMUserPrimarySMTP{
    [cmdletbinding(SupportsShouldProcess=$True)]

    param(
        [Parameter(Mandatory=$false)]
        [string]$oldsmtp,
        [Parameter(Mandatory=$true)]
        [string]$newsmtp,
        [Parameter(Mandatory=$false)]
        [string]$aduser
    )

    If($PSCmdlet.ShouldProcess("$newsmtp")) {
        $whatif = $false
    }
    else{
        $whatif = $True
    }

    if($oldsmtp){
        $Mailbox = Get-Mailbox $oldsmtp -ErrorAction silentlycontinue
        $RemoteMailbox = Get-RemoteMailbox $oldsmtp -ErrorAction silentlycontinue

        #o365
        if($RemoteMailbox){
            Set-RemoteMailbox $oldsmtp -PrimarySmtpAddress $newsmtp -UserPrincipalName $newsmtp -EmailAddressPolicyEnabled $false -WhatIf:$whatif
            Set-RemoteMailbox $newsmtp -EmailAddresses @{add=$oldsmtp} -WhatIf:$whatif
        }

        #onprem
        if($Mailbox){
            Set-Mailbox $oldsmtp -PrimarySmtpAddress $newsmtp -UserPrincipalName $newsmtp -EmailAddressPolicyEnabled $false -WhatIf:$whatif
            Set-Mailbox $newsmtp -EmailAddresses @{add=$oldsmtp} -WhatIf:$whatif
        }

    }
    else{
        #user doesn't have mail in AD. Do something or notify someone..
    }


}