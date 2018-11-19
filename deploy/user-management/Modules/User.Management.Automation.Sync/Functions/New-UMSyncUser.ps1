function New-UMSyncUser{
    [cmdletbinding(SupportsShouldProcess=$True)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification="By design - initial passwords generated in clear text")]
    param(
        [Parameter(Mandatory=$true)]
        $hruser
    )

    If($PSCmdlet.ShouldProcess($hruser.$($settings.ObjectMapping.source))) {
        $whatif = $false
    }
    else{
        $whatif = $True
    }

    $DC = (Get-ADDomainController).name
    $password = New-UMPassword

    $OU = $settings.NewUsersOU
    $365MailDomain = $settings.Exchangeonlinedomain

    $params = @{}
    $params.Add('Server', $dc)
    $params.Add('AccountPassword',(ConvertTo-SecureString $password -AsPlainText -Force))
    $params.Add('ChangePasswordAtLogon',$false)
    $params.Add('Enabled',$true)
    $params.Add('Path',$ou)
    $params.Add('Company',"Customercompany")

    $settings.AttributeMappings + $settings.ObjectMapping | ForEach-Object{
        if($_.target -like 'name'){
            $params.Add('Name', $hruser.$($_.source))
        }
        if($_.target -like 'samaccountname'){
            $params.Add('SamAccountName',$hruser.$($_.source))
        }
        if($_.target -like 'mobile'){
            $params.Add('MobilePhone',$hruser.$($_.source))
        }
        if($_.target -like 'GivenName'){
            $params.Add('GivenName',$hruser.$($_.source))
        }
        if($_.target -like 'sn'){
            $params.Add('Surname',$hruser.$($_.source))
        }
        if($_.target -like 'DisplayName'){
            $params.Add('DisplayName',$hruser.$($_.source))
        }
        if($_.target -like 'EmployeeID'){
            $params.Add('EmployeeID',$hruser.$($_.source))
        }
        if($_.target -like 'EmployeeNumber'){
            $params.Add('EmployeeNumber',$hruser.$($_.source))
        }
        if($_.target -like 'Department'){
            $params.Add('Department',$hruser.$($_.source))
        }
        if($_.target -like 'Manager'){
            $params.Add('Manager', (Get-UMUserManagerDN -hruser $hruser))
        }
        if($_.target -like 'mail'){
            $params.Add('EmailAddress', $hruser.$($_.source))
        }
        if($_.target -like 'title'){
            $params.Add('title', $hruser.$($_.source))
        }
        if($_.target -like 'Description'){
            $params.Add('Description', $hruser.$($_.source))
        }
    }


        New-ADUser @params -WhatIf:$whatif


    if($whatif -eq $false){
        Enable-RemoteMailbox -Identity $($params.SamAccountName) -RemoteRoutingAddress $($params.SamAccountName + "@" + $365MailDomain) -DomainController $DC -ErrorAction stop -WhatIf:$whatif

        $smtp = (Get-RemoteMailbox -Identity $($params.SamAccountName) -DomainController $dc).primarysmtpaddress

        if($smtp){
            Set-ADUser -Identity $($params.SamAccountName) -UserPrincipalName $smtp -Server $DC -WhatIf:$whatif
        }

    }
        $hruser | Add-Member -Name Passord -Value $password -MemberType NoteProperty -Force

        Send-UMNewUserMail -NewUser $hruser -WhatIf:$whatif -Subject "New user created in AD"

}
