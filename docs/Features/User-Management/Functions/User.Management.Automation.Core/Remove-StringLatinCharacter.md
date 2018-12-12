---
external help file: User.Management.Automation.Core-help.xml
Module Name: User.Management.Automation.Core
online version:
schema: 2.0.0
---

# Remove-StringLatinCharacter

## SYNOPSIS

Removes special characters

## SYNTAX

```powershell
Remove-StringLatinCharacter [[-String] <String>]
```

## DESCRIPTION

This function will remove special characters from a string based on the Cyrillic alphabet

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-StringLatinCharacter -String 'Vær og vind'
```

Will convert 'Vær og vind' to 'Var og vind'

## PARAMETERS

### -String

The string to remove special characters from

```yaml
Type: String
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
