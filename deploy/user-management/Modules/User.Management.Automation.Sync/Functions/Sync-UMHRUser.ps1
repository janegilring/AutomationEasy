function Sync-UMHRUser {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="By design - used to track workflow status")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification="Need to look into this later on")]
    param (
        $Settings,
        $HRUsers,
        $ADUsers
    )

    if ($global:WorkflowStatus -eq 'In progress') {

if (Test-Path -Path 'Variable:\settings') {

    if ($settings.WhatIf -eq 'True') {
        $whatif = $True
    }
    else {
        $whatif = $False
    }

    Write-Log -LogEntry '--- Sync ---' -PassThru

    #variables for counting changes
    $CreatedCount = 0
    $ModifiedCount = 0
    $softmappedCount = 0
    $disabledCount = 0

    $CreateIf = @('1','4','R','5') #custom setting for determing source usertypes to create in AD. other users will be ignored if doesn't exist in AD.

    #go through each user from source, and verify settings
    foreach($user in $HRUsers){

        #added support for rulebased attribute definition in config. combining multiple source attributes into one target attribute as strings.
        ForEach($attribute in [array](($settings.AttributeMappings | Where-Object{$_.type -like 'AD-String'}))){
            #adding rule result as new attribute on source object.
                if($attribute.Rule){
                    $result = $attribute.Rule
                    $props = $user | Get-Member | Where-Object{$_.membertype -like "Property"}
                    foreach($prop in $props.Name){
                        $result = $result -Replace "%$prop%",$($user.$($prop))
                    }
                    $user | Add-Member -NotePropertyName $($attribute.Source) -NotePropertyValue $result -Force
                }
        }

        if((get-date $($user.ANSATT_TIL)) -lt (get-date)){
            #user end date passed. Check if exist in AD and if, perform disabling.
            if($settings.Actions -contains "Deprovision"){
                #only perform disable if settings contain "Deprovision" action.
                $Aduser = $ADUserTable.item($user.$($settings.ObjectMapping.source))
                if($Aduser){
                    #User does exist in AD
                    if($Aduser.DistinguishedName -notlike ("*" + $($settings.DisabledUsersOU))){
                        #user isn't in disabled-ou
                       $disabledCount += 1
                       Write-Log -LogEntry "User $($Aduser.$($settings.ObjectMapping.target)) post end-date. Disabling.." -PassThru
                       try{
                        Disable-UMUser -aduser $Aduser -WhatIf:$whatif
                       }
                       catch{
                            Write-Log -LogEntry "Failed to disable user" -PassThru -LogType Warning
                            Write-Log -LogEntry "$($_.exception.message.replace("`n"," "))" -PassThru -LogType Warning
                       }

                    }
                }
            }
        }
        else{
            #User hasn't reached end-date.

            #getting aduser from hash-table
            $Aduser = $ADUserTable.item($user.$($settings.ObjectMapping.source))
            if($Aduser){
                #user found
                if($settings.Actions -contains "Update"){
                if($Aduser.DistinguishedName -like ("*" + $($settings.DisabledUsersOU))){
                    #user is in disabled ou and shouldn't be
                    if($CreateIf.Contains($($user.RESSURSTYPE))){
                        #user is of type that should be autocreated. Only logging this, but later maybe auto-enable.
                        Write-Log -LogEntry "Bruker $($Aduser.$($settings.ObjectMapping.target)) is disabled in AD but shouldn't be." -PassThru -LogType Warning
                    }
                    continue
                }
                #creating variable that will be $true if change is required. We want to identify all changes and make them in one write to AD.
                $Modified = $false
                $update = $false
                #region ad-string changes - first checking "standard" attributes
                foreach($attribute in [array](($settings.AttributeMappings | Where-Object{$_.type -like 'AD-String'}))){
                    if($user.$($attribute.source) -like " "){$user.$($attribute.source) = ""} #some fields in source had a space in sted of empty

                    #if source attribute has no value and settingsfile tells to not overwrite ad with an empty value.
                    if(!($user.$($attribute.source)) -and $attribute.IgnoreEmpty -like "True"){
                        $user.$($attribute.source) = $Aduser.$($attribute.target)
                    }

                    if(($user.$($attribute.source))-notlike($Aduser.$($attribute.target))){
                        #source and target value is different
                        Write-Log -LogEntry "Updating $($attribute.target) for user $($Aduser.$($settings.ObjectMapping.target))" -PassThru
                        Write-Log -LogEntry "Old value $($Aduser.$($attribute.target))" -PassThru
                        Write-Log -LogEntry "New value $($user.$($attribute.source))" -PassThru
                        if(($user.$($attribute.source)) -eq ""){
                            $aduser.$($attribute.target) = $null #source value is emptystring not $null amd set-aduser need $null
                        }
                        else{
                            $aduser.$($attribute.target) = ($user.$($attribute.source))
                        }
                        $update = $true
                    }
                    else{
                        #same value - do nothing -maybe verbose logging?
                    }
                }
                if($update){
                    #one or more standard attrubtes changed. Write to AD.
                    try{
                        $update = $false
                        if($whatif -like "false"){
                            Set-ADUser -Instance $Aduser -WhatIf:$whatif
                        }
                        $Modified = $true
                    }
                    catch{
                        Write-Log -LogEntry "Set-aduser failed.." -PassThru -LogType Warning
                        Write-Log -LogEntry "$($_.exception.message.replace("`n"," "))" -PassThru -LogType Warning
                    }
                }
                #endregion

                #region samaccountname changes
                foreach($attribute in [array](($settings.AttributeMappings | Where-Object{$_.type -like 'AD-Login'}))){
                    if(($user.$($attribute.source))-notlike($Aduser.$($attribute.target))){
                        #mismatch
                        Write-Log -LogEntry "Updating $($attribute.target) for user $($Aduser.$($settings.ObjectMapping.target))" -PassThru -LogType Warning
                        Write-Log -LogEntry "Old value $($Aduser.$($attribute.target))" -PassThru -LogType Warning
                        Write-Log -LogEntry "New value $($user.$($attribute.source))" -PassThru -LogType Warning
                        $Modified = $true
                        #Set-Usersamaccountname - function not ready. Not needed yet
                    }
                    else{
                        #same value do nothing
                    }
                }
                #endregion

                #region Object name changes
                foreach($attribute in [array](($settings.AttributeMappings | Where-Object{$_.type -like 'AD-Name'}))){
                    if(($user.$($attribute.source))-notlike($Aduser.$($attribute.target))){
                        #mismatch
                        Write-Log -LogEntry "Updating $($attribute.target) for bruker $($Aduser.$($settings.ObjectMapping.target))" -PassThru  -LogType Warning
                        Write-Log -LogEntry "Old value $($Aduser.$($attribute.target))" -PassThru -LogType Warning
                        Write-Log -LogEntry "New value $($user.$($attribute.source))" -PassThru  -LogType Warning
                        try{
                            #standard ad function. Maybe need special function
                            Rename-ADObject -Identity $Aduser.ObjectGUID -NewName ($user.$($attribute.source)) -WhatIf:$whatif
                            $Modified = $true
                        }
                        catch{
                            Write-Log -LogEntry "Rename-adobject failed.." -PassThru -LogType Warning
                            Write-Log -LogEntry "$($_.exception.message.replace("`n"," "))" -PassThru -LogType Warning
                        }
                    }
                    else{
                        #match
                    }
                }
                #endregion

                #region manager changes - need to resolve dn
                foreach($attribute in [array](($settings.AttributeMappings | Where-Object{$_.type -like 'AD-Manager'}))){
                    $ManagerDN = Get-UMUserManagerDN -hruser $user
                    if($ManagerDN -notlike ($Aduser.$($attribute.target))){
                        #mismatch
                        Write-Log -LogEntry "Updating $($attribute.target) for bruker $($Aduser.$($settings.ObjectMapping.target))" -PassThru
                        Write-Log -LogEntry "Old value $($Aduser.$($attribute.target))" -PassThru
                        Write-Log -LogEntry "New value $($ManagerDN)" -PassThru
                        try{
                            Set-ADUser -Identity $Aduser.ObjectGUID -Manager $ManagerDN -WhatIf:$whatif
                            $Modified = $true
                        }
                        catch{
                            Write-Log -LogEntry "Set-Aduser failed.." -PassThru -LogType Warning
                            Write-Log -LogEntry "$($_.exception.message.replace("`n"," "))" -PassThru -LogType Warning
                        }

                    }
                    else{
                        #match
                    }
                }
                #endregion

                #region email changes - new email-address from HR - custom actions.
                Foreach($attribute in [array](($settings.AttributeMappings | Where-Object{$_.type -like 'Exchange-PrimarySMTP'}))){
                    if(($user.$($attribute.source))-notlike ($Aduser.$($attribute.target))){
                        #check domain name format - simple chekc, could be verified against exchange accepteddomains etc.
                        if($user.$($attribute.source) -notlike "*@customerdomain.com"){
                            Write-Log -LogType Warning -LogEntry "User $($Aduser.$($settings.ObjectMapping.target)) has an invalid email-domain in source" -PassThru -LogType Warning
                            Write-Log -LogEntry "Source: $($user.$($attribute.source))" -PassThr -LogType Warning
                            continue
                        }
                        #mismatch
                        Write-Log -LogEntry "Updating $($attribute.target) for bruker $($Aduser.$($settings.ObjectMapping.target))" -PassThru
                        Write-Log -LogEntry "Old value $($Aduser.$($attribute.target))" -PassThru
                        Write-Log -LogEntry "New value $($user.$($attribute.source))" -PassThru
                        try{
                            Set-UMUserPrimarySMTP -oldsmtp ($Aduser.$($attribute.target)) -newsmtp ($user.$($attribute.source)) -aduser $Aduser -WhatIf:$whatif
                            $Modified = $true
                        }
                        catch{
                            Write-Log -LogEntry "Set smtp failed.." -PassThru -LogType Warning
                            Write-Log -LogEntry "$($_.exception.message.replace("`n"," "))" -PassThru -LogType Warning
                        }
                    }
                    else{
                        #match
                    }

                }
                #endregion

                if($Modified){$ModifiedCount +=1}

                }
            }

            #Aduser doesn't exist - create
            else{
                #if settings action says to create..
                if($settings.Actions -contains "Provision"){
                    if($CreateIf.Contains($($user.RESSURSTYPE))){
                        #Softmapping was added because some users existed in AD without having mapping-attribute set. If softmapping is enabled use a custom search to identify the user and set the mapping attriubte.
                        $Softmapped = $false
                        if($settings.SoftMapping -like "True"){
                            Write-Log -LogEntry "No Aduser with $($user.$($settings.ObjectMapping.source)) in AD - Try Softmapping:" -PassThru
                            $Aduser = Find-UMSoftmappedADuser -hruser $user
                            if($Aduser){
                                $Softmapped = $true
                                $softmappedCount += 1
                                Write-Log -LogEntry "Found user in ad -  $($Aduser.Name). Setting $($settings.ObjectMapping.target).. $($user.$($settings.ObjectMapping.source))" -PassThru
                                $Aduser | Set-ADUser -EmployeeNumber $($user.$($settings.ObjectMapping.source)) -WhatIf:$whatif
                            }
                        }
                        #user doesn't exist and softmapping didn't succeed. Create user.
                        if ($Softmapped -eq $false){
                            $CreatedCount += 1
                            Write-Log -LogEntry "User $($user.$($settings.ObjectMapping.source)) is not in AD - Create." -PassThru
                            try{
                                New-UMSyncUser -hruser $user -WhatIf:$whatif
                                if($whatif -eq $False){Write-Log -LogEntry "User successfully created in AD" -PassThru}
                            }
                            catch{
                                Write-Log -LogEntry "Failed to create user." -PassThru -LogType Warning
                                Write-Log -LogEntry "$($_.exception.message.replace("`n"," "))" -PassThru -LogType Warning
                            }
                        }
                    }
                }
            }
            #endregion
        }
    }
    if($CreatedCount -gt 0){
         Write-Log -LogEntry "Created $($CreatedCount) users in AD." -PassThru
    }
    if($ModifiedCount -gt 0){
         Write-Log -LogEntry "Modified $($ModifiedCount) users in AD." -PassThru
    }
    if($softmappedCount -gt 0){
         Write-Log -LogEntry "Softmapped $($softmappedCount) users in AD." -PassThru
    }
    if($disabledCount -gt 0){
         Write-Log -LogEntry "Disabled $($disabledCount) users in AD." -PassThru
    }
}

} else {

    Write-Log -LogEntry 'Workflow status is not "In progress" - skipping Sync-UMHRUser' -LogType Error

}

}