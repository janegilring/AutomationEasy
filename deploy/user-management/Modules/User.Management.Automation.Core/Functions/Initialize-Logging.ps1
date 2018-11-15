function Initialize-Logging {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification = "By design")]
    param (

        $LogHeader = "Log file created $(Get-Date)",
        $LogFolder = 'C:\Azure Automation\Logs\New-User',
        $LogFileNameSuffix = ".log",
        $Culture = 'nb-NO'

    )

    if ($Culture) {

        # Configuring user culture
        if ((Get-Culture).Name -ne 'nb-NO') {

            $null = Set-Culture -CultureInfo 'nb-NO'

            Write-Output "Culture not set to Norwegian - changing"

        }

    }

    Write-Output -InputObject 'Setting up file logging...'

    if (!(Test-Path -Path $LogFolder)) {

        $null = mkdir $LogFolder

    }

    try {

        Import-Module -Name 'Communary.Logger' -ErrorAction Stop

        $global:LogPath = Join-Path -Path $LogFolder -ChildPath ($((Get-Date).tostring('yyyyMMdd-hhmmss')) + $LogFileNameSuffix)

        if (-not (Test-Path -Path $LogPath)) {

            New-Log -Path $LogPath -Header $logHeaderString -UseGlobalVariable -ErrorAction Stop

        }

        else {

            New-Log -Path $LogPath -Header $logHeaderString -Append -UseGlobalVariable -ErrorAction Stop

        }

        Write-Output -InputObject "File-logging started, logging to $($LogPath)"


    }

    catch {

        Write-Output -InputObject "Setting up logging failed. Verify that the required PowerShell module (Communary.Logger) for logging is installed and that $($env:username) has write permissions to log file $($settingsobject.LogPath) on computer $($env:computername) , aborting..."

        Write-Error -Message "Setting up logging failed. Verify that the required PowerShell module (Communary.Logger) for logging is installed and that $($env:username) has write permissions to log file $($settingsobject.LogPath) on computer $($env:computername) , aborting..."

        throw $_.Exception

        break

    }

}