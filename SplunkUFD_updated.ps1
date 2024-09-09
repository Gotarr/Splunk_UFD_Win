$UFInstalled = "C:\Program Files\SplunkUniversalForwarder\etc\splunk.version"
$ScriptPfad = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$UFUpgrade = Join-Path -Path $ScriptPfad -ChildPath "splunk.version"
$FQDN = (Get-CimInstance -ClassName Win32_ComputerSystem).DNSHostName + "." + (Get-CimInstance -ClassName Win32_ComputerSystem).Domain

if (-not (Test-Path -Path $UFInstalled)) {
    try {
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\splunkforwarder-9.2.1-78803f08aabb-x64-release.msi AGREETOLICENSE=yes /quiet" -Wait
    } catch {
        Write-Error "Fehler bei der Installation des Splunk Universal Forwarders: $_"
        exit 1
    }
} else {
    $UnterschiedPlattform = Compare-Object -ReferenceObject (Get-Content $UFInstalled) -DifferenceObject (Get-Content $UFUpgrade) | Where-Object { $_.InputObject -Like "PLATFORM*" }
    $UnterschiedVersion = Compare-Object -ReferenceObject (Get-Content $UFInstalled) -DifferenceObject (Get-Content $UFUpgrade) | Where-Object { $_.InputObject -Like "VERSION*" }

    if (-not $UnterschiedPlattform) {
        Write-Host "Richtige Plattform, Weiter mit Versioncheck"
    } else {
        Write-Host "Abbruch Falsches Paket ausgewählt (LINUX Forwarder?)"
        exit 1
    }

    if (-not $UnterschiedVersion) {
        Write-Host "Kein Versionsunterschied, aktuelle Version vorhanden, breche Upgrade ab!"
        exit 0
    } else {
        Write-Host "Unterschied erkannt und Plattformcheck ist ok, Beginne Upgrade"
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $ScriptPfad\splunkforwarder-9.2.1-78803f08aabb-x64-release.msi AGREETOLICENSE=yes /quiet" -Wait
        } catch {
            Write-Error "Fehler beim Upgrade des Splunk Universal Forwarders: $_"
            exit 1
        }
    }
}