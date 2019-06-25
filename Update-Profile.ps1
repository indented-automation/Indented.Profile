try {
    Start-Build -BuildType Setup, Build

    . $psscriptroot\Indented.Profile\public\prompt.ps1

    if ($module = Get-Module Indented.Profile -ListAvailable) {
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

    Copy-Item $psscriptroot\build\Indented.Profile\* -Destination $destination -Recurse -Force
} catch {
    throw
}