function Global:prompt {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseConsistentWhitespace', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param ( )

    $colours = @{
        Cyan   = 0, 255, 255
        Green  = 128, 255, 0
        Blue   = 51, 153, 255
        Red    = 255, 0, 0
        White  = 255, 255, 255
        Grey   = 224, 224, 224
        Purple = 178, 102, 204
    }

    function Write-ColourfulString {
        param (
            [string]$Colour = 'None',

            [string]$String,

            [bool]$If = $true,

            [ref]$Length = (Get-Variable LengthRef -Scope 1 -ValueOnly -ErrorAction SilentlyContinue)
        )

        if ($String -and $If) {
            if ($Length) {
                $Length.Value += $String.Length
            }

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
        while (-not [String]::IsNullOrWhiteSpace($path)) {
            if (Test-Path (Join-Path $path.FullName '.git') -PathType Container) {
                return $path.Name
            } else {
                $path = $path.Parent
            }
        }
    }

    function Get-VcsStatus {
        [CmdletBinding()]
        param ( )

        $gitStatusOutput = (git status -s -b 2>$null) -split '\r?\n'
        if ($gitStatusOutput[0] -match '^## (?<local>[^.]+)(\.{3}(?<remote>\S+))?(?: \[)?(?:ahead (?<ahead>\d+))?(?:, )?(?:behind (?<behind>\d+))?' -or
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

    $Path = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    $prompt = ''
    $length = 0
    $lengthRef = [Ref]$length

    if ($ExecutionContext.SessionState.Path.CurrentLocation.Provider.Name -eq 'FileSystem') {
        $status = Get-VcsStatus -ErrorAction ('SilentlyContinue', 'Ignore')[$PSEdition -eq 'Core']
        if ($status) {
            $length += 6
            $prompt = "<{0} [{1} {2}]> " -f @(
                Write-ColourfulString -Colour Green -String $status.RootName
                Write-ColourfulString -Colour Cyan -String $status.BranchName
                -join @(
                    Write-ColourfulString -Colour Cyan -String ([Char]8801) -If ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0)
                    Write-ColourfulString -Colour Red -String ('{0}{1}' -f ([Char]8595), $status.BehindBy) -If ($status.BehindBy -gt 0)
                    Write-ColourfulString -Colour None -String ' ' -If ($status.BehindBy -gt 0 -and $status.AheadBy -gt 0)
                    Write-ColourfulString -Colour Green -String ('{0}{1}' -f ([Char]8593), $status.AheadBy) -If ($status.AheadBy -gt 0)
                    Write-ColourfulString -Colour Green -String (
                        ' +{0} ~{1} -{2}' -f @(
                            $status.Staged.Added
                            $status.Staged.Modified
                            $status.Staged.Deleted
                        )
                    ) -If ($status.StagedCount -gt 0)
                    Write-ColourfulString -Colour White -String ' |' -If ($status.StagedCount -gt 0 -and ($status.UnstagedCount -gt 0 -or $status.UnmergedCount -gt 0))
                    Write-ColourfulString -Colour Red -String (
                        ' +{0} ~{1} -{2}' -f @(
                            $status.Unstaged.Added
                            $status.Unstaged.Modified
                            $status.Unstaged.Deleted
                        )
                    ) -If ($status.UnstagedCount -gt 0 -or $status.UnmergedCount -gt 0)
                    Write-ColourfulString -Colour Red -String (' !{0}' -f $status.UnmergedCount) -If ($status.UnmergedCount -gt 0)
                    Write-ColourfulString -Colour Red -String ' !' -If ($status.UnstagedCount -gt 0 -or $status.UnmergedCount -gt 0)
                )
            )
        }
    }

    $maximumPathLength = $host.UI.RawUI.WindowSize.Width - $length - 22
    if ($Path.Length -gt $maximumPathLength) {
        $Path = '...{0}' -f $Path.Substring($Path.Length - $maximumPathLength, $maximumPathLength)
    }
    $prompt = "{0}[{1}] " -f @(
        $prompt
        Write-ColourfulString -Colour Blue -String $Path
    )

    if ($lastCommand = Get-History -Count 1) {
        $historyID = $lastCommand.Id + 1
    } else {
        $historyID = 1
    }

    "`n{0}`n{1}{2}|PS{3} " -f @(
        $prompt
        Write-ColourfulString -Colour Cyan -String '[DBG] ' -If ([bool]$PSDebugContext)
        $historyID
        '>' * ($nestedPromptLevel + 1)
    )
}
