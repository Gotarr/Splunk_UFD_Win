$UFInstalled = "C:\Program Files\SplunkUniversalForwarder\etc\splunk.version"
$ScriptPfad = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$UFUpgrade = "$ScriptPfad\splunk.version"
$FQDN =(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
if(![System.IO.File]::Exists($UFInstalled)){
msiexec.exe /i $ScriptPfad\splunkforwarder-9.2.1-78803f08aabb-x64-release.msi AGREETOLICENSE=yes /quiet
Wait-Process -Name msiexec
}
ELSE
{
$UnterschiedPlattform = Compare-Object -ReferenceObject $(Get-Content $UFInstalled ) -DifferenceObject $(Get-Content $UFUpgrade)|Where-Object { ($_.InputObject -Like "PLATFORM*") } 
$UnterschiedVersion = Compare-Object -ReferenceObject $(Get-Content $UFInstalled ) -DifferenceObject $(Get-Content $UFUpgrade)|Where-Object { ($_.InputObject -Like "VERSION*") } 
if($UnterschiedPlattform -eq $null)
{"Richtige Plattform, Weiter mit Versioncheck"}
ELSE
{
"Abbruch Falsches Paket ausgewählt (LINUX Forwarder?)"
exit
}
if($UnterschiedVersion -eq $null)
{
"Kein Versionunterschied, aktuelle Version vorhanden, breche Upgrade ab!"
exit
}
ELSE 
{
"Unterschied erkannt und Plattformcheck ist ok, Beginne Upgrade"
msiexec.exe /i $ScriptPfad\splunkforwarder-9.2.1-78803f08aabb-x64-release.msi AGREETOLICENSE=yes /quiet
Wait-Process -Name msiexec
}
}
Copy-Item $ScriptPfad\deploymentclient.conf -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\system\local' -Recurse -Force
(Get-Content 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf').replace("clientName = <FQDN>", "clientName = $FQDN")|Set-Content 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf'
Start-Sleep -Seconds 5
Restart-Service -Name SplunkForwarder