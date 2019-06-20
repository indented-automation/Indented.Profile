---
external help file: Indented.Profile-help.xml
Module Name: Indented.Profile
online version:
schema: 2.0.0
---

# Resolve-ParameterSet

## SYNOPSIS
Resolve a list of parameter names to a parameter set name.

## SYNTAX

### ByName
```
Resolve-ParameterSet [-Name] <String> -ParameterName <String[]> [<CommonParameters>]
```

### FromCommandInfo
```
Resolve-ParameterSet -CommandInfo <CommandInfo> -ParameterName <String[]> [<CommonParameters>]
```

## DESCRIPTION
Resolve a list of parameter names to a parameter set name.

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

### -ParameterName
A list of parameter names.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
