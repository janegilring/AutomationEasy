# Runbook: Update-AAHybridWorkerModules  

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

* Powershell version 5.1 on hybrid workers
* Latest AzureRM & AzureRM.Automation module installed on hybrid workers for first time run usingInstall-Module from admin PS command line
* Make sure AzureRM.Profile has repository equal to PSGallery (use Get-InstalledModule) to check, if not use Uninstall-Module and Install-Module

Azure Automation Assets:  

     AAresourceGroupName                = Name of resourcegroup Azure Automation resides in
     AAaccountName                      = Name of Azure Automation account
     AAhybridWorkerAdminCredentials     = Credential object that contains username & password for an account that is local admin on the hybrid worker(s).
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
