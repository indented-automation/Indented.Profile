function Restart-Console {
    <#
    .SYNOPSIS
        Restart the console.
    .DESCRIPTION
        Restart the console and put it back where I left it.
    #>

    [CmdletBinding()]
    param (
        [switch]$NoProfile
    )

    if (-not ('Window' -as [Type])) {
        Add-Type '
            using System;
            using System.Runtime.InteropServices;

            public class Window
            {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

                [DllImport("user32.dll")]
                public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, int uFlags);
            }

            public struct RECT
            {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
            }
        '
    }

    $thisProcess = Get-Process -Id $PID

    $argumentList = @(
        '-NoExit'
        @('', '-NoProfile')[[bool]$NoProfile]
        '-Command'
        'if (Test-Path "{0}") {{ Set-Location "{0}" }}' -f $pwd.Path
    ) -ne ''

    if ($env:WT_SESSION) {
        wt -w 0 $thisProcess.Name @argumentList
    } else {
        $rect = [RECT]::new()
        $hasPosition = [Window]::GetWindowRect(
            $thisProcess.MainWindowHandle,
            [Ref]$rect
        )

        $newProcess = Start-Process $thisProcess.Path -PassThru -ArgumentList $argumentList
        Start-Sleep -Milliseconds 100

        if ($hasPosition) {
            $null = [Window]::SetWindowPos(
                $newProcess.MainWindowHandle,
                $thisProcess.MainWindowHandle,
                $rect.Left,
                $rect.Top,
                -1,
                -1,
                1
            )
        }
    }

    exit
}
