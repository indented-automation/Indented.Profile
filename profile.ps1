#
# Functions
#

function Get-Secure {
    [CmdletBinding(DefaultParameterSetName = 'Get')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = 'Get')]
        [String]$Name,

        [Parameter(Mandatory, ParameterSetName = 'List')]
        [Switch]$List,

        [Switch]$NoClipboard
    )

    begin {
        if ($List) {
            Get-ChildItem $home\Documents\Keys |
                Select-Object @{n='Name';e={ $_.BaseName }},
                              @{n='Created';e={ $_.CreationTime }}
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'Get') {
            $path = '{0}\Documents\Keys\{1}.xml' -f $home, $Name
            if (Test-Path $path) {
                $credential = Import-CliXml ('{0}\Documents\Keys\{1}.xml' -f $home, $Name)
                if (-not $NoClipboard) {
                    $credential.GetNetworkCredential().Password | Set-Clipboard
                }
                $credential
            }
        }
    }
}

function Set-Secure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [String]$Name
    )

    $path = '{0}\Documents\Keys\{1}.xml' -f $home, $Name
    if (Test-Path $path) {
        $credential = Get-Credential (Get-Secure $Name -NoClipboard).Username
    } else {
        $credential = Get-Credential
    }
    $credential | Export-CliXml $path
}

