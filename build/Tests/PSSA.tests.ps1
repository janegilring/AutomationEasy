param ($PSScriptRoot)
Describe 'Testing against PowerShell Script Analyzer Rules' {
    Context 'PSSA Standard Rules' {

        $Files = Get-ChildItem -Path $PSScriptRoot\..\..\deploy -Recurse | where {$_.Extension -eq ".ps1"}
        foreach ($file in $files) {

            $analysis = Invoke-ScriptAnalyzer -Path $file.FullName -ExcludeRule PSUseDeclaredVarsMoreThanAssignments,PSUseBOMForUnicodeEncodedFile
            $scriptAnalyzerRules = Get-ScriptAnalyzerRule

            forEach ($rule in $scriptAnalyzerRules) {
                It "File $($File.Name) should pass $rule" {
                    If ($analysis.RuleName -contains $rule) {
                        $analysis |
                            Where RuleName -EQ $rule -outvariable failures |
                            Out-Default
                        $failures.Count | Should Be 0
                    }
                }
            }
        }
    }
}