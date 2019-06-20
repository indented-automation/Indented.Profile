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

        # If a module name is specified the private / internal scope of the module will be searched.
        [String]$ModuleName,

        # Claims and discards any other supplied arguments.
        [Parameter(ValueFromRemainingArguments, DontShow)]
        $EaterOfArgs
    )

    if ($Name) {
        if ($ModuleName) {
            try {
                if (-not ($moduleInfo = Get-Module $ModuleName)) {
                    $moduleInfo = Import-Module $ModuleName -Global -PassThru
                }
                $CommandInfo = & $moduleInfo ([ScriptBlock]::Create('Get-Command {0}' -f $Name))
            } catch {
                $pscmdlet.ThrowTerminatingError($_)
            }
        } else {
            $CommandInfo = Get-Command -Name $Name
        }
    }

    if ($CommandInfo -is [System.Management.Automation.AliasInfo]) {
        $CommandInfo = $CommandInfo.ResolvedCommand
    }

    return $CommandInfo
}