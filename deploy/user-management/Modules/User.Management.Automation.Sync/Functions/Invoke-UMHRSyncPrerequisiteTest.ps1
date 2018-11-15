function Invoke-UMHRSyncPrerequisiteTest {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Not sure why this test fails - need to investigate further")]
  param()

    $Path = Split-Path -Path $PSScriptRoot -Parent
    $TestPath = Join-Path -Path $Path -ChildPath Tests\Prerequisites.ps1

    $PrerequisiteTests = Invoke-Pester -Script @{
        Path       = $TestPath
      } -PassThru

      if ($PrerequisiteTests.FailedCount -gt 0) {

        $PrerequisiteTests

        $global:WorkflowStatus = 'Completed'
        $global:Status = "$($PrerequisiteTests.FailedCount) prerequisite tests failed"

        Write-Log -LogEntry $Status -LogType Error

      } else {

        $global:WorkflowStatus = 'In progress'

        Write-Log -LogEntry 'Prerequisite tests completed successfully'

      }

}