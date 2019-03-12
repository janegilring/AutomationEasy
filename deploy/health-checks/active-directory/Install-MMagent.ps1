function Install-MMAgent {
    [CmdletBinding()]
    param (
        [string]$WorkspaceKey,
        [string]$WorkspaceID
    )

    If (-not (Test-Path C:\AutomationEasy\MMAgent)) {
        New-Item -Path C:\AutomationEasy\MMAgent -ItemType Directory
    }
    Push-Location
    Set-Location C:\AutomationEasy\MMAgent

    $location = (Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkId=828603" -MaximumRedirection 0 -ErrorAction SilentlyContinue).Headers.Location

    Start-BitsTransfer -Source $location -Destination "C:\AutomationEasy\MMAgent\MMASetup-AMD64.exe"

    & .\MMASetup-AMD64.exe /c /t:c:\AutomationEasy\MMAgent\

    while (-not (Test-Path C:\AutomationEasy\MMAgent\Setup.exe)) {
        Start-Sleep 1
    }

    & .\Setup.exe /qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID=$WorkspaceID OPINSIGHTS_WORKSPACE_KEY=$WorkspaceKey AcceptEndUserLicenseAgreement=1

    Pop-Location
}

Install-MMAgent -WorkspaceKey 'eSRF925LebTwZj3/cFa7YcKtSsQ1kfDnnhnBlTbdvJ/yAc/Fa84U7Jo9t2III8DpIBB1Pc/W4ou+bzv6n//kbQ==' -WorkspaceID '70d0204c-9d4b-4dff-a649-99ecf07131e5'