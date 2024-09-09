$ScriptPfad = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
#Datei anpassen für Installation oder update
$SplunkInstaller = "splunkforwarder-9.2.1-78803f08aabb-x64-release.msi"
$FQDN = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName + "." + (Get-CimInstance -ClassName Win32_ComputerSystem).Domain

# Überprüfen, ob der Splunk Universal Forwarder installiert ist
$UFInstalledPath = "C:\Program Files\SplunkUniversalForwarder"

if (-not (Test-Path -Path $UFInstalledPath)) {
    try {
        Write-Host "Splunk Universal Forwarder wird installiert..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\$SplunkInstaller AGREETOLICENSE=yes /quiet" -Wait -ErrorAction Stop
        Write-Host "Installation erfolgreich abgeschlossen."
    } catch {
        Write-Error "Fehler bei der Installation des Splunk Universal Forwarders: $_"
        exit 1
    }
} else {
    Write-Host "Splunk Universal Forwarder ist bereits installiert. Beginne Upgrade..."
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\$SplunkInstaller AGREETOLICENSE=yes /quiet" -Wait -ErrorAction Stop
        Write-Host "Upgrade erfolgreich abgeschlossen."
    } catch {
        Write-Error "Fehler beim Upgrade des Splunk Universal Forwarders: $_"
        exit 1
    }
}