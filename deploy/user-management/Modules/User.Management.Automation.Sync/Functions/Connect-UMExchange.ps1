function Connect-UMExchange{
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$serverfqdn
    )

    $uri = "http://" + $serverfqdn + "/powershell"

    try{
        $ExSession = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri $uri -Authentication Kerberos -AllowRedirection
        Import-PSSession $ExSession -AllowClobber
    }
    catch{
        Write-Error $_
    }

}