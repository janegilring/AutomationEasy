---
external help file: User.Management.Automation-help.xml
Module Name: User.Management.Automation
online version:
schema: 2.0.0
---

# Send-UMNewUserWelcomeEmail

## SYNOPSIS

Sends a welcome e-mail to a new user.

## SYNTAX

```powershell
Send-UMNewUserWelcomeEmail [[-UserData] <Object>] [[-DepartmentData] <Object>]
 [[-ExchangeOnlineCredential] <PSCredential>] [[-MailFrom] <Object>] [[-SmtpServer] <Object>]
 [[-SmtpPort] <Object>] [[-MailEncoding] <Object>]
```

## DESCRIPTION

This function sends a welcome e-mail to a new user.
The subject, bottom and top content of the e-mail is dynamically retrieved from a Sharepoint list - making it possible for IT Operations to customize the content without changing any PowerShell code.
The command will wait for the new user`s mailbox to be provsioned in Exchange Online (function can be customized to also work against an on-prem Exchange service).

## EXAMPLES

### Example 1

```powershell
PS C:\> Send-UMNewUserWelcomeEmail -UserData $UserData
```

$UserData is the output of New-UMUser.

## PARAMETERS

### -DepartmentData

The DepartmentData parameter expects the output that is created by the function Get-UMDepartmentData

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExchangeOnlineCredential

Credentials Exchange Online - used for relaying the e-mail message

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MailEncoding

Encoding for the e-mail message to be sent

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MailFrom

From address

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmtpPort

SMTP port

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmtpServer

SMTP Server

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserData

The UserData parameter expects the output that is created by the function New-UMUserData

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
