function New-UMUserData {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="By design - function is not intended for interactive use - hence ShouldProsess is not of any value")]
    param (
        $SourceData
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        $FirstName = $SourceData.First_x0020_Name
        $MiddleName = $SourceData.Middle_x0020_Name
        $Lastname = $SourceData.Last_x0020_Name

        if ($MiddleName) {

            $DisplayName = ($FirstName + ' ' + $MiddleName + ' ' + $LastName)

        } else {

            $DisplayName = ($FirstName + ' ' + $LastName)

        }

        $FirstNameShort = $FirstName[0..2] -join ''
        $LastNameShort = $LastName[0..2] -join ''

        if ($FirstName[0..2].Count -ne 3) {

            $FirstNameShort = $FirstNameShort + $FirstNameShort[-1]

        }

        if ($LastName[0..2].Count -ne 3) {

            $LastNameShort = $LastNameShort + $LastNameShort[-1]

        }

        $Username = Remove-StringLatinCharacter -String ($FirstNameShort + $LastNameShort).ToLower()
        $Username = $Username.Replace(' ', '.')

        $EmailAlias = Remove-StringLatinCharacter -String ($FirstName + '.' + $LastName).ToLower()
        $EmailAlias = $EmailAlias.Replace(' ', '.')

        $UserPrincipalName = $Username + '@' + $CompanyData.Domain
        $ExchangeAlias = $EmailAlias + '@' + $CompanyData.Domain

        [pscustomobject]@{
            FirstName         = $FirstName
            MiddleName        = $MiddleName
            LastName          = $Lastname
            DisplayName       = $DisplayName
            Username          = $Username
            UserPrincipalName = $UserPrincipalName
            MobilePhone       = $SourceData.MobilePhone
            Manager           = $SourceData.Manager.Email
            Requester         = $SourceData.Author.Email
            EmployeeCategory  = $SourceData.Employee_x0020_Category
            JobTitle          = $SourceData.Job_x0020_Title
            Team              = $SourceData.Team.LookupValue
            ExchangeAlias     = $ExchangeAlias
        }

        $global:WorkflowStatus = 'In progress'

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}