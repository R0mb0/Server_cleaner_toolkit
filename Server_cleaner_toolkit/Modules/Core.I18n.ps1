#
# Core.I18n.ps1
# Gestione della localizzazione: rilevamento lingua di sistema, elenco lingue
# supportate e caricamento dei file di traduzione (Lang\*.psd1).
#

# Nomi nativi delle lingue, mostrati sempre nella lingua stessa (non tradotti)
# indipendentemente dalla lingua correntemente attiva nell'interfaccia.
$script:LanguageDisplayNames = [ordered]@{
    it = 'Italiano'
    en = 'English'
    fr = 'Français'
    de = 'Deutsch'
    es = 'Español'
    pt = 'Português'
}

function Get-SupportedLanguages {
    <#
        Restituisce l'elenco ordinato dei codici lingua (ISO 639-1) supportati
        dallo script. L'ordine determina la numerazione nel menu di selezione.
    #>
    return @($script:LanguageDisplayNames.Keys)
}

function Get-DefaultLanguageFromSystem {
    <#
        Rileva la lingua dell'interfaccia di sistema (Get-UICulture) e, se
        supportata, la restituisce come lingua predefinita. In caso contrario
        (o in caso di errore nel rilevamento) restituisce 'en' come fallback.
    #>
    $supported = Get-SupportedLanguages
    $detected  = 'en'

    try {
        $twoLetter = (Get-UICulture).TwoLetterISOLanguageName
        if ($supported -contains $twoLetter) {
            $detected = $twoLetter
        }
    } catch {
        # Se il rilevamento fallisce per qualsiasi motivo, resta l'inglese.
    }

    return $detected
}

function Import-LanguageStrings {
    <#
        Carica il file di traduzione (psd1) corrispondente al codice lingua
        richiesto dalla cartella Lang. Lancia un'eccezione se il file non
        esiste, cosi' l'errore e' visibile subito invece di fallire in modo
        silenzioso con testi mancanti.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$LangCode,

        [Parameter(Mandatory)]
        [string]$LangFolder
    )

    $path = Join-Path -Path $LangFolder -ChildPath "$LangCode.psd1"

    if (-not (Test-Path -Path $path -PathType Leaf)) {
        throw "File di lingua non trovato: $path"
    }

    return Import-PowerShellDataFile -Path $path
}

function Invoke-LanguageMenu {
    <#
        Mostra l'elenco delle lingue supportate (numerate da 1, con la lingua
        attualmente attiva contrassegnata da un asterisco). Alla selezione,
        aggiorna $script:CurrentLangCode e ricarica $script:Lang con le
        stringhe della nuova lingua, poi torna al menu principale. Con 0 si
        torna al menu principale senza cambiare nulla.
    #>
    Show-ScreenHeader -Title $script:Lang.LangMenu_Header -Description $script:Lang.LangMenu_Description

    $codes = Get-SupportedLanguages
    for ($i = 0; $i -lt $codes.Count; $i++) {
        $code   = $codes[$i]
        $marker = if ($code -eq $script:CurrentLangCode) { ' (*)' } else { '' }
        Write-Host ("{0}. {1}{2}" -f ($i + 1), $script:LanguageDisplayNames[$code], $marker)
    }
    Write-Host ''
    Write-Host $script:Lang.Option_Back -ForegroundColor DarkGray

    $choice = Read-MenuChoice -MinValue 0 -MaxValue $codes.Count
    if ($choice -eq 0) { return }

    $selectedCode        = $codes[$choice - 1]
    $script:CurrentLangCode = $selectedCode
    $script:Lang            = Import-LanguageStrings -LangCode $selectedCode -LangFolder $script:LangFolderPath

    Write-Host ''
    Write-Host ($script:Lang.LangMenu_Changed -f $script:LanguageDisplayNames[$selectedCode]) -ForegroundColor Green
    Start-Sleep -Seconds 1
}
