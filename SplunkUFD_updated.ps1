$UFInstalled = "C:\Program Files\SplunkUniversalForwarder\etc\splunk.version"
$ScriptPfad = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$SplunkInstaller = "splunkforwarder-9.2.1-78803f08aabb-x64-release.msi"
$FQDN = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName + "." + (Get-CimInstance -ClassName Win32_ComputerSystem).Domain

if (-not (Test-Path -Path $UFInstalled)) {
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\$SplunkInstaller AGREETOLICENSE=yes /quiet" -Wait
    } catch {
        Write-Error "Fehler bei der Installation des Splunk Universal Forwarders: $_"
        exit 1
    }
} else {
    $UFVersion = (Get-Content $UFInstalled | Select-String -Pattern "VERSION").Line
    $InstallerVersion = "VERSION=9.2.1"  # Die Version sollte hier manuell aktualisiert werden

    if ($UFVersion -eq $InstallerVersion) {
        Write-Host "Kein Versionsunterschied, aktuelle Version vorhanden, breche Upgrade ab!"
        exit 0
    } else {
        Write-Host "Unterschied erkannt, Beginne Upgrade"
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\$SplunkInstaller AGREETOLICENSE=yes /quiet" -Wait
        } catch {
            Write-Error "Fehler beim Upgrade des Splunk Universal Forwarders: $_"
            exit 1
        }
    }
}