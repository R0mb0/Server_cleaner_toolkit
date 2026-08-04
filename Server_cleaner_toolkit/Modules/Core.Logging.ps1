#
# Core.Logging.ps1
# Motore di logging: ogni operazione (es. una ricerca/purge) scrive in un file
# di log dedicato tutto cio' che scorre a terminale. Il file di log e' testo
# puro (nessun codice colore ANSI): i colori vengono riapplicati solo quando
# il log viene riaperto dallo script stesso, in base al prefisso di livello
# presente su ogni riga (es. [MATCH], [DELETED], [ERROR]...).
#
# Il log usa uno System.IO.StreamWriter tenuto aperto per tutta la durata
# dell'operazione (invece di Add-Content ad ogni riga): su una scansione
# completa di un intero disco le righe possono essere centinaia di migliaia,
# e riaprire il file ad ogni scrittura sarebbe troppo lento.
#

$script:CurrentLogPath  = $null
$script:LogWriter       = $null
$script:LogMaxBytes     = 0       # 0 = nessun limite
$script:LogBytesWritten = 0
$script:LogTruncated    = $false

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

function ConvertTo-ByteSize {
    <#
        Converte una stringa tipo "500MB", "2GB", "1024" (byte puri se senza
        unita') in un numero di byte (long). Restituisce $null se il formato
        non e' riconosciuto. Accetta MB/M e GB/G, case-insensitive, con o
        senza spazio tra numero e unita'.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    $trimmed = $Text.Trim()
    if ($trimmed -match '^(?<num>\d+(\.\d+)?)\s*(?<unit>MB|M|GB|G)?$') {
        $num  = [double]$Matches['num']
        $unit = $Matches['unit']
        if (-not $unit) { $unit = 'MB' }

        switch ($unit.ToUpperInvariant()) {
            { $_ -in @('GB', 'G') } { return [long]($num * 1GB) }
            default                 { return [long]($num * 1MB) }
        }
    }

    return $null
}

function Start-OperationLog {
    <#
        Apre un nuovo file di log per un'operazione (es. la ricerca di un
        determinato nome file) e lo imposta come log corrente: da questo
        momento in poi, ogni chiamata a Write-Log scrive anche su questo file.
        Il file viene salvato nella stessa cartella dello script (LogFolder).

        MaxBytes: se maggiore di 0, imposta una dimensione massima per il
        file; una volta raggiunta, Write-Log smette di scrivere su file (ma
        continua comunque a stampare a schermo) e $script:LogTruncated passa
        a $true, cosi' il chiamante puo' avvisare l'utente una sola volta.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$OperationName,

        [Parameter(Mandatory)]
        [string]$LogFolder,

        [long]$MaxBytes = 0
    )

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    # Rimuove i caratteri non ammessi nei nomi file di Windows dal nome
    # dell'operazione, cosi' il nome del file cercato puo' essere usato
    # direttamente come base per il nome del log.
    $safeName = ($OperationName -replace '[\\/:*?"<>|]', '_').Trim()
    if ([string]::IsNullOrWhiteSpace($safeName)) {
        $safeName = 'operazione'
    }

    $fileName = "{0}_{1}.log" -f $safeName, $timestamp
    $script:CurrentLogPath = Join-Path -Path $LogFolder -ChildPath $fileName

    $script:LogMaxBytes     = $MaxBytes
    $script:LogBytesWritten = 0
    $script:LogTruncated    = $false

    $utf8WithBom      = New-Object System.Text.UTF8Encoding($true)
    $script:LogWriter = New-Object System.IO.StreamWriter($script:CurrentLogPath, $false, $utf8WithBom)
    $script:LogWriter.AutoFlush = $true

    $header = "=== Log avviato: {0} ===" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    $script:LogWriter.WriteLine($header)
    $script:LogBytesWritten += [System.Text.Encoding]::UTF8.GetByteCount($header) + 2

    return $script:CurrentLogPath
}

function Stop-OperationLog {
    <#
        Chiude il log corrente scrivendo una riga di chiusura, e rilascia lo
        StreamWriter cosi' che le successive Write-Log non scrivano piu' su
        questo file finche' non ne viene aperto uno nuovo. Va sempre chiamata
        (idealmente in un blocco finally) al termine di ogni operazione, per
        non lasciare il file di log aperto/bloccato.
    #>
    if ($script:LogWriter) {
        try {
            $footer = "=== Log terminato: {0} ===" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            $script:LogWriter.WriteLine($footer)
            $script:LogWriter.Flush()
        } catch {
            # Se il file e' gia' inaccessibile non c'e' molto da fare: si
            # prosegue comunque con il rilascio delle risorse.
        } finally {
            $script:LogWriter.Dispose()
        }
    }

    $script:LogWriter      = $null
    $script:CurrentLogPath = $null
}

function Write-Log {
    <#
        Stampa un messaggio a terminale con il colore corrispondente al
        livello indicato e, se un log e' attualmente aperto, ne scrive una
        riga corrispondente anche nel file di log (timestamp + prefisso di
        livello, senza codici colore). Se e' stato impostato un limite di
        dimensione (Start-OperationLog -MaxBytes) e viene superato, la
        scrittura su file si interrompe silenziosamente (la stampa a schermo
        continua sempre): il chiamante puo' controllare $script:LogTruncated
        per sapere se e' successo e avvisare l'utente una sola volta.
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

    if ($script:LogWriter -and -not $script:LogTruncated) {
        $timestamp = Get-Date -Format 'HH:mm:ss'
        $line      = "{0} [{1}] {2}" -f $timestamp, $Level, $Message
        $lineBytes = [System.Text.Encoding]::UTF8.GetByteCount($line) + 2

        if ($script:LogMaxBytes -gt 0 -and ($script:LogBytesWritten + $lineBytes) -gt $script:LogMaxBytes) {
            try {
                $script:LogWriter.WriteLine('=== LOG TRUNCATO: limite di dimensione raggiunto ===')
            } catch { }
            $script:LogTruncated = $true
        } else {
            $script:LogWriter.WriteLine($line)
            $script:LogBytesWritten += $lineBytes
        }
    }
}
