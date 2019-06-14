function Copy-LastCommand {
    <#
    .SYNOPSIS
        Copy the last command to the clipboard.
    .DESCRIPTION
        Copy the last command to the clipboard.
    #>

    [CmdletBinding()]
    [Alias('last')]
    param ( )

    Get-History -Count 1 |
        Select-Object -ExpandProperty CommandLine |
        Set-Clipboard
}