Import-Module Indented.Profile, Terminal-Icons

Update-WindowTitle

Set-PSReadLineOption -BellStyle None

'NugetApiKey' | Get-Secure -AsEnvironmentVariable

$params = @{
    Name  = 'msbuild'
    Value = Join-Path (Get-ItemPropertyValue -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0 -Name MSBuildToolsPath) -ChildPath msbuild.exe
}
New-Alias @params
Remove-Variable params

if ($pwd.Path -notmatch '^C:\\Development') {
    Set-Location "C:\Development"
}

if ($PSEdition -eq 'Core') {
    Set-PSReadLineOption -Colors @{
        Command   = "`e[92m"
        Operator  = "`e[97m"
        Parameter = "`e[97m"
        Variable  = "`e[96m"
    }
}

$env:ADPS_LoadDefaultDrive = 0
