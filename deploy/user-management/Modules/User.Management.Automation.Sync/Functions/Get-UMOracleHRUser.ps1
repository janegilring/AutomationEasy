function Get-UMOracleHRUser{
    #Oracle client must be installed and tnsnames.ora must be configured.
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_ -match '\bdata source\b'})]
        [string]$conString,
        [ValidateScript({$_ -match '\bselect\b'})]
        [Parameter(Mandatory=$true)]
        [string]$sqlString
    )
    begin {
        $resultSet=@()
    }
    process {
        try{
            Write-Verbose ("Connection String: {0}" -f $conString)
            Write-Verbose ("SQL Command: `r`n {0}" -f $sqlString)
            Add-Type -Path C:\app\client\product\12.2.0\client_1\ODP.NET\managed\common\Oracle.ManagedDataAccess.dll #todo - get dynamiccaly
            $con=New-Object Oracle.ManagedDataAccess.Client.OracleConnection($conString)
            $cmd=$con.CreateCommand()
            $cmd.CommandText=$sqlString

            $da=New-Object Oracle.ManagedDataAccess.Client.OracleDataAdapter($cmd);

            $resultSet=New-Object System.Data.DataTable

            [void]$da.fill($resultSet)
        }catch{
            Write-Error($_.Exception.ToString())
        }finally{
            if($con.State-eq'Open'){$con.close()}
        }
    }
    end {
        $resultSet
    }

}
