function Update-WindowTitle {
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