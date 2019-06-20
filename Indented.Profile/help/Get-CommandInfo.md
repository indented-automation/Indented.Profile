---
external help file: Indented.Profile-help.xml
Module Name: Indented.Profile
online version:
schema: 2.0.0
---

# Get-CommandInfo

## SYNOPSIS
Get-Command helper.

## SYNTAX

### ByName
```
Get-CommandInfo -Name <String> [-ModuleName <String>] [-EaterOfArgs <Object>] [<CommonParameters>]
```

### FromCommandInfo
```
Get-CommandInfo -CommandInfo <CommandInfo> [-ModuleName <String>] [-EaterOfArgs <Object>] [<CommonParameters>]
```

## DESCRIPTION
Get-Command helper.

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
Position: Named
Default value: None
Accept pipeline input: False
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
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
If a module name is specified the private / internal scope of the module will be searched.

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

### -EaterOfArgs
Claims and discards any other supplied arguments.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
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
