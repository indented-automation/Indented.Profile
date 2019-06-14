function Get-CommandInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Mandatory, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

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