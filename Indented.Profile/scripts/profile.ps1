Import-Module Indented.Profile, Terminal-Icons

Update-WindowTitle

Set-PSReadlineOption -BellStyle None

'NugetApiKey', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY' | Get-Secure -AsEnvironmentVariable

if ($pwd.Path -notmatch '^C:\\Development') {
    Set-Location "C:\Development"
}