try {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'build.ps1')

    . $PSScriptRoot\Indented.Profile\scripts\prompt.ps1

    if ($module = Get-Module Indented.Profile -ListAvailable | Sort-Object Version | Select-Object -Last 1) {
        $destination = $module.ModuleBase -replace '\\(\d+\.)*\d+'
    } else {
        if ($PSVersion.Version.Major -gt 5) {
            $destination = Join-Path $env:USERPROFILE 'Documents\PowerShell\Modules\Indented.Profile'
        } else {
            $destination = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Modules\Indented.Profile'
        }
    }

    if (-not (Test-Path $destination)) {
        $null = New-Item -Path $destination -ItemType Directory -Force
    }

    Copy-Item $PSScriptRoot\build\Indented.Profile\* -Destination $destination -Recurse -Force
} catch {
    throw
}
