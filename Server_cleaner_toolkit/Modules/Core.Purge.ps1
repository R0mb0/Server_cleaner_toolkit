#
# Core.Purge.ps1
# Flusso interattivo di ricerca ed eliminazione file (purge): chiede il nome
# del file, un piccolo "wizard" di opzioni (modalita' di log, limite
# dimensione log, esclusione cartelle di sistema pesanti), avvia la
# scansione (Core.Search.ps1) e presenta i risultati con possibilita' di
# eliminare singole corrispondenze o tutte insieme.
#

# Flag di controllo per permettere all'utente di annullare (0) in qualsiasi
# passaggio del wizard di opzioni e tornare subito al menu principale, senza
# dover reintrodurre una gestione a "pila" delle pagine precedenti.
$script:PurgeWizardCancelled = $false

function Read-LogModeChoice {
    <#
        Chiede se registrare la scansione in modalita' completa (ogni file
        osservato) o solo corrispondenze. 0 annulla e torna al menu
        principale (imposta $script:PurgeWizardCancelled).
    #>
    Show-ScreenHeader -Title $script:Lang.LogMode_Header -Description $script:Lang.LogMode_Description
    Write-Host (Format-MenuOption 1 $script:Lang.LogMode_Full)
    Write-Host (Format-MenuOption 2 $script:Lang.LogMode_MatchesOnly)
    Write-Host ''
    Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray

    $choice = Read-MenuChoice -MinValue 0 -MaxValue 2
    if ($choice -eq 0) {
        $script:PurgeWizardCancelled = $true
        return 'Full'
    }
    if ($choice -eq 1) { return 'Full' }
    return 'MatchesOnly'
}

function Read-LogSizeLimit {
    <#
        Chiede se impostare un limite massimo di dimensione per il file di
        log e, in caso affermativo, il valore (es. "500MB", "2GB"). Restituisce
        il limite in byte, oppure 0 per "nessun limite". 0 nel menu annulla e
        torna al menu principale.
    #>
    Show-ScreenHeader -Title $script:Lang.LogLimit_Header -Description $script:Lang.LogLimit_Description
    Write-Host (Format-MenuOption 1 $script:Lang.LogLimit_None)
    Write-Host (Format-MenuOption 2 $script:Lang.LogLimit_Custom)
    Write-Host ''
    Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray

    $choice = Read-MenuChoice -MinValue 0 -MaxValue 2
    if ($choice -eq 0) {
        $script:PurgeWizardCancelled = $true
        return 0
    }
    if ($choice -eq 1) { return 0 }

    while ($true) {
        Write-Host ''
        Write-Host $script:Lang.LogLimit_EnterValue -ForegroundColor Yellow -NoNewline
        Write-Host ' ' -NoNewline
        $sizeInput = Read-Host
        $bytes = ConvertTo-ByteSize -Text $sizeInput
        if ($null -ne $bytes -and $bytes -gt 0) { return $bytes }
        Write-Host $script:Lang.LogLimit_InvalidValue -ForegroundColor Red
    }
}

function Read-ExclusionChoice {
    <#
        Chiede, con una scelta numerata (non un si/no libero, per coerenza
        con le altre impostazioni del wizard), se escludere le cartelle di
        sistema pesanti dalla scansione generale dei dischi. 0 annulla e
        torna al menu principale.
    #>
    Show-ScreenHeader -Title $script:Lang.Exclusions_Header -Description $script:Lang.Exclusions_Prompt
    Write-Host (Format-MenuOption 1 $script:Lang.Exclusions_Yes)
    Write-Host (Format-MenuOption 2 $script:Lang.Exclusions_No)
    Write-Host ''
    Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray

    $choice = Read-MenuChoice -MinValue 0 -MaxValue 2
    if ($choice -eq 0) {
        $script:PurgeWizardCancelled = $true
        return $true
    }
    return ($choice -eq 1)
}

