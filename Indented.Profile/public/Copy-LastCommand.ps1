function Copy-LastCommand {
    [CmdletBinding()]
    [Alias('last')]
    param ( )

    Get-History -Count 1 |
        Select-Object -ExpandProperty CommandLine |
        Set-Clipboard
}