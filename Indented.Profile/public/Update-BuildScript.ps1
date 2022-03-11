function Update-BuildScript {
    <#
    .SYNOPSIS
        Update the build script and configuration for the current project.
    #>

    [CmdletBinding()]
    param ( )

    $moduleManifest = Get-ChildItem -Path '*\*.psd1' |
        Where-Object { $_.BaseName -eq $_.Directory.Name }
    $moduleName = $moduleManifest.BaseName
    if (-not ($moduleName)) {
        Write-Warning 'Cannot find a PowerShell module manifest'

        return
    }

    $buildConfig = Join-Path -Path $moduleManifest.Directory.FullName -ChildPath 'build.psd1'
    if (-not (Test-Path $buildConfig)) {
        [Ordered]@{
            ModuleManifest           = $moduleManifest.Name
            OutputDirectory          = "../build"
            VersionedOutputDirectory = $true
            SourceDirectories        = @(
                'Enum'
                'Class'
                'Private'
                'Public'
            )
        } | Export-Metadata -Path $buildConfig
    }

    $moduleBase = $myinvocation.MyCommand.Module.ModuleBase
    $templates = Join-Path -Path $moduleBase -ChildPath 'templates'

    $buildScriptPath = Join-Path -Path $templates -ChildPath 'build.ps1'
    Copy-Item -Path $buildScriptPath -Destination . -Force

    $scriptAnalyzerSettings = Join-Path -Path $moduleBase -ChildPath 'templates\PSScriptAnalyzerSettings.psd1'
    Copy-Item -Path $scriptAnalyzerSettings -Destination . -Force

    $settingsPath = Join-Path -Path $templates -ChildPath 'vscode\*'
    if (-not (Test-Path .vscode)) {
        $null = New-Item .vscode -ItemType Directory
    }
    Copy-Item -Path $settingsPath -Destination .vscode

    $testsPath = Join-Path -Path $moduleManifest.Directory.FullName -ChildPath 'tests'
    if (-not (Test-Path -Path $testsPath)) {
        $null = New-Item -Path $testsPath -ItemType Directory
    }
    Join-Path -Path $templates -ChildPath 'PSScriptAnalyzer.ps1' |
        Copy-Item -Destination (Join-Path -Path $testsPath -ChildPath 'PSScriptAnalyzer.tests.ps1')
}
