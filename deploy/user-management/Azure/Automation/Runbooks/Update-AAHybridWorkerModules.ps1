<#
NAME:       Update-AAHybridWorkerModules
AUTHOR:     Morten Lerudjordet
EMAIL:      morten.lerudjordet@rewired.no

DESCRITPION:
            This runbook will check installed modules in AA account and attempt to download these from PSGallery to the hybrid workers
            It will also update independend modules installed from PSGallery to latest version.

            Note:
                All manually uploaded modules to AA will not be handled by this runbooks, and should be handled by other means

PREREQUISITES:
            AAresourceGroupName             = Name of resourcegroup Azure Automation resides in
            AAaccountName                   = Name of Azure Automation account
            AAhybridWorkerGroupName         = Name of Azure Automation hybrid worker group
            AAhybridWorkerAdminCredentials  = Credential object that contains username & password for an account that is local admin on the hybrid workers
#>
#Requires -Version 5.0
#Requires -Module AzureRM.Profile, AzureRM.Automation
$VerbosePreference = "continue"
Write-Verbose -InputObject  "Starting Runbook at time: $(get-Date -format r). Running PS version: $($PSVersionTable.PSVersion). Worker Name: $($env:COMPUTERNAME)"
$VerbosePreference = "silentlycontinue"
Import-Module -Name AzureRM.Profile, AzureRM.Automation -ErrorAction Continue -ErrorVariable oErr
If($oErr) {
    Write-Error -Message "Failed to load needed modules for Runbook." -ErrorAction Stop
}

#region Variables
$RepositoryName = "PSGallery"
$AutomationResourceGroupName = Get-AutomationVariable -Name "AAresourceGroupName"
$AutomationAccountName = Get-AutomationVariable -Name "AAaccountName"
$AutomationHybridWorkerName = Get-AutomationVariable -Name "AAhybridWorkerGroupName"
$AAworkerCredential = Get-AutomationVariable -Name "AAhybridWorkerAdminCredentials"

# Azure Automation Login for Resource Manager
$AzureConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
$AzureRunAsCertificate = Get-AutomationCertificate -Name "AzureRunAsCertificate"
#endregion

$VerbosePreference = "continue"
try {
    TODO: Have check for running under admin rights

#region Authenticate to Azure
    # ADD certificate if it is not in the cert store of the user
    if ((Test-Path Cert:\CurrentUser\My\$($AzureConnection.CertificateThumbprint)) -eq $false)
    {
        Write-Verbose -Message "Installing the Service Principal's certificate..."
        $store = new-object System.Security.Cryptography.X509Certificates.X509Store("My", "CurrentUser")
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::MaxAllowed)
        $store.Add($AzureRunAsCertificate)
        $store.Close()
    }

    $cert = Get-ChildItem -Path Cert:\CurrentUser\my | Where-Object {$_.Thumbprint -eq $($AzureConnection.CertificateThumbprint)}
    if($($cert.PrivateKey.CspKeyContainerInfo.Accessible) -eq $True)
    {
        Write-Verbose -Message "Private key of login certificate is accessible"
    }
    else
    {
        Write-Error -Message "Private key of login certificate is NOT accessible, check you user certificate store if the private key is missing or damaged" -ErrorAction Stop
    }
    Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $AzureConnection.TenantId `
    -ApplicationId $AzureConnection.ApplicationId `
    -CertificateThumbprint $AzureConnection.CertificateThumbprint -ErrorAction Continue -ErrorVariable oErr
    if($oErr) {
        Write-Error -Message "Failed to connect to Azure." -ErrorAction Stop
    }
    Select-AzureRmSubscription -SubscriptionId $AzureConnection.SubscriptionID -ErrorAction Continue -ErrorVariable oErr
    If($oErr)
    {
        Write-Error -Message "Failed to select Azure subscription." -ErrorAction Stop
    }
#endregion

#region Get data from AA
    # Get modules installed in AA
    $AAInstalledModules = Get-AzureRMAutomationModule -AutomationAccountName $AutomationAccountName -ResourceGroupName $AutomationResourceGroupName

	# Get names of hybrid workers
    $AAworkers = (Get-AzureRMAutomationHybridWorkerGroup -Name $AutomationHybridWorkerName -ResourceGroupName $AutomationResourceGroupName -AutomationAccountName $AutomationAccountName -ErrorAction SilentlyContinue -ErrorVariable oErr).RunbookWorker.Name
    if($oErr)
    {
        Write-Error -Message "Failed to fetch hybrid worker group" -ErrorAction Stop
    }
#endregion

    Write-Verbose -InputObject "Unloading modules on hybrid worker: $($env:COMPUTERNAME)"
    Remove-Module -Name AzureRM.Profile, AzureRM.Automation -Force -ErrorAction Continue -ErrorVariable oErr
    if($oErr)
    {
        Write-Error -Message "Failed to unload modules on hybrid worker: $($env:COMPUTERNAME)" -ErrorAction Stop
    }
    Write-Output -InputObject "Runbook is currently running on worker: $(([System.Net.Dns]::GetHostByName(($env:computerName))).HostName)"
    # Start a removete session against the worker not currently running on
