function Get-Secure {
    [CmdletBinding(DefaultParameterSetName = 'Get')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = 'Get')]
        [String]$Name,

        [Parameter(Mandatory, ParameterSetName = 'List')]
        [Switch]$List,

        [Switch]$NoClipboard,

        [Switch]$AsEnvironmentVariable
    )

    begin {
        if ($List) {
            Get-ChildItem $home\Documents\Keys |
                Select-Object @{n='Name';e={ $_.BaseName }},
                              @{n='Created';e={ $_.CreationTime }}
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'Get') {
            $path = '{0}\Documents\Keys\{1}.xml' -f $home, $Name
            if (Test-Path $path) {
                $credential = Import-CliXml ('{0}\Documents\Keys\{1}.xml' -f $home, $Name)
                if ($AsEnvironmentVariable) {
                    Set-Item env:$Name -Value $credential.GetNetworkCredential().Password
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