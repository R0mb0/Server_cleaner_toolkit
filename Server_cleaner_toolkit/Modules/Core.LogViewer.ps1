#
# Core.LogViewer.ps1
# Elenco e visualizzazione dei log salvati nella cartella dello script.
# In lettura, ogni riga viene ricolorata in base al prefisso di livello
# [INFO]/[MATCH]/[DELETED]/... scritto da Write-Log (Core.Logging.ps1).
# Il contenuto viene mostrato paginato, in stile "more/less" da terminale.
#

function Invoke-LogViewerMenu {
    <#
        Elenca i file *.log presenti nella cartella dello script (i log sono
        sempre salvati li', accanto allo script stesso). L'utente sceglie un
        numero per aprirlo, oppure 0 per tornare al menu principale.
    #>
    while ($true) {
        Show-ScreenHeader -Title $script:Lang.Logs_Header -Description $script:Lang.Logs_Description

        $logFiles = @(Get-ChildItem -Path $script:LogFolderPath -Filter '*.log' -File -ErrorAction SilentlyContinue |
            Sort-Object -Property LastWriteTime -Descending)

        if ($logFiles.Count -eq 0) {
            Write-Host $script:Lang.Logs_None -ForegroundColor DarkGray
            Write-Host ''
            Write-Host $script:Lang.Option_Back -ForegroundColor DarkGray
            Read-MenuChoice -MinValue 0 -MaxValue 0 | Out-Null
            return
        }

        for ($i = 0; $i -lt $logFiles.Count; $i++) {
            Write-Host ("{0}. {1}" -f ($i + 1), $logFiles[$i].Name)
        }
        Write-Host ''
        Write-Host $script:Lang.Option_Back -ForegroundColor DarkGray

        $choice = Read-MenuChoice -MinValue 0 -MaxValue $logFiles.Count
        if ($choice -eq 0) { return }

        Show-LogFile -Path $logFiles[$choice - 1].FullName
    }
}

function Get-LogLineColor {
    <#
        Estrae il prefisso di livello (es. "[MATCH]") da una riga di log e
        restituisce il colore console corrispondente. Le righe senza un
        prefisso riconosciuto (es. le righe "=== Log avviato ===") vengono
        mostrate in bianco.
    #>
    param(
        [string]$Line
    )

    if ($Line -match '^\d{2}:\d{2}:\d{2}\s\[([A-Z]+)\]') {
        return Get-LogLevelColor -Level $Matches[1]
    }

    return 'White'
}

function Show-LogFile {
    <#
        Mostra il contenuto di un file di log a schermo, pagina per pagina
        (in stile "more"): una schermata di righe alla volta, poi INVIO per
        proseguire o 0 per tornare alla lista dei log senza finire il file.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $lines = @(Get-Content -Path $Path -ErrorAction SilentlyContinue)
    if ($lines.Count -eq 0) {
        $lines = @('')
    }

    # Righe utili per pagina: altezza finestra corrente meno spazio per
    # intestazione e indicatore di pagina. Minimo 10 per terminali piccoli.
    $windowHeight = 25
    try { $windowHeight = [Console]::WindowHeight } catch { }
    $pageSize = [Math]::Max(10, $windowHeight - 8)

    $totalPages = [Math]::Ceiling($lines.Count / $pageSize)
    if ($totalPages -eq 0) { $totalPages = 1 }

    $page = 0
    while ($page -lt $totalPages) {
        $title = $script:Lang.Logs_Viewing -f (Split-Path -Path $Path -Leaf)
        Show-ScreenHeader -Title $script:Lang.Logs_Header -Description $title

        $start = $page * $pageSize
        $end   = [Math]::Min($start + $pageSize, $lines.Count) - 1

        for ($i = $start; $i -le $end; $i++) {
            Write-Host $lines[$i] -ForegroundColor (Get-LogLineColor -Line $lines[$i])
        }

        $page++
        Write-Host ''
        if ($page -ge $totalPages) {
            Write-Host $script:Lang.Logs_EndOfFile -ForegroundColor DarkGray
            Write-Host $script:Lang.Option_Back -ForegroundColor DarkGray
            Read-MenuChoice -MinValue 0 -MaxValue 0 | Out-Null
            return
        }

        Write-Host ($script:Lang.Logs_PageIndicator -f $page, $totalPages) -ForegroundColor DarkCyan
        Write-Host $script:Lang.Logs_PagerHelp -ForegroundColor DarkGray
        # Qui non si riusa Read-MenuChoice: INVIO a vuoto deve significare
        # "pagina successiva" senza mostrare un errore di scelta non valida,
        # mentre "0" riporta alla lista dei log. Qualsiasi altro input viene
        # semplicemente ignorato e fa avanzare comunque alla pagina dopo.
        $userInput = (Read-Host).Trim()
        if ($userInput -eq '0') { return }
    }
}
