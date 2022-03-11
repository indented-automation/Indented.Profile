function Install-ProfileScript {
    <#
    .SYNOPSIS
        Install the profile script stored in this module.

    .DESCRIPTION
        Install the profile script stored in this module.
    #>

    [CmdletBinding()]
    param ( )

    $parent = Split-Path -Path $profile.CurrentUserAllHosts -Parent
    if (-not $parent) {
        $null = New-Item -Path $parent -ItemType Directory -Force
    }
    $params = @{
        Path        = Join-Path -Path $myinvocation.MyCommand.Module.ModuleBase -ChildPath 'scripts\profile.ps1'
        Destination = $profile.CurrentUserAllHosts
        Force       = $true
    }
    Copy-Item @params
}
