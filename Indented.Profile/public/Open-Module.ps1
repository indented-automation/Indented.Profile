function Open-Module {
    <#
    .SYNOPSIS
        Open the specified module in Visual Studio Code.

    .DESCRIPTION
        Open the specified module in Visual Studio Code.
    #>

    [CmdletBinding()]
    param (
        # The name of the module to open.
        [Parameter(Mandatory)]
        [string]$ModuleName,

        # The version of the module to open.
        [Version]$Version
    )

    Get-Module $ModuleName |
        Where-Object { -not $Version -or $_.Version -eq $Version } |
        Sort-Object Version -Descending |
        Select-Object -First 1 |
        ForEach-Object { code $_.ModuleBase }
}
