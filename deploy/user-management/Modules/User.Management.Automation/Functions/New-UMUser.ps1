function New-UMUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseBOMForUnicodeEncodedFile", "", Justification="Not sure why this test fails - need to investigate further")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "", Justification="By design - used to create initial password which have to be changed after first logon")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="By design - used to track global status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="By design - function is not intended for interactive use - hence ShouldProsess is not of any value")]
    param (
        $CompanyData,
        $DepartmentData,
        $UserData
    )

    if ($global:WorkflowStatus -eq 'In progress') {

        Write-Log -LogEntry 'Company data:'
        $CompanyData.PSObject.Properties | ForEach-Object { Write-Log -LogEntry  "$($_.Name) : $($_.Value)" }

        Write-Log -LogEntry 'Department data:'
        $DepartmentData.PSObject.Properties | ForEach-Object { Write-Log -LogEntry  "$($_.Name) : $($_.Value)" }

        Write-Log -LogEntry 'User data:'
        $UserData.PSObject.Properties | ForEach-Object { Write-Log -LogEntry  "$($_.Name) : $($_.Value)" }

        switch ($DepartmentData.UserDirectory) {

            #  'AzureAD' {}

            default {

                # Provision user to on-prem Active Directory

                $samaccountname = $UserData.UserName
                $ThirdCharacter = [int][char]$samaccountname[2]

                do {

                    Write-Log -LogEntry "Testing whether username $samaccountname already exist" -PassThru

                    $ADUser = Get-ADUser -Filter 'samaccountname -eq $samaccountname'

                    $ThirdCharacter++

                    if ($ADUser) {

                        $samaccountnamepart1 = $samaccountname[0..2] -join ''
                        $samaccountnamepart2 = $samaccountname[3..5] -join ''
                        $samaccountnamepart1 = ($samaccountnamepart1[0..1] + [char]$ThirdCharacter) -join ''
                        $samaccountname = $samaccountnamepart1 + $samaccountnamepart2

                    }

                }
                until ($null -eq $ADUser)

                if ($UserData.UserName -ne $samaccountname) {

                    Write-Log -LogEntry "Username $($UserData.UserName) already exist - updating username to next available: $samaccountname" -PassThru

                    $global:UserData.Username = $samaccountname
                    $global:UserData.UserPrincipalName = $samaccountname + '@' + $CompanyData.Domain

                } else {

                    Write-Log -LogEntry "Username $samaccountname does not exist - creating user" -PassThru

                }

                if (-not ($ADUser)) {

                    Write-Log -LogEntry "User $samaccountname does not already exist in Active Directory - creating" -PassThru

                    $global:InitialPassword = New-Password

                    $Parameters = @{}
                    $Parameters.Add('AccountPassword', (ConvertTo-SecureString -String $InitialPassword -AsPlainText -Force))
                    $Parameters.Add('Credential', $ActiveDirectoryCredential)
                    $Parameters.Add('Enabled', $true)
                    $Parameters.Add('Passthru', $true)
                    $Parameters.Add('ErrorAction', $true)

                    $OtherAttributes = @{}

                    if ($UserData.FirstName) {

                        $Parameters.Add('GivenName', $UserData.FirstName)

                    }

                    if ($UserData.LastName) {

                        $Parameters.Add('SurName', $UserData.LastName)

                    }

                    if ($UserData.DisplayName) {

                        $Parameters.Add('DisplayName', $UserData.DisplayName)
                        $Parameters.Add('Name', $UserData.DisplayName)

                    }

                    if ($UserData.UserName) {

                        $Parameters.Add('SamAccountName', $UserData.UserName)

                    }

                    if ($UserData.UserPrincipalName) {

                        $Parameters.Add('UserPrincipalName', $UserData.UserPrincipalName)
                        $Parameters.Add('EmailAddress', $UserData.UserPrincipalName)

                    }

                    if ($UserData.JobTitle) {

                        $Parameters.Add('Title', $UserData.JobTitle)

                    }

                    if ($UserData.MobilePhone) {

                        $Parameters.Add('MobilePhone', $UserData.MobilePhone)

                    }

                    if ($UserData.Manager) {

                        $ManagerEmail = $UserData.Manager
                        $ManagerADUser = Get-ADUser -Filter 'mail -eq $ManagerEmail'

                        if ($ManagerADUser) {

                            $Parameters.Add('Manager', $ManagerADUser)
                        }

                    }

                    if ($DepartmentData.Name) {

                        $Parameters.Add('Department', $DepartmentData.Name)

                    }

                    if ($TeamData.Name) {

                        $Parameters.Add('Description', $TeamData.Name)

                    } elseif ($DepartmentData.Name) {

                        $Parameters.Add('Description', $DepartmentData.Name)

                    }

                    if ($DepartmentData.OUPath) {

                        $Parameters.Add('Path', $DepartmentData.OUPath)

                    }

                    if ($CompanyData.City) {

                        $Parameters.Add('City', $CompanyData.City)

                    }

                    if ($CompanyData.StreetAddress) {

                        $Parameters.Add('StreetAddress', $CompanyData.StreetAddress)

                    }

                    if ($CompanyData.PostalCode) {

                        $Parameters.Add('PostalCode', $CompanyData.PostalCode)

                    }

                    if ($CompanyData.CountryAbbriviation) {

                        $Parameters.Add('Country', $CompanyData.CountryAbbriviation)

                    }

                    if ($CompanyData.Country) {

                        $OtherAttributes.Add('co', $CompanyData.Country)

                    }

                    if ($CompanyData.CountryCode) {

                        $OtherAttributes.Add('countryCode', [int]$CompanyData.CountryCode)


                    }

                    if ($CompanyData.Name) {

                        $Parameters.Add('Company', $CompanyData.Name)

                    }

                    if ($OtherAttributes.Count -gt 0) {

                        $Parameters.Add('OtherAttributes', $OtherAttributes)

                    }

                    try {

                        New-ADUser @Parameters

                        $global:WorkflowStatus = 'In progress'
                        $global:Status = 'User creation completed'

                    }

                    catch {

                        $global:WorkflowStatus = 'Completed'
                        $global:Status = "User creation failed - aborting. Error message: $($_.Exception.Message)"

                            Write-Log -LogEntry $Status -LogType Error

                    }

                }

            }

        }

    } else {

        Write-Log -LogEntry 'Workflow status is not "In progress" - skipping' -LogType Warning

    }

}