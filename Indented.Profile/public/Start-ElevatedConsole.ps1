using namespace System.Security.Principal

function Start-ElevatedConsole {
    <#
    .SYNOPSIS
        Creates a new elevated PowerShell session.

    .DESCRIPTION
        Creates a new elevated PowerShell session, supports all versions of PowerShell.
    #>

    [CmdletBinding()]
    [Alias('elevate')]
    param ( )

    $isAdministrator = ([WindowsPrincipal][WindowsIdentity]::GetCurrent()).IsInRole(
        [WindowsBuiltInRole]"Administrator"
    )

    if (-not $isAdministrator) {
        Start-Process (Get-Process -Id $PID).Path -Verb Runas -ArgumentList @(
            '-NoExit'
            '-Command'
            "Set-Location '$($pwd.Path)'"
        )
    }
}