#region Code to run remote
    $ScriptBlock =
    {
        Import-Module -Name Packagemanagement -ErrorAction Continue -ErrorVariable oErr
        if($oErr) {
            Write-Error -Message "Failed to load Packagemanagement module." -ErrorAction Stop
        }
        # Get installed modules
        $InstalledModules = Get-InstalledModule -ErrorAction Continue -ErrorVariable oErr
        if($oErr) {
            Write-Error -Message "Failed to retrieve installed modules" -ErrorAction Stop
        }
        # Find missing modules on hybrid worker
        $MissingModules = Compare-Object -ReferenceObject $Using:AAInstalledModules -DifferenceObject $InstalledModules -Property Name | Where-Object {$_.SideIndicator -eq "<="}

        # Add missing modules from Gallery
        ForEach($MissingModule in $MissingModules.Name)
        {
            # Not optimized for speed
            # Check if it is a PSGallery module
            try
            {
                # ErrorVariable does not get populated, try/catch is a workaround to get at the error
                $ModuleFound = Find-Module -Name $MissingModule -Repository $RepositoryName -ErrorAction Stop
            }
            catch [System.Exception]
            {
                Write-Verbose -Message "No match found for module name: $MissingModule in PSGallery"
            }
            catch
            {
                Write-Error -Message "Failed to serach for module" -ErrorAction Continue
            }

            if($ModuleFound)
            {
                if(($ModuleFound.GetTYpe()).BaseType -eq "System.Object")
                {
                    # TODO: Option to remove older module versions
                    # Check if module is already installed / can also be used to find older versions and cleanup
                    if(-not (Get-Module -Name $ModuleFound.Name -ListAvailable))
                    {
                        # Install-Module will by default install dependecies according to documentation
                        Install-Module -Name $ModuleFound.Name -AllowClobber -Confirm:$False -ErrorAction Continue -ErrorVariable oErr
                        if($oErr)
                        {
                            Write-Error -Message "Failed to install module: $($ModuleFound.Name)" -ErrorAction Continue
                        }
                        else
                        {
                            # New module added
                            $newModule = $true
                        }
                    }
                }
                else
                {
                    Write-Output -InputObject "More than one module was found in search, nothing was installed"
                }
            }
        }
        if($newModule)
        {
            # Get updated installed modules
            $InstalledModules = Get-InstalledModule -ErrorAction Continue -ErrorVariable oErr
            if($oErr)
            {
                Write-Error -Message "Failed to retrieve installed modules" -ErrorAction Stop
            }
        }

        $VerbosePreference = "Continue"
        # Redirect Verbose log stream to output stream
        ForEach($InstalledModule in $InstalledModules)
        {
            # Only update modules instelled from gallery
            if($InstalledModule.Repository -eq $RepositoryName)
            {
                # Redirecting Verbose stream to Output stream so log can be transfered back
                $VerboseLog = Update-Module -Name $InstalledModule.Name -ErrorAction SilentlyContinue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                # continue on error
                if($oErr)
                {
                    Write-Error -Message "Failed to update module: $($InstalledModule.Name)" -ErrorAction Continue
                    $oErr = $Null
                }
                if($VerboseLog)
                {
                    if($VerboseLog -like "*Skipping installed module*")
                    {
                        Write-Output -InputObject "Module: $($InstalledModule.Name) is up to date running version: $($InstalledModule.Version)"
                    }
                    else
                    {
                        Write-Output -InputObject "Updating Module: $($InstalledModule.Name)"
                        # Outputting the whole verbose log
                        $VerboseLog
                    }
                }
            }
            else
            {
                Write-Output -InputObject "Module: $($InstalledModule.Name) not in PSGallery, therefore will not autoupdate"
            }
        }
    }
#endregion

#region Logic for running code remote on workers
    ForEach($AAworker in $AAworkers)
    {
        $AAjobs = Get-AzureRMAutomationJob -AutomationAccountName $AutomationAccountName -ResourceGroupName $AutomationResourceGroupName |
                    Where-Object {$_.Hybridworker -ne $Null -and ($_.Status -eq "Running" -or $_.Status -eq "Starting" -or $_.Status -eq "Activating" -or $_.Status -eq "New" ) }
        Write-Output -InputObject "Invoking module update against worker: $AAworker"
        #TODO: Check if Get-AzureRMAutomationJob has the worker node name in return object, check that Hybridworker parameter is of type string, check that compare works as intended
        if(-not [bool]($AAjobs.HybridWorker -match $AAworker))
        {
            Invoke-Command -ComputerName $AAworker -Credential $AAworkerCredential -ScriptBlock $ScriptBlock -HideComputerName -ErrorAction Continue -ErrorVariable oErr
            if($oErr)
            {
                Write-Error -Message "Error executing remote command against: $AAworker" -ErrorAction Continue
                $oErr = $Null
            }
        }
    }
}
#endregion
catch
{
    if($_.Exception.Message)
    {
        Write-Error -Message "$($_.Exception.Message)" -ErrorAction Continue
    }
    else
    {
        Write-Error -Message "$($_.Exception)" -ErrorAction Continue
    }
    throw "$($_.Exception)"
}
finally
{
    Write-Output -InputObject "Runbook ended at time: $(get-Date -format r)"
}