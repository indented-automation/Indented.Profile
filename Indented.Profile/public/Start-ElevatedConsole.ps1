function Start-ElevatedConsole {
    [CmdletBinding()]
    [Alias('elevate')]
    param ( )

    $isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]"Administrator"
    )

    if (-not $isAdministrator) {
        Start-Process (Get-Process -Id $PID).Path -Verb Runas -ArgumentList @(
            '-NoExit'
            '-Command'
            "Set-Location $($pwd.Path)"
        )
    }
}