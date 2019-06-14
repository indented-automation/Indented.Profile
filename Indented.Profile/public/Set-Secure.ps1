function Set-Secure {
    <#
    .SYNOPSIS
        Store a credential.
    .DESCRIPTION
        Store a credential in an xml file created
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The name of the credential to set.
        [Parameter(Mandatory, Position = 1)]
        [String]$Name
    )

    $path = '{0}\Documents\Keys\{1}.xml' -f $home, $Name
    if (Test-Path $path) {
        $credential = Get-Credential (Get-Secure $Name -NoClipboard).Username
    } else {
        $credential = Get-Credential
    }
    $credential | Export-CliXml $path
}