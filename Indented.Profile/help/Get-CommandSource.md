---
external help file: Indented.Profile-help.xml
Module Name: Indented.Profile
online version:
schema: 2.0.0
---

# Get-CommandSource

## SYNOPSIS
Get the source of a command.

## SYNTAX

### ByName
```
Get-CommandSource [-Name] <String> [-ModuleName <String>] [-OpenWithCode] [<CommonParameters>]
```

### FromCommandInfo
```
Get-CommandSource -CommandInfo <CommandInfo> [-ModuleName <String>] [-OpenWithCode] [<CommonParameters>]
```

## DESCRIPTION
Get the source of a command.

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

### -ModuleName
If a command is not public, a module name may be specified to get the command source.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OpenWithCode
If the command is a function, open code with the file content.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Code

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
