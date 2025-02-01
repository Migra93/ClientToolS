# **Sichere Ermittlung des Skript-Pfads**
$ScriptPath = $PSScriptRoot
if (-not $ScriptPath) {
    $ScriptPath = Get-Location  # Falls leer, nutze aktuelles Verzeichnis
}
# Erstellen oder leeren der Log-Datei
$HostName = Hostname
$LogPath = "$ScriptPath\$HostName"
$LogFile = "$LogPath\NetzwerkAnalyse.log"

Set-Content -Path $logFile -Value "Netzwerk Analyse - $(Get-Date)`n"

# Hostname
$hostname = hostname
Add-Content -Path $logFile -Value "Hostname: $hostname`n"

# Funktion zur Befehlsausführung mit Fehlerabfang
function Run-Command {
    param ($command)
    try {
        $result = Invoke-Expression -Command $command 2>&1
        if ($result) {
            Add-Content -Path $logFile -Value ($result -join "`n")
        } else {
            Add-Content -Path $logFile -Value "Keine Ausgabe von: $command"
        }
    } catch {
        Add-Content -Path $logFile -Value ("Fehler bei " + $command + ": " + $_.Exception.Message)
    }
}

# IP-Konfiguration
Add-Content -Path $logFile -Value "--- IP-Konfiguration ---"
Run-Command "ipconfig /all"

# Netzwerkadapter-Informationen
Add-Content -Path $logFile -Value "--- Netzwerkadapter ---"
Run-Command "Get-NetAdapter"

# Routen anzeigen
Add-Content -Path $logFile -Value "--- Routen ---"
Run-Command "route print"

# Ping-Test
Add-Content -Path $logFile -Value "--- Ping-Test zu 8.8.8.8 ---"
Run-Command "ping 8.8.8.8"

# Traceroute
Add-Content -Path $logFile -Value "--- Traceroute zu 8.8.8.8 ---"
Run-Command "tracert 8.8.8.8"

# DNS-Check mit erstem verfügbarem DNS-Server
$dnsServers = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
$dnsServer = if ($dnsServers -is [array]) { $dnsServers[0] } else { $dnsServers }

if ($dnsServer) {
    Add-Content -Path $logFile -Value "--- DNS-Check für google.com über $dnsServer ---"
    Run-Command "Resolve-DnsName google.com -Server $dnsServer"
} else {
    Add-Content -Path $logFile -Value "Kein DNS-Server gefunden!"
}

# Abschluss
Add-Content -Path $logFile -Value "Netzwerkanalyse abgeschlossen!"
