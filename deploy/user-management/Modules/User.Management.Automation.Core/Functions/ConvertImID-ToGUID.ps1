function Convert-ImIDToGUID {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $ImmutableId
    )

    try {
        $byteArray = [Convert]::FromBase64String($ImmutableId)
        $newGuid = ([Guid]$byteArray).Guid
        Write-Output $newGuid
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}