function Format-ByteSize {
    <#
        Converte un numero di byte in una stringa leggibile ("500 MB",
        "2 GB"), oppure nel testo localizzato "nessun limite" se 0 o minore.
    #>
    param([long]$Bytes)

    if ($Bytes -le 0) { return $script:Lang.LogLimit_None }
    if ($Bytes -ge 1GB) { return "{0:N0} GB" -f ($Bytes / 1GB) }
    return "{0:N0} MB" -f ($Bytes / 1MB)
}

function Remove-SingleFile {
    <#
        Elimina fisicamente un file e registra l'esito (successo o errore)
        nel log corrente. Restituisce $true se l'eliminazione e' riuscita.
    #>
    param(
        [Parameter(Mandatory)]
        $Entry
    )

    try {
        Remove-Item -LiteralPath $Entry.FullPath -Force -ErrorAction Stop
        Write-Log ($script:Lang.Results_Deleted -f $Entry.FullPath) -Level DELETED
        return $true
    } catch {
        Write-Log ($script:Lang.Results_DeleteFailed -f $Entry.FullPath, $_.Exception.Message) -Level ERROR
        return $false
    }
}

function Show-PurgeResults {
    <#
        Mostra l'elenco numerato delle corrispondenze trovate (1..N), con
        un'opzione aggiuntiva N+1 per eliminarle tutte insieme, e 0 per
        tornare al menu principale senza eliminare nulla. Dopo ogni
        eliminazione la lista viene ridisegnata rinumerata; quando resta
        vuota si torna automaticamente al menu principale.
    #>
    param(
        [Parameter(Mandatory)]
        [System.Collections.Generic.List[object]]$Results
    )

    while ($true) {
        if ($Results.Count -eq 0) {
            Write-Host ''
            Write-Host $script:Lang.Results_ReturningToMain -ForegroundColor DarkGray
            Start-Sleep -Seconds 1
            return
        }

        Show-ScreenHeader -Title $script:Lang.Results_Header -Description $script:Lang.Results_Description

        for ($i = 0; $i -lt $Results.Count; $i++) {
            $entry = $Results[$i]
            $tag = ''
            if ($entry.IsHidden) { $tag += $script:Lang.Scan_Hidden }
            if ($entry.IsLink)   { $tag += $script:Lang.Scan_Link }
            Write-Host (Format-MenuOption ($i + 1) "$($entry.FullPath)$tag") -ForegroundColor Green
        }

        $deleteAllNumber = $Results.Count + 1
        Write-Host ''
        Write-Host (Format-MenuOption $deleteAllNumber ($script:Lang.Results_DeleteAll -f $Results.Count)) -ForegroundColor Yellow
        Write-Host ''
        Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray

        $choice = Read-MenuChoice -MinValue 0 -MaxValue $deleteAllNumber
        if ($choice -eq 0) { return }

        if ($choice -eq $deleteAllNumber) {
            Write-Host ''
            Write-Host ($script:Lang.Results_ConfirmDeleteAll -f $Results.Count) -ForegroundColor Yellow
            if (Read-YesNoConfirmation) {
                foreach ($entry in @($Results)) {
                    Remove-SingleFile -Entry $entry | Out-Null
                }
                $Results.Clear()
            }
            continue
        }

        $selected = $Results[$choice - 1]
        Write-Host ''
        Write-Host $script:Lang.Results_ConfirmDeleteOne -ForegroundColor Yellow
        Write-Host $selected.FullPath -ForegroundColor Green
        if (Read-YesNoConfirmation) {
            $deleted = Remove-SingleFile -Entry $selected
            if ($deleted) {
                $Results.RemoveAt($choice - 1)
            } else {
                Start-Sleep -Seconds 2
            }
        }
    }
}

