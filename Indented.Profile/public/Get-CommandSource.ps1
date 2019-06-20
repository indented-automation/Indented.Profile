function Get-CommandSource {
    <#
    .SYNOPSIS
        Get the source of a command.
    .DESCRIPTION
        Get the source of a command.
    #>

    [CmdletBinding()]
    [Alias('source')]
    param (
        # The name of a command.
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        # A CommandInfo object.
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

        # If a command is not public, a module name may be specified to get the command source.
        [String]$ModuleName,

        # If the command is a function, open code with the file content.
        [Alias('Code')]
        [Switch]$OpenWithCode
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
                if ($OpenWithCode) {
                    $process = [System.Diagnostics.Process]@{
                        StartInfo = [System.Diagnostics.ProcessStartInfo]@{
                            FileName              = (Get-Command code).Source
                            Arguments             = '-'
                            RedirectStandardInput = $true
                            UseShellExecute       = $false
                        }
                    }
                    if ($process.Start()) {
                        $streamWriter = [System.IO.StreamWriter]$process.StandardInput
                        $streamWriter.WriteLine('function {0} {{' -f $commandInfo.Name)
                        $streamWriter.Write($commandInfo.Definition)
                        $streamWriter.WriteLine('}')
                        $streamWriter.Close()
                    }
                } else {
                    $commandInfo.Definition
                }
            }
        } catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}