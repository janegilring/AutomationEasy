function Get-UMHRUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $Settings
    )

    if ($global:WorkflowStatus -eq 'In progress') {

            #Getting userdata from source
        #oracle supported - new will be added like csv, xml or sql
        if($Settings.HRDataSource.type -eq 'Oracle'){
            try{
                Write-Log -LogEntry "Getting users from Source Oracle.." -PassThru -LogType Information
                Get-UMOracleHRUser -conString $settings.HRDataSource.connectionstring -sqlString $settings.HRDataSource.Query
                Write-Log -LogEntry "Got $($hrusers.count) users from source." -PassThru
            }
            Catch{
                Write-Log -LogEntry "Failed to get users from source - abort" -PassThru -LogType Information
                throw $_.Exception
            }
        } elseif ($Settings.HRDataSource.type -eq 'CSV'){

            try{
                Write-Log -LogEntry "Getting users from Source CSV $($settings.HRDataSource.connectionstring)." -PassThru -LogType Information

                $Users = @(Import-Csv -Path $settings.HRDataSource.connectionstring -Encoding Default)

                if (-not ($Users)) {

                    $global:WorkflowStatus = 'Completed'

                    Write-Log -LogEntry "Got 0 users from source - abort" -PassThru -LogType Warning

                } else {

                  Write-Log -LogEntry "Got $($Users.count) users from source." -PassThru

                  $Users

            }
            }
            Catch{
                Write-Log -LogEntry "Failed to get users from source - abort" -PassThru -LogType Information
                throw $_.Exception
            }

        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping Get-UMHRUser' -LogType Warning

    }

}