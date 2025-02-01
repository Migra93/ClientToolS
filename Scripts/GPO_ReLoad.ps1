param(
    [switch]$AdminMode
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# **Sichere Ermittlung des Skript-Pfads**
$ScriptPath = $PSScriptRoot
if (-not $ScriptPath) {
    $ScriptPath = Get-Location  # Falls leer, nutze aktuelles Verzeichnis
}

# **System-Variablen**
$HostName = hostname
$NameTitel = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name -replace ".*\\", ""
$LogPath = "$ScriptPath\$HostName"

# **Programme**
$PwshExe = "$ScriptPath\pwsh\pwsh.exe"
$PsExecExe = "$ScriptPath\pwsh\psexec.exe"

# **Erstelle das Verzeichnis, falls es nicht existiert**
if (!(Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

# **Speicherorte für GPO-Reports & Logs**
$GPPreUserReport = "$LogPath\PreGPO_${NameTitel}.html"
$GPPreMachineReport = "$LogPath\PreGPO_${HostName}.html"
$GPAfterUserReport = "$LogPath\UpdatetGPO_${NameTitel}.html"
$GPAfterMachineReport = "$LogPath\UpdatetGPO_${HostName}.html"
$SyncFile = "$LogPath\AdminTaskCompleted.txt"
$LogFile = "$LogPath\GPO_${HostName}.log"

# **Logging-Funktion**
Function Write-Log {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding utf8
}

Write-Host "✅ Debugging aktiviert. Log: $LogFile" -ForegroundColor Green
Write-Log "✅ Debugging aktiviert. Log: $LogFile"

if (!(Test-Path "$PwshExe")) {
    Write-Host "❌ Fehler: PowerShell 7 wurde nicht gefunden unter: $PwshExe" -ForegroundColor Red
    Write-Log "❌ Fehler: PowerShell 7 wurde nicht gefunden!"
    exit 1
} else {
    Write-Host "✅ Verwende PowerShell 7: $PwshExe" -ForegroundColor Green
    Write-Log "✅ Verwende PowerShell 7: $PwshExe"

    # Teste PowerShell 7 mit direkter Ausgabe
    $PwshTestOutput = & "$PwshExe" -Command "[System.Environment]::OSVersion.VersionString"
    
    if ($PwshTestOutput) {
        Write-Host "✅ PowerShell 7-Test erfolgreich: $PwshTestOutput" -ForegroundColor Green
        Write-Log "✅ PowerShell 7-Test erfolgreich: $PwshTestOutput"
    } else {
        Write-Host "❌ PowerShell 7 konnte nicht gestartet werden. Prüfe die Installation!" -ForegroundColor Red
        Write-Log "❌ PowerShell 7 konnte nicht gestartet werden!"
        exit 1
    }
}


if (!(Test-Path "$PwshExe")) {
    Write-Host "❌ Fehler: PowerShell 7 wurde nicht gefunden unter: $PwshExe" -ForegroundColor Red
    Write-Log "❌ Fehler: PowerShell 7 wurde nicht gefunden!"
    exit 1
} else {
    Write-Host "✅ Verwende PowerShell 7: $PwshExe" -ForegroundColor Green
    Write-Log "✅ Verwende PowerShell 7: $PwshExe"
}

# **Funktion: Dienste für Gruppenrichtlinien neu starten**
Function Restart-GPOServices {
    $ServicesToRestart = @("gpsvc", "LanmanWorkstation", "winmgmt", "netlogon", "Wuauserv")

    foreach ($Service in $ServicesToRestart) {
        if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
            Write-Host "🔄 Starte Dienst: $Service ..." -ForegroundColor Yellow
            Write-Log "🔄 Starte Dienst: $Service ..."
            
            Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Start-Service -Name $Service -ErrorAction SilentlyContinue
            
            if ((Get-Service -Name $Service).Status -eq 'Running') {
                Write-Host "✅ Dienst $Service erfolgreich neu gestartet!" -ForegroundColor Green
                Write-Log "✅ Dienst $Service erfolgreich neu gestartet!"
            } else {
                Write-Host "❌ Dienst $Service konnte nicht gestartet werden!" -ForegroundColor Red
                Write-Log "❌ Dienst $Service konnte nicht gestartet werden!"
            }
        } else {
            Write-Host "⚠ Dienst $Service nicht gefunden, wird übersprungen." -ForegroundColor Cyan
            Write-Log "⚠ Dienst $Service nicht gefunden, wird übersprungen."
        }
    }
}

# **Funktion: Prozesse für GPO neu starten**
Function Restart-GPOProcesses {
    $ProcessesToRestart = @("explorer", "taskeng", "gpscript")

    foreach ($Process in $ProcessesToRestart) {
        if (Get-Process -Name $Process -ErrorAction SilentlyContinue) {
            Write-Host "🔄 Beende Prozess: $Process ..." -ForegroundColor Yellow
            Write-Log "🔄 Beende Prozess: $Process ..."
            
            Stop-Process -Name $Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2

            if ($Process -eq "explorer") {
                Start-Process -FilePath "explorer.exe"
            }

            Write-Host "✅ Prozess $Process erfolgreich neu gestartet!" -ForegroundColor Green
            Write-Log "✅ Prozess $Process erfolgreich neu gestartet!"
        } else {
            Write-Host "⚠ Prozess $Process nicht gefunden, wird übersprungen." -ForegroundColor Cyan
            Write-Log "⚠ Prozess $Process nicht gefunden, wird übersprungen."
        }
    }
}

# **Admin-Prozess starten**
if (-not $AdminMode) {
    Write-Host "📡 Erfasse Benutzer-Gruppenrichtlinien für den User: $($NameTitel)..." -ForegroundColor Cyan
    Start-Process -FilePath "gpresult.exe" -ArgumentList "/User $env:USERNAME /H `"$GPPreUserReport`" /f" -NoNewWindow -Wait
    Write-Log "✅ Benutzer-GPOs erfolgreich erfasst."

    Write-Host "🚀 Starte Admin-Prozess für Maschinen-GPOs..." -ForegroundColor White
    Write-Log "🚀 Starte Admin-Prozess für Maschinen-GPOs..."

    $PsExecCommand = "-accepteula -h -s -i 1 `"$PwshExe`" -NoExit -ExecutionPolicy Bypass -File `"$ScriptPath\GPO_ReLoad.ps1`" -AdminMode"

    Write-Host "🔄 Starte Admin-Prozess mit: `"$PsExecExe`" $PsExecCommand" -ForegroundColor Cyan
    Write-Log "🔄 Starte Admin-Prozess mit: `"$PsExecExe`" $PsExecCommand"

    Start-Process -FilePath "$PsExecExe" -ArgumentList $PsExecCommand -Verb RunAs -Wait
    Start-Sleep -Seconds 3

    # **Prozesslaufzeit überwachen**
    $AdminProcessRunning = Get-Process | Where-Object { $_.ProcessName -like "pwsh*" }
    if ($AdminProcessRunning) {
        Write-Host "✅ Admin-Prozess erfolgreich gestartet: $($AdminProcessRunning.Id)" -ForegroundColor Green
        Write-Log "✅ Admin-Prozess erfolgreich gestartet: $($AdminProcessRunning.Id)"
    } else {
        Write-Host "❌ Fehler: Admin-Prozess wurde NICHT gestartet oder ist abgestürzt!" -ForegroundColor Red
        Write-Log "❌ Fehler: Admin-Prozess wurde NICHT gestartet oder ist abgestürzt!"
        exit 1
    }

    Start-Process -FilePath "gpresult.exe" -ArgumentList "/User $env:USERNAME /H `"$GPAfterUserReport`" /f" -NoNewWindow -Wait
    del $SyncFile -Force
    exit
}

# **Admin-Modus**
if ($AdminMode) {
    Write-Host "✅ Admin-Modus aktiviert!" -ForegroundColor Green
    Restart-GPOServices
    Restart-GPOProcesses

    Start-Process -FilePath "gpresult.exe" -ArgumentList "/Scope Computer /H `"$GPAfterMachineReport`" /f" -NoNewWindow -Wait
    New-Item -Path $SyncFile -ItemType File -Force | Out-Null

    Write-Host "✅ Admin-Bereich abgeschlossen!" -ForegroundColor Green
    exit
}
