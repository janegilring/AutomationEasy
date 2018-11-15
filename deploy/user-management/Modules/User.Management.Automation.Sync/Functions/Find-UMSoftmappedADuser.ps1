function Find-UMSoftmappedADuser{
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $hruser
    )

    $u = Get-ADUser -Properties mail,employeenumber -Filter "samaccountname -like '$($hruser.BRUKERNAVN)'"

    if($u -and $hruser.e_post -like $u.mail){
        return $u
    }
    else{
        return $null
    }

}