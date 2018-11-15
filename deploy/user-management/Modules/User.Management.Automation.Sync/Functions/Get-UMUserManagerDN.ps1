function Get-UMUserManagerDN{
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $hruser
    )

    #hardcoded - get from settings?
    if($null -ne $hruser.LEDER -and $hruser.LEDER -ne " "){
        $leder = $ADUserTable.Item($hruser.LEDER)
        if($leder){
            return $leder.DistinguishedName
        }
        else{
            return $null
        }
    }
    else{
        return $null
    }

}