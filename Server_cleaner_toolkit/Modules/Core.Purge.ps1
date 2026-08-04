#
# Core.Purge.ps1
# Flusso di ricerca ed eliminazione file (purge). In questa Fase 1 e' solo
# uno stub di navigazione: la logica di scansione del server, il matching
# tollerante dei nomi file e l'eliminazione con conferma verranno
# implementati nelle Fasi 3/4.
#

function Invoke-PurgeMenu {
    <#
        Punto di ingresso del menu "Elimina un file (purge)". Per ora mostra
        solo un messaggio informativo; in Fase 3/4 chiedera' il nome del file,
        avviera' un log dedicato (Start-OperationLog) e la scansione del
        server, per poi presentare i risultati con opzioni di cancellazione.
    #>
    Show-ScreenHeader -Title $script:Lang.Purge_Header -Description $script:Lang.Purge_Description
    Write-Host $script:Lang.Purge_NotImplemented -ForegroundColor DarkYellow
    Write-Host ''
    Write-Host $script:Lang.Option_Back -ForegroundColor DarkGray
    Read-MenuChoice -MinValue 0 -MaxValue 0 | Out-Null
}
