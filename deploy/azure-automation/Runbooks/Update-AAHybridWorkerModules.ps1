#Requires -Version 5.1
#Requires -Module AzureRM.Profile, AzureRM.Automation
Param(
[bool]$UpdateAllHybridGoups = $true,
[bool]$ForceInstallModule = $false,
[bool]$UpdateToNewestModule = $false,
[bool]$SyncOnly = $false,
[bool]$UpdateOnly = $false,
[bool]$AllRepositories = $false,
[String]$ModuleRepositoryName = "PSGallery",
[String]$ModuleSourceLocation = ""
)
<#
NAME:       Update-AAHybridWorkerModules
AUTHOR:     Morten Lerudjordet
EMAIL:      morten.lerudjordet@rewired.no

DESCRITPION:
            This runbook will check installed modules in AA account and attempt to download these from the configured trusted repositories to the hybrid workers
            It will also update independend modules installed from PSGallery to latest version (using Install-Module).
            The logic will not clean out older versions of modules.
            The different behaviours are configurable by manipulating parameters.

            Note:
                All manually uploaded (not imported from PSGallery) modules to AA will not be handled by this runbooks, and should be handled by other means
                Run Get-InstalledModule in PS command window (not in ISE) to check that Repository is set to PSGallery

PREREQUISITES:
            Powershell version 5.1 on hybrid workers
            Latest AzureRM & AzureRM.Automation module installed on hybrid workers for first time run using Install-Module from admin PS command line
            Make sure AzureRM.Profile has repository equal to PSGallery (use Get-InstalledModule) to check, if not use Uninstall-Module and Install-Module
            Azure Automation Assets:
                AAresourceGroupName             = Name of resourcegroup Azure Automation resides in
                AAaccountName                   = Name of Azure Automation account
                AAhybridWorkerAdminCredentials  = Credential object that contains username & password for an account that is local admin on the hybrid worker(s).
                                                  If hybrid worker group contains more than one worker, the account must be allowed to do remoting to all workers.

.PARAMETER UpdateAllHybridGoups
            If $true the runbook will try to remote to all hybrid workers in every hybrid group attached to AA account
            $false will only update the hybrid workers in the same hybrid group the update runbook is running on
            Default is $true

.PARAMETER ForceReinstallofModule
            If $true the runbook will try to force a uninstall-module and install-module if update-module fails
            $false will not try to force reinstall of module
            Default is $false

.PARAMETER UpdateToNewestModule
            If $true the runbook will install newest available module version if the version installed in Azure Automation is not available in repository
            $false will not install the module at all on the hybrid worker if the same version as in AA is not available in repository
            Default is $false

.PARAMETER SyncOnly
            If $true the runbook will only install the modules and version found in Azure Automation
            $false will keep all modules on hybrid worker up to date with the latest found in the repository
            Default is $false

.PARAMETER UpdateOnly
            If $true the runbook will only update already installed modules on the hybrid worker
            $false will query AA for modules installed there and add the onces missing on the worker
            Default is $false

.PARAMETER AllRepositories
            If $true the runbook will use all registered trusted repositories
            $false will only use the repository set in ModuleRepositoryName variable
            Default is $false

.PARAMETER ModuleRepositoryName
            Name of repository to use
            Default is PSGallery

.PARAMETER ModuleSourceLocation
            URL of repository location. Set this parameter with the ModuleRepositoryName = the new repo to add.
            Running the runbook once will add the new repository to hybrid workers and sets it as trusted.
            Then set AllRepositories = $true to make the runbook search all repositories for adding modules from AA or updating them locally
