---
external help file: Indented.Profile-help.xml
Module Name: Indented.Profile
online version:
schema: 2.0.0
---

# Get-Syntax

## SYNOPSIS
Get the syntax for a command.

## SYNTAX

### ByName
```
Get-Syntax [-Name] <String> [-Long] [<CommonParameters>]
```

### FromCommandInfo
```
Get-Syntax -CommandInfo <CommandInfo> [-Long] [<CommonParameters>]
```

## DESCRIPTION
Get the syntax for a command.
A wrapper for Get-Command -Syntax.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Name
The name of a command.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CommandInfo
A CommandInfo object.

```yaml
Type: CommandInfo
Parameter Sets: FromCommandInfo
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Long
Write syntax output in a vertical format.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
