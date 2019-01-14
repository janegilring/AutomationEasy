[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "By design - used in script intended for interactive use.")]
param (
    $AutomationAccount= 'Infrastructure-Automation',
    $ResourceGroup = 'RG-Infrastructure-Automation',
    $Path = (Join-Path $env:SYSTEM_ARTIFACTSDIRECTORY "_IT Ops\Azure\Automation\Runbooks"),
    $Tags =  @{'Source'='Release Pipeline'; 'Environment' = 'Prod'}
)

<#

 NAME: Sync-Runbooks.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to synchronize runbooks from a local path to an Azure Automation account.
          Can be leveraged both locally during development and as part of a release pipeline.

 #>

 if (Get-Module -ListAvailable -Name Az.Automation) {

     Import-Module -Name Az.Automation

} else {

    Write-Warning "Missing prerequisite Az PowerShell module, exiting..."
    Write-Host "You may install the module from PowerShell Gallery using PowerShellGet: Install-Module -Name Az" -ForegroundColor Yellow

    break

}

    $files = Get-ChildItem -Path $path -Recurse | Where-Object {$_.Extension -eq ".ps1"}

    foreach ($file in $files) {

        $runbookname = $file.BaseName

        Write-Host "Publishing $runbookname" -ForegroundColor Green

        $null = Import-AzAutomationRunbook -Name $runbookname -path $file.FullName -Type PowerShell -Force -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount -Tags $Tags
        $null = Publish-AzAutomationRunbook -Name $runbookname -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount
        $null = Set-AzAutomationRunbook -Name $runbookname -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount

    }