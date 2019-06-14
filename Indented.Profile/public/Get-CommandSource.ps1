function Get-CommandSource {
    [CmdletBinding()]
    [Alias('source')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo
    )

    process {
        try {
            $CommandInfo = Get-CommandInfo @psboundparameters

            if ($commandInfo -is [System.Management.Automation.CmdletInfo]) {
                $assembly = $commandInfo.ImplementingType.Assembly.Location
                $type = $commandInfo.ImplementingType.FullName

                if (Get-Command dnspy -ErrorAction SilentlyContinue) {
                    dnspy $assembly --select T:$type
                } elseif (Get-Command ilspy -ErrorAction SilentlyContinue) {
                    ilspy $assembly /navigateTo:T:$type
                } else {
                    throw 'No decompiler present'
                }
            } else {
                $commandInfo.Definition
            }
        } catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}