function prompt {
    function Write-ColourfulString {
        param (
            [String]$Colour = 'None',

            [String]$String,

            [Boolean]$If = $true
        )

        if ($String -and $If) {
            if ($Colour -eq 'None') {
                $String
            } else {
                $rgb = $colours[$Colour]

                "{0}[38;2;{1};{2};{3}`m{4}{0}[0m" -f @(
                    ([Char]27)
                    $rgb[0]
                    $rgb[1]
                    $rgb[2]
                    $String
                )
            }
        } else {
            ''
        }
    }

    function Get-VcsRootName {
        $path = $executionContext.SessionState.Path.CurrentLocation
        if ($path.Provider.Name -ne 'FileSystem') {
            return
        }
        $path = Get-Item $path.Path
        while ($path) {
            if (Test-Path (Join-Path $path '.git') -PathType Container) {
                return $path.Name
            } else {
                $path = $path.Parent
            }
        }
    }

    function Get-VcsStatus {
        $gitStatusOutput = (git status -s -b 2>$null) -split '\r?\n'
        if ($gitStatusOutput[0] -match '^## (?<local>\S+)\.{3}(?<remote>\S+)(?: \[)?(?:ahead (?<ahead>\d+))?(?:, )?(?:behind (?<behind>\d+))?' -or
            $gitStatusOutput[0] -match '^## HEAD \(no branch\)') {

            if (-not $matches['local']) {
                $matches['local'] = git rev-parse --short HEAD
            }

            $status = [PSCustomObject]@{
                RootName      = Get-VcsRootName
                BranchName    = $matches['local']
                AheadBy       = [Int]$matches['ahead']
                BehindBy      = [Int]$matches['behind']

                StagedCount   = 0
                Staged        = [PSCustomObject]@{
                    Added    = 0
                    Deleted  = 0
                    Modified = 0
                }
                UnstagedCount = 0
                Unstaged      = [PSCustomObject]@{
                    Added    = 0
                    Deleted  = 0
                    Modified = 0
                }
                UnmergedCount = 0
            }

            foreach ($entry in $gitStatusOutput) {
                switch -Regex ($entry) {
                    '^[ADM]'        { $status.StagedCount++ }
                    '^A'            { $status.Staged.Added++; break }
                    '^D '           { $status.Staged.Deleted++; break }
                    '^M '           { $status.Staged.Modified++; break }
                    '^( [DM]|\?\?)' { $status.UnstagedCount++ }
                    '^\?\?'         { $status.Unstaged.Added++; break }
                    '^ D'           { $status.Unstaged.Deleted++; break }
                    '^ M'           { $status.Unstaged.Modified++; break }
                    '^UU'           { $status.UnmergedCount++; break }
                }
            }

            $status
        }
    }

    $colours = @{
        Cyan   = 0, 255, 255
        Green  = 128, 255, 0
        Blue   = 51, 153, 255
        Red    = 255, 0, 0
        White  = 255, 255, 255
        Grey   = 224, 224, 224
        Purple = 178, 102, 204
    }

    $Path = $executionContext.SessionState.Path.CurrentLocation

    $status = Get-VcsStatus
    $prompt = ''
    if ($status) {
        $prompt = "<{0} [{1} {2}]> " -f @(
            Write-ColourfulString -Colour Green -String $status.RootName
            Write-ColourfulString -Colour Cyan -String $status.BranchName
            -join @(
                Write-ColourfulString -Colour Cyan -String ([Char]8801) -If ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0)
                Write-ColourfulString -Colour Red -String ('{0}{1}' -f ([Char]8595), $status.BehindBy) -If ($status.BehindBy -gt 0)
                Write-ColourfulString -Colour None -String ' ' -If ($status.BehindBy -gt 0 -and $status.AheadBy -gt 0)
                Write-ColourfulString -Colour Green -String ('{0}{1}' -f ([Char]8593), $status.AheadBy) -If ($status.AheadBy -gt 0)
                Write-ColourfulString -Colour Green -String (' +{0} ~{1} -{2}' -f @(
                    $status.Staged.Added
                    $status.Staged.Modified
                    $status.Staged.Deleted
                )) -If ($status.StagedCount -gt 0)
                Write-ColourfulString -Colour White -String ' |' -If ($status.StagedCount -gt 0 -and ($status.UnstagedCount -gt 0 -or $status.UnmergedCount -gt 0))
                Write-ColourfulString -Colour Red -String (' +{0} ~{1} -{2}' -f @(
                    $status.Unstaged.Added
                    $status.Unstaged.Modified
                    $status.Unstaged.Deleted
                )) -If ($status.UnstagedCount -gt 0 -or $status.UnmergedCount -gt 0)
                Write-ColourfulString -Colour Red -String (' !{0}' -f $status.UnmergedCount) -If ($status.UnmergedCount -gt 0)
                Write-ColourfulString -Colour Red -String ' !' -If ($status.UnstagedCount -gt 0 -or $status.UnmergedCount -gt 0)
            )
        )
    }

    $prompt = "{0}[{1}] " -f @(
        $prompt
        Write-ColourfulString -Colour Blue -String $Path
    )

    $lastCommand = Get-History -Count 1
    if ($lastCommand) {
        $timeTaken = '{0:N2}' -f ($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).TotalMilliseconds
        $offset = $host.UI.RawUI.WindowSize.Width - $timeTaken.Length - 4

        $prompt = "{0}{1}[{2}G[{3} ms]" -f @(
            $prompt
            ([Char]27)
            $offset
            Write-ColourfulString -Colour Purple -String $timeTaken
        )
    }

    "`n{0}`nPS>" -f $prompt
}

function Restart-Console {
    Start-Process (Get-Process -Id $PID).Path -ArgumentList @(
        '-NoExit'
        '-Command'
        "Set-Location $($pwd.Path)"
    )
    exit
}

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

function Get-CommandInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Mandatory, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

        [Parameter(ValueFromRemainingArguments, DontShow)]
        $EaterOfArgs
    )

    if ($Name) {
        $CommandInfo = Get-Command -Name $Name
    }

    if ($commandInfo -is [System.Management.Automation.AliasInfo]) {
        $CommandInfo = $CommandInfo.ResolvedCommand
    }

    return $CommandInfo
}

