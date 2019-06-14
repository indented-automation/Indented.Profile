function Restart-Console {
    Start-Process (Get-Process -Id $PID).Path -ArgumentList @(
        '-NoExit'
        '-Command'
        "Set-Location $($pwd.Path)"
    )
    exit
}
