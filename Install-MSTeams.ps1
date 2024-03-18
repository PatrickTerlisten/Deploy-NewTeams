<#
.SYNOPSIS
Installation von Microsoft Teams.

.DESCRIPTION
Installiert Microsoft Teams systemweit. Das Skript lädt die aktuelle Version herunter und installiert sie.

.NOTES
Autor: Patrick Terlisten
Firma: ML Network DV-Systeme, Netzwerk & Kommunikation GmbH
E-Mail: p.terlisten@mlnetwork.de
Version: 1.0
Dieses Skript wird "wie es ist" ohne jegliche Gewährleistung zur Verfügung gestellt. Führen Sie es auf eigenes Risiko aus.

.LINK
https://mlnetwork.de
#>

# Variablen festlegen
$TeamsMSIXUrl = 'https://go.microsoft.com/fwlink/?linkid=2196106'
$TeamsBootstrapperUrl = 'https://go.microsoft.com/fwlink/?linkid=2243204'
$TeamsBootstrapperExe = "$Env:Temp\teamsbootstrapper.exe"
$TeamsMSIX = "$Env:Temp\MSTeams-x64.msix"

# Funktion zum Herunterladen von Dateien
function GetTeamsFiles {
    param (
        [string]$SourceUrl,
        [string]$DestinationPath
    )

    # TLS 1.2 aktivieren
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationPath
    Write-Host "Download von $($DestinationPath.Split('\')[-1]) abgeschlossen"
}

# Funktion zur Installation von Microsoft Teams
function InstallTeams {
    param (
        [string]$BootstrapperExe,
        [string]$MSIXFile
    )

    Write-Host 'Microsoft Teams wird installiert'
    & $BootstrapperExe -p -o $MSIXFile
    Write-Host 'Microsoft Teams wurde erfolgreich installiert'
}

# Funktion zum Beenden von Teams-Prozessen
function StopTeamsProcesses {
    Write-Host 'Beende Microsoft Teams-Prozesse' -ForegroundColor Yellow
    Get-Process | Where-Object { $_.Description -like 'Microsoft Teams*' } | Stop-Process -Force
}

# Herunterladen und Installieren von Teams
function NewTeamsInstall {
    StopTeamsProcesses
    GetTeamsFiles -SourceUrl $TeamsMSIXUrl -DestinationPath $TeamsMSIX
    GetTeamsFiles -SourceUrl $TeamsBootstrapperUrl -DestinationPath $TeamsBootstrapperExe
    InstallTeams -BootstrapperExe $TeamsBootstrapperExe -MSIXFile $TeamsMSIX
}

# Alles ausführen
NewTeamsInstall