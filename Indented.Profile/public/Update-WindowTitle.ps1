using namespace System.Security.Principal

function Update-WindowTitle {
    <#
    .SYNOPSIS
        Set the window title to something else.

    .DESCRIPTION
        Set the window title to something else.
    #>

    $isAdministrator = ([WindowsPrincipal][WindowsIdentity]::GetCurrent()).IsInRole(
        [WindowsBuiltInRole]'Administrator'
    )

    $host.UI.RawUI.WindowTitle = '{0}{1}{2} - PowerShell {3}' -f @(
        [Environment]::UserName
        @('', ' (Administrator)')[$isAdministrator]
        @('', ' (32-bit)')[[IntPtr]::Size -eq 4]
        $PSVersionTable.PSVersion
    )
}