#>
try {
    # just incase Requires does not work
    if($PSVersionTable.PSVersion -lt 5.1)
    {
        Write-Error -Message "Powershell version must be 5.1 or higher. Current version: $($PSVersionTable.PSVersion)" -ErrorAction Stop
    }
    $VerbosePreference = "continue"
    Write-Verbose -Message  "Starting Runbook at time: $(Get-Date -format r).`nRunning PS version: $($PSVersionTable.PSVersion).`nWorker Name: $($env:COMPUTERNAME)"
    $VerbosePreference = "silentlycontinue"
    Import-Module -Name AzureRM.Profile, AzureRM.Automation -ErrorAction Continue -ErrorVariable oErr
    If($oErr) {
        Write-Error -Message "Failed to load needed modules for Runbook." -ErrorAction Stop
    }

#region Variables
    # Azure Automation environment
    $AutomationResourceGroupName = Get-AutomationVariable -Name "AAresourceGroupName" -ErrorAction Stop
    $AutomationAccountName = Get-AutomationVariable -Name "AAaccountName" -ErrorAction Stop
    $AAworkerCredential = Get-AutomationPSCredential -Name "AAhybridWorkerAdminCredentials" -ErrorAction Stop

    # Azure Automation Login for Resource Manager
    $AzureConnection = Get-AutomationConnection -Name "AzureRunAsConnection" -ErrorAction Stop
    $AzureRunAsCertificate = Get-AutomationCertificate -Name "AzureRunAsCertificate" -ErrorAction Stop

    # Local variables
    $RunbookName = "Update-AAHybridWorkerModules"
    $RunbookJobHistoryDays = -1
#endregion

    $VerbosePreference = "continue"

#TODO: Have check for running under admin rights

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
# Below authentication will lock AzureRM.profile from updating
<#
    $Null = Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $AzureConnection.TenantId `
    -ApplicationId $AzureConnection.ApplicationId `
    -CertificateThumbprint $AzureConnection.CertificateThumbprint -ErrorAction Continue -ErrorVariable oErr
    if($oErr) {
        Write-Error -Message "Failed to connect to Azure." -ErrorAction Stop
    }
    $Null = Select-AzureRmSubscription -SubscriptionId $AzureConnection.SubscriptionID -ErrorAction Continue -ErrorVariable oErr
    If($oErr)
    {
        Write-Error -Message "Failed to select Azure subscription." -ErrorAction Stop
    }
#>

    $Null = Login-AzureRmAccount -ServicePrincipal -ApplicationId $AzureConnection.ApplicationId `
    -CertificateThumbprint $AzureConnection.CertificateThumbprint -TenantId $AzureConnection.TenantId `
    -SubscriptionId $AzureConnection.SubscriptionId -ErrorAction Continue -ErrorVariable oErr
    if($oErr)
    {
        Write-Error -Message "Failed to login to Azure" -ErrorAction Stop
    }

#endregion

#region Get data from AA
    # Get modules installed in AA
    Write-Verbose -Message "Retrieving installed modues in AA"
    $AAInstalledModules = Get-AzureRMAutomationModule -AutomationAccountName $AutomationAccountName -ResourceGroupName $AutomationResourceGroupName |
                            Where-Object {$_.ProvisioningState -eq "Succeeded"}

    # Get names of hybrid workers in all groups
    Write-Verbose -Message "Fetching name of all hybrid worker groups"
    # Get groups but filter out the ones with GUID in them as they are not legitimate groups
    $AAworkerGroups = (Get-AzureRMAutomationHybridWorkerGroup -ResourceGroupName $AutomationResourceGroupName -AutomationAccountName $AutomationAccountName -ErrorAction SilentlyContinue -ErrorVariable oErr) |
                    Where-Object -FilterScript {$_.Name -notmatch '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}'}
    if($oErr)
    {
        Write-Error -Message "Failed to fetch hybrid worker(s)" -ErrorAction Stop
    }
#endregion

#region Code to run remote
    $ScriptBlock =
    {
#region Install PowershellGet
        Import-Module -Name PowerShellGet -ErrorAction Continue -ErrorVariable oErr
        if($oErr)
        {
            Write-Error -Message "Failed to load PowerShellGet module." -ErrorAction Continue
        }

        if($Using:AllRepositories)
        {
            # Check if PSGallery is trusted, if not make it so
            $Repositories = Get-PSRepository -ErrorAction Continue -ErrorVariable oErr
            if($oErr)
            {
                Write-Error -Message "Failed to get repository information" -ErrorAction Stop
            }
        }
        else
        {
            # Check if PSGallery is trusted, if not make it so
            $Repositories = Get-PSRepository -ErrorAction Continue -ErrorVariable oErr | Where-Object -FilterScript {$_.Name -eq $Using:ModuleRepositoryName}
            if($oErr)
            {
                Write-Error -Message "Failed to get repository information" -ErrorAction Stop
            }
            if($Repositories)
            {
                if($Repositories.InstallationPolicy -eq "Untrusted")
                {
                    Set-PSRepository -Name $Using:ModuleRepositoryName -InstallationPolicy Trusted
                    Write-Output -InputObject "Added trust for repositiry: $($Using:ModuleRepositoryName)"
                }
            }
            else
            {
                if($Using:ModuleSourceLocation)
                {
                    Register-PSRepository -Name $Using:ModuleRepositoryName -SourceLocation $Using:ModuleSourceLocation -PublishLocation $Using:ModuleSourceLocation -InstallationPolicy 'Trusted'
                    Write-Output -InputObject "Added repositiry: $($Using:ModuleRepositoryName) from location: $($Using:ModuleSourceLocation) to hybrid worker repository"
                }
                else
                {
                    Write-Error -Message "Variable ModuleSourceLocation is missing repository URL, can't add new repository to hybrid worker" -ErrorAction Stop
                }
            }
        }
        Write-Output -InputObject "Forcing install of PowerShellGet from PSGallery"
        # PSGallery as source is hardcoded and not using the ModuleRepositoryName variable
        $VerboseLog = Install-Module -Name PowerShellGet -AllowClobber -Force -Repository PSGallery -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
        if($oErr)
        {
            Write-Error -Message "Failed to install module: PowerShellGet" -ErrorAction Continue
            $oErr = $Null
        }
        if($VerboseLog)
        {
            Write-Output -InputObject "Installing Module: PowerShellGet"
            # Outputting the whole verbose log
            #$VerboseLog
            $VerboseLog = $Null
        }
#endregion

        Write-Output -InputObject "Using repositories: $($Repositories.Name)"
        # Get installed modules
        $InstalledModules = Get-InstalledModule -ErrorAction Continue -ErrorVariable oErr
        if($oErr)
        {
            Write-Error -Message "Failed to retrieve installed modules" -ErrorAction Stop
        }
        if(-not $Using:UpdateOnly)
        {
#region Compare AA modules with modules installed on worker and install from repository if version found
            # Find missing modules on hybrid worker
            $MissingModules = Compare-Object -ReferenceObject $Using:AAInstalledModules -DifferenceObject $InstalledModules -Property Name -PassThru |
                Where-Object {$_.SideIndicator -eq "<="} | Select-Object -Property Name,Version
            if($MissingModules)
            {
                # Add missing modules from repositories
                ForEach($MissingModule in $MissingModules)
                {
                    Write-Output -InputObject "Module: $($MissingModule.Name) is missing on hybrid worker"
                    try
                    {
                        # ErrorVariable does not get populated, try/catch is a workaround to get at the error, if more module are returned only select with excact same name
                        $ModuleFound = Find-Module -Name $MissingModule.Name -AllVersions -Repository $Repositories.Name -ErrorAction Stop |
                                Where-Object -FilterScript {$_.Name -eq $MissingModule.Name}
                    }
                    catch
                    {
                        if($_.CategoryInfo.Category -eq "ObjectNotFound")
                        {
                            Write-Output -InputObject "No match found for module name: $($MissingModule.Name) in $($Repositories.Name)"
                        }
                        else
                        {
                            Write-Error -Message "Failed to serach for module" -ErrorAction Continue
                        }
                    }
                    if($ModuleFound)
                    {
                        # Choose repo with highest version number
                        if(($ModuleFound.GetTYpe()).BaseType.Name -eq "Array")
                        {
                            # Choose repo with highest version number of module
                            $RepositoryToInstallFrom = $ModuleFound | Sort-Object -Descending -Property Version | Select-Object -First 1 | Select-Object -Property Repository
                            $ModuleFound = $ModuleFound | Where-Object -FilterScript {$_.Repository -eq $RepositoryToInstallFrom.Repository}
                            if(($ModuleFound.GetTYpe()).BaseType.Name -eq "Array")
                            {
                                Write-Output -InputObject "Module: $($ModuleFound[0].Name) found in multiple trusted repositories. Installing from $($ModuleFound[0].Repository) as it has the highest version number"
                            }
                            else
                            {
                                Write-Output -InputObject "Module: $($ModuleFound.Name) found in multiple trusted repositories. Installing from $($ModuleFound.Repository) as it has the highest version number"
                            }
                        }
                        # Check to see if the same version is available in repository, then install this version even if it is not the newest
                        if($ModuleFound.Version -match $MissingModule.Version)
                        {
                            # Get the correct version to install
                            $ModuleFound = $ModuleFound | Where-Object -FilterScript {$_.Version -match $MissingModule.Version}
                            if(($ModuleFound.GetTYpe()).BaseType.Name -eq "Object")
                            {
                                Write-Output -InputObject "Module: $($ModuleFound.Name) with correct version: $($ModuleFound.Version) found in repository: $($ModuleFound.Repository) and will be installed on worker"
# TODO: Option to remove older module versions
                                # Check if module is already installed / can also be used to find older versions and cleanup
                                if((Get-Module -Name $ModuleFound.Name -ListAvailable) -eq $Null)
                                {
                                    # Install-Module will by default install dependecies according to documentation
                                    $VerboseLog = Install-Module -Name $ModuleFound.Name -AllowClobber -RequiredVersion $ModuleFound.Version -Repository $ModuleFound.Repository -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                                    if($oErr)
                                    {
                                        Write-Error -Message "Failed to install module: $($ModuleFound.Name)" -ErrorAction Continue
                                        $oErr = $Null
                                    }
                                    else
                                    {
                                        # New module added
                                        $newModule = $true
                                    }
                                    if($VerboseLog)
                                    {
                                        Write-Output -InputObject "Installing Module: $($ModuleFound.Name) with version: $($ModuleFound.Version)"
                                        # Outputting the whole verbose log
                                        $VerboseLog
                                        $VerboseLog = $Null
                                    }
                                }
                            }
                            else
                            {
                                Write-Output -InputObject "More than one module was found in search, nothing was installed"
                            }
                        }
                        else
                        {
                            # Update to newest module version if the module version installed in AA is no longer available in repository
                            if($Using:UpdateToNewestModule)
                            {
                                # Use latest version
                                $ModuleFound = $ModuleFound[0]
                                # Check if module is already installed / can also be used to find older versions and cleanup
                                if((Get-Module -Name $ModuleFound.Name -ListAvailable) -eq $Null)
                                {
                                    # Install-Module will by default install dependecies according to documentation
                                    $VerboseLog = Install-Module -Name $ModuleFound.Name -AllowClobber -Repository $ModuleFound.Repository -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                                    if($oErr)
                                    {
                                        Write-Error -Message "Failed to install module: $($ModuleFound.Name)" -ErrorAction Continue
                                        $oErr = $Null
                                    }
                                    else
                                    {
                                        # New module added
                                        $newModule = $true
                                    }
                                    if($VerboseLog)
                                    {
                                        Write-Output -InputObject "Installing Module: $($ModuleFound.Name) with latest version: $($ModuleFound.Version)"
                                        # Outputting the whole verbose log
                                        $VerboseLog
                                        $VerboseLog = $Null
                                    }
                                }
                            }
                            else
                            {
                                Write-Error -Message "Could not find version: $($MissingModule.Version) of module: $($MissingModule.Name) in: $($Repositories.Name). Update module in Azure Automation" -ErrorAction Continue
                                Write-Output -InputObject "Set UpdateToNewestModule to true to install newest version of module: $($MissingModule.Name).`nOr update version of module in Azure Automation"
                            }
                        }
                    }
                    else
                    {
                        Write-Output -InputObject "Module: $($MissingModule.Name) with version: $($MissingModule.Version) not found in repository: $($Repositories.Name)"
                    }
                }
            }
            else
            {
                Write-Output -InputObject "None of the missing modules where found in the configured repository: $($Repositories.Name)"
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
#endregion
        }
#region Update all modules installed from repositories with latest version
        # check if only want to keep the same module version as on AA and not update all modules on worker to latest
        if(-not $Using:SyncOnly)
        {
            if($InstalledModules)
            {
                ForEach($InstalledModule in $InstalledModules)
                {
                    # Only update modules installed from given repository
                    #Write-Output -InputObject "Module: $($InstalledModule.Name) is from repository: $($InstalledModule.Repository)"
                    if( $Repositories.Name -match $InstalledModule.Repository )
                    {
                        # Will try to unload module from session so update can be done
                        if((Get-Module -Name $InstalledModule.Name -ListAvailable) -ne $Null)
                        {
                            Write-Output -InputObject "Unloading module: $($InstalledModule.Name) on hybrid worker: $($env:COMPUTERNAME)"
                            Remove-Module -Name $InstalledModule.Name -Force -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable oErr
                            if($oErr)
                            {
                                if($oErr -notlike "*No modules were removed*")
                                {
                                    Write-Error -Message "Failed to unload module: $($InstalledModule.Name) on hybrid worker: $($env:COMPUTERNAME). Will try to update anyway." -ErrorAction Continue
                                }
                                $oErr = $Null
                            }
                        }

                        # Redirecting Verbose stream to Output stream so log can be transfered back
                        $VerboseLog = Update-Module -Name $InstalledModule.Name -ErrorAction SilentlyContinue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                        # continue on error
                        if($oErr)
                        {
                            Write-Error -Message "Failed to update module: $($InstalledModule.Name)" -ErrorAction Continue
                            $oErr = $Null
                            if($Using:ForceInstallModule)
                            {
                                $VerboseLog = Uninstall-Module -Name $InstalledModule.Name -Force -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                                if($oErr)
                                {
                                    Write-Error -Message "Failed to remove module: $($InstalledModule.Name)" -ErrorAction Continue
                                    $oErr = $Null
                                }
                                if($VerboseLog)
                                {
                                    Write-Output -InputObject "Forcing removal of module: $($InstalledModule.Name)"
                                    # Streaming verbose log
                                    $VerboseLog
                                    $VerboseLog = $Null
                                }
                                $VerboseLog = Install-Module -Name $InstalledModule.Name -AllowClobber -Force -Repository $InstalledModule.Repository -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                                if($oErr)
                                {
                                    Write-Error -Message "Failed to install module: $($InstalledModule.Name)" -ErrorAction Continue
                                    $oErr = $Null
                                }
                                if($VerboseLog)
                                {
                                    Write-Output -InputObject "Forcing install of module: $($InstalledModule.Name) from $($InstalledModule.Repository)"
                                    # Streaming verbose log
                                    $VerboseLog
                                    $VerboseLog = $Null
                                }
                            }
                        }
                        if($VerboseLog)
                        {
                            if($VerboseLog -like "*Skipping installed module*")
                            {
                                Write-Output -InputObject "Module: $($InstalledModule.Name) is up to date running version: $($InstalledModule.Version) repository: $($InstalledModule.Repository)"
                            }
                            else
                            {
                                Write-Output -InputObject "Updating Module: $($InstalledModule.Name)"
                                # Streaming verbose log
                                $VerboseLog
                                $VerboseLog = $Null
                            }
                        }
                    }
                    else
                    {
                        # Check if repo name is URL, if try to reinstall module to get supported repo naming convention
                        if($InstalledModule.Repository -match '(https?://([-\w\.]+)+(:\d+)?(/([\w/_\.]*(\?\S+)?)?)?)')
                        {
                            # Check if Get-InstalledMoule does not give correct repository formatting. Reinstall module to force correct repository naming
                            $ModuleFound = $Null
                            # If multiple repos are in use find can return multiple modules
                            $ModuleFound = Find-Module -Name $InstalledModule.Name -Repository $Repositories.Name -ErrorAction SilentlyContinue

                            if($ModuleFound)
                            {
#TODO: Better handling of from what repo to install module from if multiple are returned from find
                                # Check if module is in multiple repos
                                if(($ModuleFound.GetTYpe()).BaseType.Name -eq "Array")
                                {
                                    Write-Output -InputObject "Multiple repositories has module: $($InstalledModule.Name) hosted"
                                    if($ModuleFound.Repository -match "PSGallery")
                                    {
                                        # prefer PSGallery
                                        $ModuleFound = $ModuleFound | Where-Object -FilterScript {$_.Repository -like "*PSGallery*"}
                                        Write-Output -InputObject "Module: $($InstalledModule.Name) found in multiple trusted repositories. Installing from $($ModuleFound.Repository)"
                                    }
                                    else
                                    {
                                        # Use the repo with the highest version number
                                        $ModuleFound = $ModuleFound | Sort-Object -Descending -Property Version | Select-Object -First 1
                                        Write-Output -InputObject "Module: $($InstalledModule.Name) found in multiple trusted repositories. Installing from $($ModuleFound.Repository)"
                                    }
                                }
                                Write-Output -InputObject "Local module: $($InstalledModule.Name) has URL for repository name, reinstalling to fix"
                                $VerboseLog = Uninstall-Module -Name $ModuleFound.Name -Force -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                                if($oErr)
                                {
                                    Write-Error -Message "Failed to install module: $($ModuleFound.Name)" -ErrorAction Continue
                                    $oErr = $Null
                                }
                                if($VerboseLog)
                                {
                                    Write-Output -InputObject "Forcing removal of module: $($ModuleFound.Name)"
                                    # Streaming verbose log
                                    $VerboseLog
                                    $VerboseLog = $Null
                                }
                                $VerboseLog = Install-Module -Name $ModuleFound.Name -Force -Repository $ModuleFound.Repository -ErrorAction Continue -ErrorVariable oErr -Verbose:$True -Confirm:$False 4>&1
                                if($oErr)
                                {
                                    Write-Error -Message "Failed to install module: $($ModuleFound.Name)" -ErrorAction Continue
                                    $oErr = $Null
                                }
                                if($VerboseLog)
                                {
                                    Write-Output -InputObject "Forcing install of module: $($ModuleFound.Name) from $($ModuleFound.Repository)"
                                    # Streaming verbose log
                                    $VerboseLog
                                    $VerboseLog = $Null
                                }
                            }
                            else
                            {
                                Write-Output -InputObject "Module: $($InstalledModule.Name) is not in $($Repositories.Name), therefore will not autoupdate"
                            }
                        }
                    }
                }
            }
        }
#endregion

    }
#endregion

#region Logic for running code remote on workers
    $CurrentWorker = ([System.Net.Dns]::GetHostByName(($env:computerName))).HostName
    $CurrentWorkerGroup = $AAworkerGroups | Where-Object -FilterScript {$_.RunbookWorker.Name -match $CurrentWorker} | Select-Object -Property Name

    Write-Output -InputObject "Runbook is currently running on worker: $CurrentWorker in worker group: $($CurrentWorkerGroup.Name)"
    # Remove logging noise of removal and adding modules to session
    $VerbosePreference = "silentlycontinue"
    ForEach($AAworkerGroup in $AAworkerGroups)
    {
        if(($AAworkerGroup.Name -ne $CurrentWorkerGroup) -and (-not $UpdateAllHybridGoups))
        {
            Write-Output -InputObject "Skipping updating the hybrid worker group: $AAworkerGroup as UpdateAllHybridGoups is set to $UpdateAllHybridGoups"
        }
        else
        {
            Write-Output -InputObject "Updating hybrid workers in group: $($AAworkerGroup.Name)"
            $AAjobs = Get-AzureRMAutomationJob -AutomationAccountName $AutomationAccountName -ResourceGroupName $AutomationResourceGroupName -StartTime (Get-Date).AddDays($RunbookJobHistoryDays) |
                    Where-Object {$_.RunbookName -ne $RunbookName -and $_.Hybridworker -ne $Null -and ($_.Status -eq "Running" -or $_.Status -eq "Starting" -or $_.Status -eq "Activating" -or $_.Status -eq "New") }

            Remove-Module -Name AzureRM.Profile, AzureRM.Automation -Force -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable oErr
            if($oErr)
            {
                if($oErr -notlike "*No modules were removed*")
                {
                    Write-Warning -Message "Failed to unload modules on hybrid worker: $($env:COMPUTERNAME)"
                }
                $oErr = $Null
            }
            # Dont start update job if other runbooks are running on the hybrid worker group. At the moment one can only get the hybrid worker group something is running on not the idividual worker
            if(-not [bool]($AAjobs.HybridWorker -match $AAworkerGroup.Name))
            {
                ForEach($AAworker in $AAworkerGroup.RunbookWorker.Name)
                {
                    Write-Output -InputObject "Invoking module update against worker: $AAworker"
                    Invoke-Command -ComputerName $AAworker -Credential $AAworkerCredential -ScriptBlock $ScriptBlock -HideComputerName -ErrorAction Continue -ErrorVariable oErr
                    if($oErr)
                    {
                        Write-Error -Message "Error executing remote command against: $AAworker.`n$oErr" -ErrorAction Continue
                        $oErr = $Null
                    }
                }
            }
            else
            {
                Write-Warning -Message "Hybrid worker group: $($AAworkerGroup.Name) has jobs running. Will not run update of modules at this time"
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