<#
.SYNOPSIS
Entfernt alle Microsoft Teams Installationen von einem Rechner.

.DESCRIPTION
Dieses Skript entfernt alle Microsoft Teams Installationen von einem Rechner, einschließlich des Machine-Wide Installers und aller Installationen in Benutzerverzeichnissen.

.NOTES
Autor: Patrick Terlisten
Firma: ML Network DV-Systeme, Netzwerk & Kommunikation GmbH
E-Mail: p.terlisten@mlnetwork.de
Version: 1.0
Dieses Skript wird "wie es ist" ohne jegliche Gewährleistung zur Verfügung gestellt. Führen Sie es auf eigenes Risiko aus.

.LINK
https://mlnetwork.de
#>

# Funktion zum Deinstallieren von Microsoft Teams
function UninstallTeams {
    param (
        [string]$Path
    )
    
    $ClientInstaller = Join-Path -Path $Path -ChildPath '../Update.exe'
  
    try {
        $process = Start-Process -FilePath $ClientInstaller -ArgumentList '--uninstall /s' -PassThru -Wait -ErrorAction Stop
  
        if ($process.ExitCode -ne 0) {
            Write-Error "Deinstallation von Microsoft Teams ist mit Exit Code $($process.ExitCode) fehlgeschlagen."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
  
# Microsoft Teams Machine-wide Installer entfernen
Write-Host 'Deinstalliere Microsoft Teams Machine-wide Installer' -ForegroundColor Yellow
  
try {
    $MachineWide = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq 'Teams Machine-Wide Installer' }
    $MachineWide.Uninstall()
}
catch {
    Write-Host 'Microsoft Teams Machine-wide Installer nicht vorhanden' -ForegroundColor Yellow
  
}
  
# Alle Benutzerprofile auf dem Rechner durchgehen
$Users = Get-ChildItem -Path "$($ENV:SystemDrive)\Users"
  
# Deinstallation von Microsoft Teams für jeden Benutzer
foreach ($User in $Users) {
    Write-Host "Deinstalliere Teams für Benutzer $($User.Name)." -ForegroundColor Yellow
  
    # Installationsordner überprüfen
    $LocalAppData = Join-Path -Path "$($ENV:SystemDrive)\Users\$($User.Name)\AppData\Local\Microsoft\Teams" -ChildPath 'Current'
    $ProgramData = Join-Path -Path "$($env:ProgramData)\$($User.Name)\Microsoft\Teams" -ChildPath 'Current'
  
    if (Test-Path "$LocalAppData\Teams.exe") {
        UninstallTeams -Path $LocalAppData
        $LocalAppData = Join-Path -Path "$($ENV:SystemDrive)\Users\$($User.Name)\AppData\Local" -ChildPath 'Microsoft'
        Remove-Item $LocalAppData\Teams* -Force -Confirm:$false -Recurse
    }
    else {
        Write-Warning "Microsoft Teams für Benutzer $($User.Name) ist nicht installiert."
    }
}