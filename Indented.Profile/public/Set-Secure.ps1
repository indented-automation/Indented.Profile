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
    $folder = Split-Path -Path $path -Parent
    if (Test-Path $path) {
        $credential = Get-Credential (Get-Secure $Name -NoClipboard).Username
    } else {
        if (-not(Test-Path $folder)) {
            New-Item -Path $folder -ItemType "Directory" -ErrorAction Stop
        }
        $credential = Get-Credential
        if ($null -eq $credential) { return }
    }
    $credential | Export-CliXml $path
}