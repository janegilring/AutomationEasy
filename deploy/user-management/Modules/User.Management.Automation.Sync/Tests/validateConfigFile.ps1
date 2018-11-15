#more work needed.

param (
    [string] $SettingsFile
)

if (Test-Path -Path $SettingsFile) {
    $settings = Get-Content -Path $SettingsFile -Raw | ConvertFrom-Json
}

else {
    Write-Warning "Could not read the settings file ($($SettingsFile))"
}

Describe 'Config file' {
    It 'LogType' {
        $settings.LogType | Should Be 'File'
    }

    # FIX if log file not exist
    It 'LogPath' {
        Test-Path -Path $settings.LogPath | Should Be $true
    }

    It 'VerboseLogging' {
        $settings.VerboseLogging | Should Match "True|False"
    }

    It 'WhatIf' {
        $settings.WhatIf | Should Match "True|False"
    }


}

Describe 'AttributeMappings' {

    foreach ($mapping in $settings.AttributeMappings) {

        Context "$($mapping.type)" {

            It 'Source' {
                $mapping.Source | Should Not BeNullOrEmpty
            }

            It 'Target' {
                $mapping.Target | Should Not BeNullOrEmpty
            }

            It 'Teste at attributter finnes i AD / HR' {
                #$mapping.SkuId | Should Not BeNullOrEmpty
               # $sku = Get-AzureADSubscribedSku | Where-Object {$_.SkuId -eq $mapping.SkuId}
              #  $sku | Should Not BeNullOrEmpty
            }

        }
    }
}