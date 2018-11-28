---
external help file: User.Management.Automation.Core-help.xml
Module Name: User.Management.Automation.Core
online version:
schema: 2.0.0
---

# New-Password

## SYNOPSIS
Generate complex password(s).

## SYNTAX

### FixedLength (Default)
```
New-Password [-Length <Int32>] [-Type <String>] [-Amount <Int32>] [-IncludeSymbols] [-IncludeNumbers]
 [-IncludeUppercaseCharacters] [-IncludeLowercaseCharacters] [-AlwaysStartWith <String>] [-AsSecureString]
 [<CommonParameters>]
```

### VariableLength
```
New-Password [-MinimumPasswordLength <Int32>] [-MaximumPasswordLength <Int32>] [-Type <String>]
 [-Amount <Int32>] [-IncludeSymbols] [-IncludeNumbers] [-IncludeUppercaseCharacters]
 [-IncludeLowercaseCharacters] [-AlwaysStartWith <String>] [-AsSecureString] [<CommonParameters>]
```

## DESCRIPTION
This functions lets you generate either random passwords of the chosen complexity and length, or pronounceable passwords.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-Password
```

Will generate a random password.

### Example 2
```powershell
PS C:\> New-Password -Length 20
```

Will generate a random password 20 characters in length.

### Example 3
```powershell
PS C:\> New-Password -Min 12 -Max 20 -IncludeSymbols:$false -AlwaysStartWith Letter
```

Will generate a password between 12 and 20 characters in length that don't include symbols, but that always starts with a letter.

### Example 4
```powershell
PS C:\> New-Password -Type Pronounceable -Amount 10
```

Will generate 10 pronounceable passwords.

## PARAMETERS

### -AlwaysStartWith
{{Fill AlwaysStartWith Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: StartWith
Accepted values: Any, Letter, Number

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Amount
{{Fill Amount Description}}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Count

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsSecureString
{{Fill AsSecureString Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeLowercaseCharacters
{{Fill IncludeLowercaseCharacters Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Lowercase

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeNumbers
{{Fill IncludeNumbers Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Numbers

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSymbols
{{Fill IncludeSymbols Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Symbols

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeUppercaseCharacters
{{Fill IncludeUppercaseCharacters Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Uppercase

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Length
{{Fill Length Description}}

```yaml
Type: Int32
Parameter Sets: FixedLength
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaximumPasswordLength
{{Fill MaximumPasswordLength Description}}

```yaml
Type: Int32
Parameter Sets: VariableLength
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumPasswordLength
{{Fill MinimumPasswordLength Description}}

```yaml
Type: Int32
Parameter Sets: VariableLength
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
{{Fill Type Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Complex, Pronounceable

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS
System.String
System.Security.SecureString
### System.Object
## NOTES
                Author: Øyvind Kallstad
                Date: 19.09.2015
                Version: 1.2
## RELATED LINKS
https://communary.wordpress.com/