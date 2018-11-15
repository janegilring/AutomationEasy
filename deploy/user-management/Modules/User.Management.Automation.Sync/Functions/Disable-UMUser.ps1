function Disable-UMUser{
    [cmdletbinding(SupportsShouldProcess=$True)]

    param(
        [Parameter(Mandatory=$true)]
        $aduser
    )

    If($PSCmdlet.ShouldProcess($hruser.$($settings.ObjectMapping.source))) {
        $whatif = $false
    }
    else{
        $whatif = $True
    }

        $Aduser | Disable-ADAccount -WhatIf:$whatif
        $Aduser | Move-ADObject -TargetPath $($settings.DisabledUsersOU) -WhatIf:$whatif

        if($aduser.mail){
            $Mailbox = Get-Mailbox $aduser.mail -ErrorAction silentlycontinue
            $RemoteMailbox = Get-RemoteMailbox $aduser.mail -ErrorAction silentlycontinue
        }

        #o365
        if($RemoteMailbox){
            Set-RemoteMailbox $aduser.mail -HiddenFromAddressListsEnabled $true -WhatIf:$whatif
        }

        #onprem
        if($Mailbox){
            Set-Mailbox $aduser.mail -HiddenFromAddressListsEnabled $true -WhatIf:$whatif
        }


    }