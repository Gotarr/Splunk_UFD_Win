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
    Write-Host "Splunk Universal Forwarder ist bereits installiert. Beginne Upgrade"
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\$SplunkInstaller AGREETOLICENSE=yes /quiet" -Wait
    } catch {
        Write-Error "Fehler beim Upgrade des Splunk Universal Forwarders: $_"
        exit 1
    }
}