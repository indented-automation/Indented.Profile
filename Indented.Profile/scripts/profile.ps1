Import-Module Indented.Profile, Terminal-Icons

Update-WindowTitle

Set-PSReadlineOption -BellStyle None

'NugetApiKey', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY' | Get-Secure -AsEnvironmentVariable

$params = @{
    Name  = 'msbuild'
    Value = Join-Path (Get-ItemPropertyValue -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0 -Name MSBuildToolsPath) -ChildPath msbuild.exe
}
New-Alias @params
Remove-Variable params

if ($pwd.Path -notmatch '^C:\\Development') {
    Set-Location "C:\Development"
}