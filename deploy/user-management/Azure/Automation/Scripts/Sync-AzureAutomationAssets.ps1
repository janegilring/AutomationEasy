[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "By design - used in script intended for interactive use.")]
param()
<#

 NAME: Sync-AzureAutomationAssets.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: PowerShell script to manually export/import variables and credentials in Azure Automation

 #>


 if (Get-Module -ListAvailable -Name Az.Automation) {

     Import-Module -Name Az.Automation

    $PSDefaultParameterValues = @{
        "*AzAutomation*:ResourceGroupName" = 'Infrastructure-Automation'
        "*AzAutomation*:AutomationAccountName" = 'RG-Infrastructure-Automation'
      }

} else {

    Write-Warning "Missing prerequisite Az PowerShell module, exiting..."
    Write-Host "You may install the module from PowerShell Gallery using PowerShellGet: Install-Module -Name Az" -ForegroundColor Yellow

    break

}

#region Authenticate to Azure

    Connect-AzAccount

    $subscriptionId = (Get-AzSubscription | Out-GridView -Title 'Select an Azure subscription' -PassThru).SubscriptionId

    Set-AzContext -SubscriptionId $subscriptionId

#endregion

#region Azure variable assets
AzureAutomation
$CsvPath = '~\Git\user-management\Azure\Automation\Assets\AzureAutomationVariables.csv'
$XlsxPath = '~\Git\user-management\Azure\Automation\Assets\AzureAutomationVariables.xlsx'
$AAVariables = Import-Csv -Path $CsvPath

#region Import variables

foreach ($variable in $AAVariables) {

    if (-not (Get-AzAutomationVariable -Name $variable.Name -ErrorAction SilentlyContinue)) {

        Write-Output "Variable $($variable.Name) not found in Azure Automation Asset store, creating.."

        $Encrypted = [bool]::Parse($variable.Encrypted)
        New-AzAutomationVariable -Name $variable.Name -Value $variable.Value -Description $variable.Description -Encrypted $Encrypted

    } else {

        $VariableValue = (Get-AzAutomationVariable -Name $variable.Name).Value

        if (-not ($VariableValue -eq $variable.Value)) {

            Write-Output "Variable value changed for $($variable.Name). Old value: $($VariableValue) New value: $($variable.Value) Updating..."
            $Encrypted = [bool]::Parse($variable.Encrypted)
            Set-AzAutomationVariable -Name $variable.Name -Value $variable.Value -Encrypted $Encrypted

        }

    }


}

#endregion

#region Export variables

# Requires the ImportExcel PowerShell module
Get-AzAutomationVariable | Select-Object -Property Name,Value,Description,Encrypted |
Export-Excel -Path $XlsxPath -WorkSheetname AzureAutomationVariables -AutoSize -TableName Variables

#endregion

#endregion

#region Azure credential assets

$CsvPath = '~\Git\user-management\Azure\Automation\Assets\AzureAutomationCredentials.csv'
$XlsxPath = '~\Git\user-management\Azure\Automation\Assets\AzureAutomationCredentials.xlsx'
$AACredentials = Import-Csv -Path $CsvPath

#region Import credentials

foreach ($AACredential in $AACredentials) {

    if (-not (Get-AzAutomationCredential -Name $AACredential.Name -ErrorAction SilentlyContinue)) {

        Write-Output "Variable $($AACredential.Name) not found in Azure Automation Asset store, creating.."

        $Value = Get-Credential -UserName $AACredential.UserName -Message "Specify password for $($AACredential.UserName)"
        New-AzAutomationCredential -Name $AACredential.Name -Value $Value -Description $variable.Description

    }
}

#endregion

#region Export credentials

# Requires the ImportExcel PowerShell module
Get-AzAutomationCredential  | Select-Object -Property Name,UserName,Description |
Export-Excel -Path $XlsxPath -WorkSheetname AzureAutomationCredentials -AutoSize -TableName Credentials

#endregion