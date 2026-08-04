#
# Core.Logging.ps1
# Motore di logging: ogni operazione (es. una ricerca/purge) scrive in un file
# di log dedicato tutto cio' che scorre a terminale. Il file di log e' testo
# puro (nessun codice colore ANSI): i colori vengono riapplicati solo quando
# il log viene riaperto dallo script stesso, in base al prefisso di livello
# presente su ogni riga (es. [MATCH], [DELETED], [ERROR]...).
#

$script:CurrentLogPath = $null

# Mappa livello di log -> colore console. Usata sia da Write-Log (scrittura
# live) sia dal visualizzatore log (ricolorazione in lettura).
$script:LogLevelColors = @{
    INFO    = 'Gray'
    HEADER  = 'Cyan'
    PROMPT  = 'Yellow'
    MATCH   = 'Green'
    SCAN    = 'DarkGray'
    DELETED = 'Red'
    WARN    = 'DarkYellow'
    ERROR   = 'Red'
    SUCCESS = 'Green'
}

function Get-LogLevelColor {
    <#
        Restituisce il colore console associato a un livello di log.
        Se il livello non e' riconosciuto (o la riga non ha un prefisso di
        livello, come nel caso di righe di separazione) restituisce 'White'.
    #>
    param(
        [string]$Level
    )

    if ($script:LogLevelColors.ContainsKey($Level)) {
        return $script:LogLevelColors[$Level]
    }
    return 'White'
}

function Start-OperationLog {
    <#
        Apre un nuovo file di log per un'operazione (es. la ricerca di un
        determinato nome file) e lo imposta come log corrente: da questo
        momento in poi, ogni chiamata a Write-Log scrive anche su questo file.
        Il file viene salvato nella stessa cartella dello script (LogFolder).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$OperationName,

        [Parameter(Mandatory)]
        [string]$LogFolder
    )

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    # Rimuove i caratteri non ammessi nei nomi file di Windows dal nome
    # dell'operazione, cosi' il nome del file di ricerca puo' essere usato
    # direttamente come base per il nome del log.
    $safeName = ($OperationName -replace '[\\/:*?"<>|]', '_').Trim()
    if ([string]::IsNullOrWhiteSpace($safeName)) {
        $safeName = 'operazione'
    }

    $fileName = "{0}_{1}.log" -f $safeName, $timestamp
    $script:CurrentLogPath = Join-Path -Path $LogFolder -ChildPath $fileName

    $header = "=== Log avviato: {0} ===" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    Set-Content -Path $script:CurrentLogPath -Value $header -Encoding UTF8

    return $script:CurrentLogPath
}

function Stop-OperationLog {
    <#
        Chiude il log corrente scrivendo una riga di chiusura, e azzera il
        riferimento cosi' che le successive Write-Log non scrivano piu' su
        questo file finche' non ne viene aperto uno nuovo.
    #>
    if ($script:CurrentLogPath) {
        $footer = "=== Log terminato: {0} ===" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        Add-Content -Path $script:CurrentLogPath -Value $footer -Encoding UTF8
    }
    $script:CurrentLogPath = $null
}

function Write-Log {
    <#
        Stampa un messaggio a terminale con il colore corrispondente al
        livello indicato e, se un log e' attualmente aperto (Start-OperationLog
        e' stato chiamato), ne scrive una riga corrispondente anche nel file
        di log, con timestamp e prefisso di livello ma senza codici colore.
    #>
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Message,

        [ValidateSet('INFO', 'HEADER', 'PROMPT', 'MATCH', 'SCAN', 'DELETED', 'WARN', 'ERROR', 'SUCCESS')]
        [string]$Level = 'INFO',

        [switch]$NoNewline
    )

    $color = Get-LogLevelColor -Level $Level

    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $color -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $color
    }

    if ($script:CurrentLogPath) {
        $timestamp = Get-Date -Format 'HH:mm:ss'
        $line = "{0} [{1}] {2}" -f $timestamp, $Level, $Message
        Add-Content -Path $script:CurrentLogPath -Value $line -Encoding UTF8
    }
}
