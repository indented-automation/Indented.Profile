function Get-ParameterInfo {
    <#
    .SYNOPSIS
        Creates a summary of a parameter from a command.
    .DESCRIPTION
        Creates a summary of a parameter from a command.
    #>

    [CmdletBinding()]
    [Alias('paraminfo')]
    param (
        # The name of a command.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        # A CommandInfo object.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

        # The name of a parameter. Supports wildcards.
        [Parameter(Position = 2, ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'FromCommandInfo')]
        [String]$ParameterName = '*'
    )

    begin {
        $commonParams = @(
            [System.Management.Automation.Internal.CommonParameters].GetProperties().Name
            [System.Management.Automation.Internal.ShouldProcessParameters].GetProperties().Name
            [System.Management.Automation.Internal.TransactionParameters].GetProperties().Name
        )
    }

    process {
        $CommandInfo = Get-CommandInfo @psboundparameters

        foreach ($parameterSet in $CommandInfo.ParameterSets) {
            foreach ($parameter in $parameterSet.Parameters) {
                if ($parameter.Name -notin $commonParams -and $parameter.Name -like $ParameterName) {
                    [PSCustomObject]@{
                        CommandName       = $CommandInfo.Name
                        Name              = $parameter.Name
                        Aliases           = $parameter.Aliases
                        Type              = $parameter.ParameterType.Name
                        Position          = @('None', $parameter.Position)[$parameter.Position -gt [Int32]::MinValue]
                        ParameterSetName  = $parameterSet.Name
                        Pipeline          = @(
                            @('', 'None')[-not $parameter.ValueFromPipeline -and -not $parameter.ValueFromPipelineByPropertyName]
                            @('', 'ByValue')[$parameter.ValueFromPipeline]
                            @('', 'ByPropertyName')[$parameter.ValueFromPipelineByPropertyName]
                        ) -ne '' -join ', '
                        FromRemainingArgs = $parameter.ValueFromRemainingArguments
                        Validation        = $parameter.Attributes |
                            Where-Object { $_ -is [System.Management.Automation.ValidateArgumentsAttribute] } |
                            ForEach-Object { $_.GetType().Name -replace 'Attribute$' }
                        Attributes        = $parameter.Attributes
                        PSTypeName        = 'Indented.ParamInfo'
                    }
                }
            }
        }
    }
}