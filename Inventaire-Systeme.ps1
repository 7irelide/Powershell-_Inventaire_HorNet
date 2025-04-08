# Script d'inventaire système
# Ce script collecte les informations système (nom de machine, numéro de série)
# et les ajoute à un fichier CSV existant ou en crée un nouveau si nécessaire.

# Récupération des informations système
$NomMachine = $env:COMPUTERNAME
$SystemInfo = Get-CimInstance -ClassName Win32_BIOS -ErrorAction SilentlyContinue
if (-not $SystemInfo) {
    # Fallback sur Get-WmiObject si Get-CimInstance échoue
    $SystemInfo = Get-WmiObject -Class Win32_BIOS -ErrorAction SilentlyContinue
}

if ($SystemInfo) {
    $NumeroSerie = $SystemInfo.SerialNumber
} else {
    $NumeroSerie = "Non disponible"
    Write-Warning "Impossible de récupérer le numéro de série."
}

$DateReleve = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Création de l'objet avec les données
$InformationsSysteme = [PSCustomObject]@{
    NomMachine = $NomMachine
    NumeroSerie = $NumeroSerie
    DateReleve = $DateReleve
}

# Définition du chemin du fichier CSV
$CheminFichierCSV = Join-Path -Path $PSScriptRoot -ChildPath "inventaire_postes.csv"

# Vérification de l'existence du fichier CSV
if (-not (Test-Path -Path $CheminFichierCSV)) {
    # Création du fichier avec les en-têtes si inexistant
    $InformationsSysteme | Export-Csv -Path $CheminFichierCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
    Write-Host "Fichier CSV créé avec succès : $CheminFichierCSV"
} else {
    # Ajout des données au fichier existant
    $InformationsSysteme | Export-Csv -Path $CheminFichierCSV -NoTypeInformation -Encoding UTF8 -Append -Delimiter ";"
    Write-Host "Données ajoutées au fichier CSV existant : $CheminFichierCSV"
}

Write-Host "Inventaire système terminé."
Write-Host "Nom de la machine : $NomMachine"
Write-Host "Numéro de série   : $NumeroSerie"
Write-Host "Date du relevé    : $DateReleve"


pause