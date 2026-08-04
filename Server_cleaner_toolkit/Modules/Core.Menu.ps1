#
# Core.Menu.ps1
# Componenti UI riutilizzabili per la navigazione a menu: intestazione di
# pagina (con pulizia schermo), lettura di una scelta numerica validata e
# richiesta di conferma si/no.
#

function Show-ScreenHeader {
    <#
        Pulisce la console e stampa un'intestazione standard per la "pagina"
        corrente: titolo, e una breve descrizione di cosa si puo' fare in
        questa schermata.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [string]$Description
    )

    Clear-Host

    $bar = '=' * 64
    Write-Host $bar -ForegroundColor DarkCyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host $bar -ForegroundColor DarkCyan

    if ($Description) {
        Write-Host ''
        Write-Host $Description -ForegroundColor Yellow
    }

    Write-Host ''
}

function Format-MenuOption {
    <#
        Formatta una voce di menu numerata in modo uniforme, es. "1  Cambia lingua".
        Deliberatamente NESSUN segno di punteggiatura e' attaccato al numero
        (ne' punto "1.", ne' parentesi "1)"): con entrambi gli utenti sono
        stati tentati di digitare anche quel simbolo insieme al numero, e la
        scelta veniva rifiutata perche' l'input accetta solo cifre. Il doppio
        spazio basta a separare visivamente numero e testo. Le stringhe di
        traduzione non contengono il numero: viene sempre aggiunto qui, in un
        unico punto, cosi' il formato resta coerente in ogni lingua e menu.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$Number,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Text
    )

    return "{0}  {1}" -f $Number, $Text
}

function Read-MenuChoice {
    <#
        Chiede ripetutamente un input numerico finche' l'utente non digita un
        valore intero compreso tra MinValue e MaxValue. In caso di input non
        valido stampa il messaggio di errore localizzato e richiede di nuovo.
    #>
    param(
        [Parameter(Mandatory)]
        [int]$MinValue,

        [Parameter(Mandatory)]
        [int]$MaxValue,

        [string]$PromptText = '>'
    )

    while ($true) {
        Write-Host ''
        Write-Host $PromptText -ForegroundColor Yellow -NoNewline
        Write-Host ' ' -NoNewline
        $userInput = Read-Host

        if ($userInput -match '^\d+$') {
            $value = [int]$userInput
            if ($value -ge $MinValue -and $value -le $MaxValue) {
                return $value
            }
        }

        Write-Host $script:Lang.Invalid_Choice -ForegroundColor Red
    }
}

function Read-YesNoConfirmation {
    <#
        Chiede una conferma si/no localizzata (usando Confirm_Yes / Confirm_No
        dal file di lingua corrente, case-insensitive) e ripete la domanda
        finche' non riceve una risposta valida. Restituisce $true per si,
        $false per no.
    #>
    param(
        [string]$PromptText
    )

    if (-not $PromptText) {
        $PromptText = $script:Lang.Confirm_Prompt
    }

    while ($true) {
        Write-Host ''
        Write-Host $PromptText -ForegroundColor Yellow -NoNewline
        Write-Host ' ' -NoNewline
        $userInput = (Read-Host).Trim()

        if ($userInput -ieq $script:Lang.Confirm_Yes) { return $true }
        if ($userInput -ieq $script:Lang.Confirm_No)  { return $false }

        Write-Host $script:Lang.Invalid_Choice -ForegroundColor Red
    }
}