function Invoke-PurgeMenu {
    <#
        Punto di ingresso del menu "Elimina un file (purge)". Ordine voluto:
        1) nome del file (cosi' si puo' aprire subito il log con quel nome);
        2) wizard di opzioni, tutto a scelta numerata (modalita' di log,
           limite dimensione, esclusione cartelle pesanti) - ogni scelta
           viene anche scritta nel log gia' aperto;
        3) riepilogo e conferma si/no per avviare davvero la scansione
           (unica eccezione, insieme alla cancellazione dei file, in cui si
           risponde a testo libero invece che con un numero);
        4) scansione e presentazione dei risultati.
    #>
    Show-ScreenHeader -Title $script:Lang.Purge_Header -Description $script:Lang.Purge_Description
    Write-Host $script:Lang.Purge_AskFileName -ForegroundColor Yellow
    Write-Host '>' -ForegroundColor Yellow -NoNewline
    Write-Host ' ' -NoNewline
    $fileName = (Read-Host).Trim()

    # Un nome vuoto (solo INVIO) equivale a rinunciare e tornare al menu
    # principale: non essendo un menu numerato non ha senso chiedere "0", e
    # non avendo ancora un nome non ha senso aprire un log.
    if ([string]::IsNullOrWhiteSpace($fileName)) { return }

    $script:PurgeWizardCancelled = $false

    try {
        # Il log si apre subito, con il nome del file appena inserito: tutte
        # le scelte successive del wizard vengono registrate qui, anche se
        # poi l'utente dovesse annullare prima di arrivare alla scansione.
        Start-OperationLog -OperationName $fileName -LogFolder $script:LogFolderPath -MaxBytes 0 | Out-Null

        $logMode = Read-LogModeChoice
        if ($script:PurgeWizardCancelled) {
            Write-Log $script:Lang.Purge_Cancelled -Level WARN
            return
        }
        $logModeLabel = if ($logMode -eq 'Full') { $script:Lang.LogMode_Full } else { $script:Lang.LogMode_MatchesOnly }
        Write-Log ($script:Lang.Purge_SummaryLogMode -f $logModeLabel) -Level INFO

        $maxBytes = Read-LogSizeLimit
        if ($script:PurgeWizardCancelled) {
            Write-Log $script:Lang.Purge_Cancelled -Level WARN
            return
        }
        # Il limite scelto vale da qui in avanti: le righe gia' scritte nel
        # log durante il wizard non vengono ricontate retroattivamente.
        $script:LogMaxBytes = $maxBytes
        Write-Log ($script:Lang.Purge_SummaryLogLimit -f (Format-ByteSize -Bytes $maxBytes)) -Level INFO

        $excludeHeavy = Read-ExclusionChoice
        if ($script:PurgeWizardCancelled) {
            Write-Log $script:Lang.Purge_Cancelled -Level WARN
            return
        }
        $exclusionLabel = if ($excludeHeavy) { $script:Lang.Confirm_Yes } else { $script:Lang.Confirm_No }
        Write-Log ($script:Lang.Purge_SummaryExclusions -f $exclusionLabel) -Level INFO

        Show-ScreenHeader -Title $script:Lang.Purge_SummaryHeader
        Write-Host ($script:Lang.Purge_SummaryFile -f $fileName)
        Write-Host ($script:Lang.Purge_SummaryLogMode -f $logModeLabel)
        Write-Host ($script:Lang.Purge_SummaryLogLimit -f (Format-ByteSize -Bytes $maxBytes))
        Write-Host ($script:Lang.Purge_SummaryExclusions -f $exclusionLabel)
        Write-Host ''
        Write-Host $script:Lang.Purge_ConfirmStart -ForegroundColor Yellow

        if (-not (Read-YesNoConfirmation)) {
            Write-Log $script:Lang.Purge_ScanCancelled -Level WARN
            return
        }

        $results = Search-ServerForFile -FileNameInput $fileName -ExcludeHeavySystemFolders $excludeHeavy -VerboseMode $logMode -IncludeNetworkDrives $true

        if ($script:LogTruncated) {
            Write-Host ''
            Write-Host $script:Lang.Scan_LogTruncated -ForegroundColor DarkYellow
        }

        Show-PurgeResults -Results $results
    } finally {
        # Va sempre eseguito, anche se l'utente annulla a meta' wizard o la
        # ricerca viene interrotta da un errore imprevisto, per non lasciare
        # il file di log aperto.
        Stop-OperationLog
    }
}
