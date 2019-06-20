function Update-WindowTitle {
    <#
    .SYNOPSIS
        Set the window title to something else.
    .DESCRIPTION
        Set the window title to something else.
    #>

    $isAdministrator = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]"Administrator"
    )

    $host.UI.RawUI.WindowTitle = '{0}{1}{2} - PowerShell {3}' -f @(
        $env:USERNAME
        @('', ' (Administrator)')[$isAdministrator]
        @('', ' (32-bit)')[[IntPtr]::Size -eq 4]
        $psversiontable.PSVersion
    )
}