function Get-Secure {
    <#
    .SYNOPSIS
        Get a stored credential.

    .DESCRIPTION
        Get a stored credential.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Get')]
    param (
        # The name which identifies a credential.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = 'Get')]
        [string]$Name,

        # List all available credentials.
        [Parameter(Mandatory, ParameterSetName = 'List')]
        [switch]$List,

        # Do not copy the password to the clipboard.
        [switch]$NoClipboard,

        # Store the password in an environment variable instead of returning a credential.
        [switch]$AsEnvironmentVariable
    )

    begin {
        if ($List) {
            Get-ChildItem $home\Documents\Keys | Select-Object @(
                @{ Name = 'Name'; Expression = 'BaseName' }
                @{ Name = 'Created'; Expression = 'CreationTime' }
            )
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'Get') {
            $path = '{0}\Documents\Keys\{1}.xml' -f $home, $Name
            if (Test-Path $path) {
                $credential = Import-Clixml -Path ('{0}\Documents\Keys\{1}.xml' -f $home, $Name)
                if ($AsEnvironmentVariable) {
                    Set-Item -Path env:$Name -Value $credential.GetNetworkCredential().Password
                } else {
                    if (-not $NoClipboard) {
                        $credential.GetNetworkCredential().Password | Set-Clipboard
                    }
                    $credential
                }
            }
        }
    }
}
