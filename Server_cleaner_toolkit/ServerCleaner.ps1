#Requires -Version 5.1
<#
    ServerCleaner.ps1
    ------------------
    Toolkit interattivo a riga di comando per la pulizia di file su server
    Windows Server 2016+. Fase 1: framework (menu, multilingua, logging,
    navigazione). La ricerca/eliminazione file vera e propria (Core.Purge.ps1)
    verra' implementata nelle Fasi 3/4.

    Struttura:
      ServerCleaner.ps1        <- punto di ingresso (questo file)
      Modules\Core.*.ps1       <- moduli funzionali, caricati con dot-sourcing
      Lang\<codice>.psd1       <- stringhe tradotte (it, en, fr, de, es, pt)

    I log delle operazioni vengono salvati nella stessa cartella in cui si
    trova fisicamente questo script.
#>

# --- Percorsi base -----------------------------------------------------
$script:ScriptRoot     = $PSScriptRoot
$script:ModulesFolder  = Join-Path -Path $script:ScriptRoot -ChildPath 'Modules'
$script:LangFolderPath = Join-Path -Path $script:ScriptRoot -ChildPath 'Lang'
$script:LogFolderPath  = $script:ScriptRoot

# --- Caricamento moduli (dot-sourcing: condividono lo scope di questo script) ---
. (Join-Path $script:ModulesFolder 'Core.Elevation.ps1')
. (Join-Path $script:ModulesFolder 'Core.I18n.ps1')
. (Join-Path $script:ModulesFolder 'Core.Logging.ps1')
. (Join-Path $script:ModulesFolder 'Core.Menu.ps1')
. (Join-Path $script:ModulesFolder 'Core.LogViewer.ps1')
. (Join-Path $script:ModulesFolder 'Core.Purge.ps1')

# --- Lingua di default: rilevata dal sistema, con fallback su inglese ---
$script:CurrentLangCode = Get-DefaultLanguageFromSystem
$script:Lang            = Import-LanguageStrings -LangCode $script:CurrentLangCode -LangFolder $script:LangFolderPath

# --- Verifica privilegi amministrativi e auto-elevazione ---------------
# Molte delle cartelle che lo script dovra' ispezionare nelle fasi
# successive (cache IIS, ASP.NET temp, ecc.) richiedono privilegi elevati:
# la richiesta viene fatta subito, prima di mostrare qualunque menu.
if (-not (Test-IsAdministrator)) {
    Write-Host $script:Lang.Elevation_Requesting -ForegroundColor Yellow
    $elevated = Invoke-SelfElevation -ScriptPath $PSCommandPath
    if ($elevated) {
        exit
    } else {
        Write-Host $script:Lang.Elevation_Failed -ForegroundColor Red
        exit 1
    }
}

# --- Menu principale -----------------------------------------------------
function Show-MainMenu {
    Show-ScreenHeader -Title $script:Lang.AppTitle -Description $script:Lang.MainMenu_Description
    Write-Host $script:Lang.MainMenu_Option1
    Write-Host $script:Lang.MainMenu_Option2
    Write-Host $script:Lang.MainMenu_Option3
    Write-Host ''
    Write-Host $script:Lang.Option_Exit -ForegroundColor DarkGray
}

while ($true) {
    Show-MainMenu
    $choice = Read-MenuChoice -MinValue 0 -MaxValue 3

    switch ($choice) {
        0 {
            Write-Host ''
            Write-Host $script:Lang.Exiting -ForegroundColor DarkGray
            exit
        }
        1 { Invoke-LanguageMenu }
        2 { Invoke-PurgeMenu }
        3 { Invoke-LogViewerMenu }
    }
}
