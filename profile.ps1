#
# Functions
#

function prompt {
    $Path = $executionContext.SessionState.Path.CurrentLocation

    Write-Host ""
    if ((Get-GitStatus) -and $Path -match 'Development\\([^\\]+)') {
        Write-Host "<" -ForegroundColor White -NoNewLine
        Write-Host $matches[1] -ForegroundColor Green -NoNewLine
        Write-VcsStatus
        Write-Host "> " -ForegroundColor White -NoNewLine
    }
    Write-Host "[" -ForegroundColor White -NoNewLine
    Write-Host $Path -ForegroundColor DarkGray -NoNewLine
    Write-Host "]" -ForegroundColor White
    "PS> "
}

function Restart-Console {
    Start-Process Powershell -ArgumentList '-NoExit', '-Command', "Set-Location $($pwd.Path)"
    exit
}

function Set-ConsoleDefaults {
    Set-ItemProperty -Path 'HKCU:\Console' -Name 'FaceName' -Value 'Lucida Console'
    Set-ItemProperty -Path 'HKCU:\Console' -Name 'FontSize' -Value 0x000c0007
    Set-ItemProperty -Path 'HKCU:\Console' -Name 'QuickEdit' -Value 0x00000001
    Set-ItemProperty -Path 'HKCU:\Console' -Name 'ScreenBufferSize' -Value 0x270f0078
    Set-ItemProperty -Path 'HKCU:\Console' -Name 'ScreenColors' -Value 0x0000000F
    Set-ItemProperty -Path 'HKCU:\Console' -Name 'WindowSize' -Value 0x00460078
}

#
# Window appearance
#

Set-ConsoleDefaults

# WindowTitle
$isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]"Administrator"
)
$host.UI.RawUI.WindowTitle = '{0}{1}{2} - Windows PowerShell' -f
    $env:USERNAME,
    $(if ($isAdministrator) { ' (Administrator)' } else { '' }),
    $(if ([IntPtr]::Size -eq 4) { ' (32-bit)' } else { '' })
Remove-Variable isAdministrator

$host.PrivateData.DebugForegroundColor = 'Cyan'
$host.PrivateData.VerboseForegroundColor = 'Green'

#
# Aliases
#

New-Alias -Name grep -Value Select-String

#
# Start path
#

if ($pwd.Path -eq 'C:\Windows\System32') {
  Set-Location "C:\Development"
}
if ($env:PSMODULEPATH.Split(';') -notcontains 'C:\Development') {
    [System.Environment]::SetEnvironmentVariable(
        'PSMODULEPATH',
        ('C:\Development;{0}' -f $env:PSMODULEPATH),
        'User'
    )
    $env:PSMODULEPATH = [System.Environment]::GetEnvironmentVariable('PSMODULEPATH')
}

#
# Import modules
#

if (Test-Path "$env:LOCALAPPDATA\GitHub\shell.ps1") {
    . (Resolve-Path "$env:LOCALAPPDATA\GitHub\shell.ps1")
    Import-Module "$env:github_posh_git\posh-git.psm1"
    $GitPromptSettings.EnableWindowTitle = $false
}

Write-Host "MODULES:"
Write-Host

Get-Module | ForEach-Object { Write-Host $_.Name }
Write-Host