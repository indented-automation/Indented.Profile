function Get-CommandInfo {
    <#
    .SYNOPSIS
        Get-Command helper.
    .DESCRIPTION
        Get-Command helper.
    #>

    [CmdletBinding()]
    param (
        # The name of a command.
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [String]$Name,

        # A CommandInfo object.
        [Parameter(Mandatory, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

        # Claims and discards any other supplied arguments.
        [Parameter(ValueFromRemainingArguments, DontShow)]
        $EaterOfArgs
    )

    if ($Name) {
        $CommandInfo = Get-Command -Name $Name
    }

    if ($CommandInfo -is [System.Management.Automation.AliasInfo]) {
        $CommandInfo = $CommandInfo.ResolvedCommand
    }

    return $CommandInfo
}