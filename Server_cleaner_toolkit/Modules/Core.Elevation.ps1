#
# Core.Elevation.ps1
# Gestione dei privilegi amministrativi: verifica e auto-elevazione dello script.
#

function Test-IsAdministrator {
    <#
        Restituisce $true se la sessione PowerShell corrente e' in esecuzione
        con privilegi di amministratore, $false altrimenti.
    #>
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-SelfElevation {
    <#
        Rilancia lo script corrente in una nuova sessione PowerShell con
        privilegi elevati (prompt UAC). Restituisce $true se il rilancio e'
        stato avviato correttamente, $false in caso di errore o annullamento
        da parte dell'utente (es. UAC negato).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath
    )

    $argString = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

    try {
        Start-Process -FilePath 'powershell.exe' -ArgumentList $argString -Verb RunAs -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}