function Get-CommandSource {
    [CmdletBinding()]
    [Alias('source')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo
    )

    process {
        try {
            $CommandInfo = Get-CommandInfo @psboundparameters

            if ($commandInfo -is [System.Management.Automation.CmdletInfo]) {
                $assembly = $commandInfo.ImplementingType.Assembly.Location
                $type = $commandInfo.ImplementingType.FullName

                if (Get-Command dnspy -ErrorAction SilentlyContinue) {
                    dnspy $assembly --select T:$type
                } elseif (Get-Command ilspy -ErrorAction SilentlyContinue) {
                    ilspy $assembly /navigateTo:T:$type
                } else {
                    throw 'No decompiler present'
                }
            } else {
                $commandInfo.Definition
            }
        } catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }
}

function Get-Syntax {
    [CmdletBinding()]
    [Alias('synt', 'syntax')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

        [Switch]$Long
    )

    begin {
        $commonParams = @(
            [System.Management.Automation.Internal.CommonParameters].GetProperties().Name
            [System.Management.Automation.Internal.ShouldProcessParameters].GetProperties().Name
            [System.Management.Automation.Internal.TransactionParameters].GetProperties().Name
        )
    }

    process {
        $CommandInfo = Get-CommandInfo @psboundparameters
        foreach ($parameterSet in $CommandInfo.ParameterSets) {
            if ($Long) {
                $stringBuilder = [System.Text.StringBuilder]::new().AppendFormat('{0} ', $commandInfo.Name)

                $null = foreach ($parameter in $parameterSet.Parameters) {
                    if ($parameter.Name -notin $commonParams) {
                        if (-not $parameter.IsMandatory) {
                            $stringBuilder.Append('[')
                        }

                        if ($parameter.Position -gt [Int32]::MinValue) {
                            $stringBuilder.Append('[')
                        }

                        $stringBuilder.AppendFormat('-{0}', $parameter.Name)

                        if ($parameter.Position -gt [Int32]::MinValue) {
                            $stringBuilder.Append(']')
                        }

                        if ($parameter.ParameterType -ne [Switch]) {
                            $stringBuilder.AppendFormat(' <{0}>', $parameter.ParameterType.Name)
                        }

                        if (-not $parameter.IsMandatory) {
                            $stringBuilder.Append(']')
                        }

                        $stringBuilder.AppendLine().Append(' ' * ($commandInfo.Name.Length + 1))
                    }
                }

                $stringBuilder.AppendLine().ToString()
            } else {
                "`n{0} {1}" -f $CommandInfo.Name, $parameterSet
            }
        }
    }
}

function Get-ParameterInfo {
    [CmdletBinding()]
    [Alias('paraminfo')]
    param (
        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromCommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo,

        [Parameter(Mandatory, Position = 2, ParameterSetName = 'ByName')]
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'FromCommandInfo')]
        [String]$ParameterName
    )

    process {
        if ($Name) {
            $CommandInfo = Get-Command -Name $Name
        }

        if ($commandInfo -is [System.Management.Automation.AliasInfo]) {
            $commandInfo = $commandInfo.ResolvedCommand
        }
    }
}

function Copy-LastCommand {
    [CmdletBinding()]
    [Alias('last')]
    param ( )

    Get-History -Count 1 |
        Select-Object -ExpandProperty CommandLine |
        Set-Clipboard
}

Set-PSReadlineOption -BellStyle None

#
# Window appearance
#

# WindowTitle
$isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]"Administrator"
)
$host.UI.RawUI.WindowTitle = '{0}{1}{2} - PowerShell' -f
    $env:USERNAME,
    $(if ($isAdministrator) { ' (Administrator)' } else { '' }),
    $(if ([IntPtr]::Size -eq 4) { ' (32-bit)' } else { '' })
Remove-Variable isAdministrator

#
# Aliases
#

New-Alias -Name grep -Value Select-String

#
# Start path
#

if ($pwd.Path -notmatch '^C:\\Development') {
    Set-Location "C:\Development"
}

#
# Import modules
#

Import-Module Terminal-Icons