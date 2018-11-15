function Get-UMADUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    param (
        $Settings
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        #Getting all users from AD with mapping-attribute set.
        [array]$ADProperties = $Settings.AttributeMappings.target
        $ADProperties += $Settings.ObjectMapping.target

            try{
                Write-Log -LogEntry "Getting all users from AD with mapping-attribute set." -PassThru -LogType Information
                $Adusers = Get-ADUser -Properties $ADProperties -Filter "$($settings.ObjectMapping.target) -like '*'"
                Write-Log -LogEntry "Found $($Adusers.count) users." -PassThru -LogType Information
            }
            Catch{
                Write-Log -LogEntry "Failed to get users from AD" -PassThru -LogType Error
                throw $_.Exception
            }

        #connect to Exchange powershell
        Write-Log -LogEntry "Connect to Exchange powershell  - $($settings.ExchangeServer)" -PassThru
        try{
            Connect-UMExchange -serverfqdn $settings.ExchangeServer
        }
        catch{
            Write-Log -LogEntry "Failed connecting to Exchange" -PassThru -LogType Error
            throw $_.Exception
        }
        #making an hashtable from all ADusers to speed things up
        $ADUserTable = @{}
        $Adusers | ForEach-Object{
            $ADUserTable.Add($_.$($settings.ObjectMapping.target),$_)
        }

        $Adusers

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping Get-UMADUser' -LogType Warning

    }

}