#
# Core.Search.ps1
# Motore di ricerca file. Fase 2: enumerazione dischi (fissi e di rete),
# individuazione delle cache note (IIS, ASP.NET, XAMPP/WAMP/Laragon, Temp),
# confronto tollerante dei nomi (spazi/trattini/underscore, suffissi di
# copia, caratteri speciali) e scansione iterativa (non ricorsiva a livello
# di chiamate di funzione, per non avere limiti di profondita' sulle cartelle
# molto annidate) con rilevamento di file nascosti e collegamenti.
#
# NOTA: su percorsi molto profondi (oltre ~260 caratteri) Get-ChildItem su
# Windows PowerShell 5.1 puo' fallire per il limite storico di Windows sulla
# lunghezza dei percorsi; in quel caso la cartella viene segnalata come
# "accesso negato" e la scansione prosegue con le altre.
#

function Get-HeavySystemExclusions {
    <#
        Elenco di cartelle di sistema molto pesanti e dove un documento
        utente non finirebbe mai, usate come esclusione opzionale durante la
        scansione generale dei dischi (non si applicano mai alle cache note,
        che restano sempre incluse indipendentemente da questa impostazione).
    #>
    $roots = New-Object System.Collections.Generic.List[string]

    if ($env:SystemRoot) {
        $roots.Add((Join-Path $env:SystemRoot 'WinSxS'))
        $roots.Add((Join-Path $env:SystemRoot 'System32'))
        $roots.Add((Join-Path $env:SystemRoot 'SysWOW64'))
        $roots.Add((Join-Path $env:SystemRoot 'servicing'))
        $roots.Add((Join-Path $env:SystemRoot 'assembly'))
        $roots.Add((Join-Path $env:SystemRoot 'Installer'))
        $roots.Add((Join-Path $env:SystemRoot 'SoftwareDistribution'))
    }
    if ($env:ProgramData) {
        $roots.Add((Join-Path $env:ProgramData 'Microsoft\Windows Defender'))
        $roots.Add((Join-Path $env:ProgramData 'Microsoft\Windows\WER'))
    }
    if ($env:SystemDrive) {
        $roots.Add((Join-Path $env:SystemDrive '$Recycle.Bin'))
        $roots.Add((Join-Path $env:SystemDrive 'System Volume Information'))
    }

    return $roots
}

function Get-ScanRoots {
    <#
        Restituisce le radici dei dischi da scansionare: sempre i dischi
        fissi locali, e le unita' di rete mappate se richiesto.
    #>
    param(
        [switch]$IncludeNetworkDrives
    )

    $roots = New-Object System.Collections.Generic.List[string]

    try {
        $wantedTypes = @(3)
        if ($IncludeNetworkDrives) { $wantedTypes += 4 }

        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop |
            Where-Object { $wantedTypes -contains $_.DriveType }

        foreach ($d in $disks) {
            if ($d.DeviceID) { $roots.Add("$($d.DeviceID)\") }
        }
    } catch {
        # Fallback se CIM non e' disponibile: non distingue disco fisso da
        # rete, ma e' meglio di non scansionare nulla.
        Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Root) { $roots.Add($_.Root) }
        }
    }

    return $roots
}

function Get-KnownCachePaths {
    <#
        Individua le cartelle "cache" note gia' esistenti sul server: IIS,
        ASP.NET temporaneo, Windows Temp, e le cartelle tipiche degli stack
        di sviluppo web piu' comuni su Windows (XAMPP, WAMP, Laragon) su ogni
        disco fisso, oltre alla cartella Temp di ogni profilo utente. Vengono
        sempre scansionate per prime e per intero, indipendentemente
        dall'impostazione di esclusione delle cartelle di sistema pesanti.
    #>
    $candidates = New-Object System.Collections.Generic.List[hashtable]

    $candidates.Add(@{ Path = 'C:\inetpub\wwwroot'; Label = 'IIS wwwroot' })
    $candidates.Add(@{ Path = 'C:\inetpub\temp\IIS Temporary Compressed Files'; Label = 'IIS Compressed Cache' })

    if ($env:SystemRoot) {
        foreach ($fxRoot in @('Microsoft.NET\Framework', 'Microsoft.NET\Framework64')) {
            $fullFxRoot = Join-Path $env:SystemRoot $fxRoot
            if (Test-Path -Path $fullFxRoot) {
                Get-ChildItem -Path $fullFxRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    $tempPath = Join-Path $_.FullName 'Temporary ASP.NET Files'
                    if (Test-Path -Path $tempPath) {
                        $candidates.Add(@{ Path = $tempPath; Label = "ASP.NET Temp ($($_.Name))" })
                    }
                }
            }
        }
        $candidates.Add(@{ Path = (Join-Path $env:SystemRoot 'Temp'); Label = 'Windows Temp' })
    }

    if ($env:TEMP) {
        $candidates.Add(@{ Path = $env:TEMP; Label = 'TEMP corrente' })
    }

    foreach ($drive in (Get-ScanRoots)) {
        foreach ($sub in @('xampp\htdocs', 'xampp\tmp', 'wamp\www', 'wamp64\www', 'laragon\www')) {
            $p = Join-Path $drive $sub
            if (Test-Path -Path $p) {
                $candidates.Add(@{ Path = $p; Label = $sub })
            }
        }
    }

    $usersRoot = Join-Path $env:SystemDrive 'Users'
    if (Test-Path -Path $usersRoot) {
        Get-ChildItem -Path $usersRoot -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notin @('Public', 'Default', 'Default User', 'All Users') } |
            ForEach-Object {
                $p = Join-Path $_.FullName 'AppData\Local\Temp'
                if (Test-Path -Path $p) {
                    $candidates.Add(@{ Path = $p; Label = "Temp utente ($($_.Name))" })
                }
            }
    }

    $seen   = New-Object System.Collections.Generic.HashSet[string]
    $result = New-Object System.Collections.Generic.List[object]
    foreach ($c in $candidates) {
        $key = $c.Path.TrimEnd('\').ToLowerInvariant()
        if ((Test-Path -Path $c.Path) -and $seen.Add($key)) {
            $result.Add([PSCustomObject]@{ Path = $c.Path; Label = $c.Label })
        }
    }

    return $result
}

function Test-PathExcluded {
    <#
        Verifica se un percorso e' uguale a, o si trova sotto, una delle
        cartelle nell'elenco di esclusione fornito (confronto case-insensitive
        per prefisso di percorso).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string[]]$ExcludeList = @()
    )

    if (-not $ExcludeList -or $ExcludeList.Count -eq 0) { return $false }

    $normalizedPath = $Path.TrimEnd('\').ToLowerInvariant()

    foreach ($ex in $ExcludeList) {
        if ([string]::IsNullOrWhiteSpace($ex)) { continue }
        $normalizedEx = $ex.TrimEnd('\').ToLowerInvariant()
        if ($normalizedPath -eq $normalizedEx -or $normalizedPath.StartsWith("$normalizedEx\")) {
            return $true
        }
    }

    return $false
}

function ConvertTo-NormalizedName {
    <#
        Normalizza un nome file per il confronto tollerante: minuscolo, e
        spazi/trattini/underscore/punti uniformati a un singolo spazio, cosi'
        "mio file", "mio-file", "mio_file" e "mio.file" risultano equivalenti.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Name)

    $n = $Name.ToLowerInvariant()
    $n = [regex]::Replace($n, '[\s_\-\.]+', ' ')
    return $n.Trim()
}

function ConvertTo-StrippedName {
    <#
        Variante ancora piu' tollerante: rimuove qualunque carattere che non
        sia lettera o cifra. Usata come secondo livello di confronto per
        nomi con punteggiatura o caratteri speciali molto diversi.
    #>
    param([Parameter(Mandatory)][AllowEmptyString()][string]$Name)

    return [regex]::Replace($Name.ToLowerInvariant(), '[^a-z0-9]', '')
}

function Remove-CopySuffix {
    <#
        Rimuove dal nome normalizzato i suffissi tipici delle copie generate
        automaticamente da Windows: "(1)", "(2)", "copy", "copia", "kopie",
        "copie", anche ripetuti, cosi' "report (1)" puo' confrontarsi con
        "report".
    #>
    param([Parameter(Mandatory)][string]$NormalizedName)

    $pattern  = '(\s*-?\s*(copy|copia|kopie|copie)\s*\d*|\s*\(\d+\)|\s+\d+)$'
    $result   = $NormalizedName
    $previous = $null

    while ($result -ne $previous) {
        $previous = $result
        $result   = [regex]::Replace($result, $pattern, '', 'IgnoreCase').Trim()
    }

    return $result
}

function Get-TargetVariants {
    <#
        Costruisce le varianti normalizzate del nome cercato dall'utente,
        usate per il confronto tollerante con i file trovati sul server.
    #>
    param([Parameter(Mandatory)][string]$RawInput)

    $trimmedInput = $RawInput.Trim()
    $withoutExt   = [System.IO.Path]::GetFileNameWithoutExtension($trimmedInput)
    if ([string]::IsNullOrWhiteSpace($withoutExt)) { $withoutExt = $trimmedInput }

    return [PSCustomObject]@{
        Normalized = ConvertTo-NormalizedName -Name $withoutExt
        Stripped   = ConvertTo-StrippedName   -Name $withoutExt
    }
}

function Test-NameMatches {
    <#
        Confronta il nome base (senza estensione) di un file trovato con le
        varianti del nome cercato. Le verifiche "contiene" si applicano solo
        se il termine cercato ha almeno 3 caratteri normalizzati, per evitare
        un numero eccessivo di falsi positivi con input molto corti.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$CandidateBaseName,

        [Parameter(Mandatory)]
        $TargetVariants
    )

    $targetNormalized = $TargetVariants.Normalized
    $targetStripped    = $TargetVariants.Stripped
    if ([string]::IsNullOrWhiteSpace($targetNormalized)) { return $false }

    $candidateNormalized = ConvertTo-NormalizedName -Name $CandidateBaseName
    if ([string]::IsNullOrWhiteSpace($candidateNormalized)) { return $false }
    $candidateStripped = ConvertTo-StrippedName -Name $CandidateBaseName
    $candidateNoCopy   = Remove-CopySuffix -NormalizedName $candidateNormalized

    if ($candidateNormalized -eq $targetNormalized) { return $true }
    if ($candidateNoCopy -eq $targetNormalized)     { return $true }
    if (-not [string]::IsNullOrWhiteSpace($targetStripped) -and $candidateStripped -eq $targetStripped) {
        return $true
    }

    if ($targetNormalized.Length -ge 3) {
        if ($candidateNormalized.Contains($targetNormalized)) { return $true }
        if ($candidateNoCopy.Contains($targetNormalized))     { return $true }
        if (-not [string]::IsNullOrWhiteSpace($targetStripped) -and $targetStripped.Length -ge 3 -and $candidateStripped.Contains($targetStripped)) {
            return $true
        }
        if ($candidateNormalized.Length -ge 3 -and $targetNormalized.Contains($candidateNormalized)) {
            return $true
        }
    }

    return $false
}

function Show-ScanProgress {
    <#
        Indicatore di avanzamento "leggero" per la modalita' di log
        MatchesOnly: riscrive la stessa riga di console (senza scenderne una
        nuova, e senza scrivere nel file di log) con il percorso della
        cartella attualmente in scansione, cosi' l'utente vede che lo script
        sta lavorando senza gonfiare ne' la console ne' il log.
    #>
    param([string]$Path)

    $line = $script:Lang.Scan_Folder -f $Path
    if ($line.Length -gt 100) { $line = $line.Substring(0, 100) }
    Write-Host ("`r{0}" -f $line.PadRight(100)) -NoNewline -ForegroundColor DarkGray
}

function Invoke-DirectoryWalk {
    <#
        Cammina la struttura di cartelle a partire da RootPath usando una
        pila esplicita (non chiamate ricorsive), cosi' da non avere limiti di
        profondita' anche su alberi di cartelle molto annidati. Per ogni
        cartella visitata, cataloga i file al suo interno; quelli che
        corrispondono alle varianti cercate finiscono in Results (con i tag
        di nascosto/collegamento) e vengono sempre stampati e loggati; gli
        altri file vengono stampati/loggati solo in modalita' 'Full'.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$RootPath,

        [Parameter(Mandatory)]
        $TargetVariants,

        [ValidateSet('Full', 'MatchesOnly')]
        [string]$VerboseMode = 'Full',

        [string[]]$ExcludePaths = @(),

        # NB: niente [Parameter(Mandatory)] qui. PowerShell rifiuta di
        # bindare una collezione vuota a un parametro obbligatorio ("Cannot
        # bind argument... because it is an empty collection"), e all'inizio
        # di ogni scansione la lista dei risultati e' vuota per definizione
        # (nessuna corrispondenza ancora trovata).
        [System.Collections.Generic.List[object]]$Results
    )

    if (-not (Test-Path -Path $RootPath)) { return }
    if (Test-PathExcluded -Path $RootPath -ExcludeList $ExcludePaths) { return }

    $stack = New-Object System.Collections.Generic.Stack[string]
    $stack.Push($RootPath)

    while ($stack.Count -gt 0) {
        $current = $stack.Pop()

        if ($VerboseMode -eq 'Full') {
            Write-Log ($script:Lang.Scan_Folder -f $current) -Level SCAN
        } else {
            Show-ScanProgress -Path $current
        }

        $items = $null
        try {
            $items = Get-ChildItem -LiteralPath $current -Force -ErrorAction Stop
        } catch {
            if ($VerboseMode -ne 'Full') { Write-Host '' }
            Write-Log ($script:Lang.Scan_AccessDenied -f $current) -Level WARN
            continue
        }

        foreach ($item in $items) {
            # Ogni elemento viene elaborato nel proprio try/catch: su una
            # cartella "viva" come Windows\Temp e' normale che un file
            # scompaia (cancellato da un altro processo) proprio nell'istante
            # in cui lo si sta osservando. Senza questa protezione, un errore
            # su un singolo elemento fermava silenziosamente l'intera
            # scansione (il messaggio d'errore veniva subito cancellato dal
            # ridisegno del menu principale, dando l'impressione che lo
            # script fosse semplicemente "tornato indietro" da solo).
            try {
                if ($item.PSIsContainer) {
                    $isReparse = (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)
                    # Le cartelle "collegamento" (junction/symlink) non vengono
                    # attraversate, per evitare cicli infiniti (es. cartelle che
                    # rimandano a se stesse o a un antenato).
                    if ($isReparse) { continue }
                    if (Test-PathExcluded -Path $item.FullName -ExcludeList $ExcludePaths) { continue }
                    $stack.Push($item.FullName)
                } else {
                    $isMatch = Test-NameMatches -CandidateBaseName $item.BaseName -TargetVariants $TargetVariants

                    if ($isMatch) {
                        $isHidden = (($item.Attributes -band [IO.FileAttributes]::Hidden) -ne 0)
                        $isLink   = (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)

                        $tag = ''
                        if ($isHidden) { $tag += $script:Lang.Scan_Hidden }
                        if ($isLink)   { $tag += $script:Lang.Scan_Link }

                        if ($VerboseMode -ne 'Full') { Write-Host '' }
                        Write-Log (($script:Lang.Scan_Match -f $item.FullName) + $tag) -Level MATCH

                        $Results.Add([PSCustomObject]@{
                            FullPath = $item.FullName
                            IsHidden = $isHidden
                            IsLink   = $isLink
                        })
                    } elseif ($VerboseMode -eq 'Full') {
                        Write-Log $item.FullName -Level SCAN
                    }
                }
            } catch {
                if ($VerboseMode -ne 'Full') { Write-Host '' }
                Write-Log ($script:Lang.Scan_ItemError -f $item.FullName, $_.Exception.Message) -Level WARN
            }
        }
    }

    if ($VerboseMode -ne 'Full') {
        Write-Host ''
    }
}

function Search-ServerForFile {
    <#
        Orchestratore della ricerca: scansiona prima le cache note (sempre
        per intero) e poi ogni disco individuato (fisso, e di rete se
        richiesto), evitando di ripetere la scansione delle cache gia'
        coperte. Restituisce l'elenco delle corrispondenze trovate.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FileNameInput,

        [bool]$ExcludeHeavySystemFolders = $true,

        [ValidateSet('Full', 'MatchesOnly')]
        [string]$VerboseMode = 'Full',

        [bool]$IncludeNetworkDrives = $true
    )

    $targetVariants = Get-TargetVariants -RawInput $FileNameInput
    $results        = New-Object System.Collections.Generic.List[object]

    Write-Log ($script:Lang.Scan_Starting -f $FileNameInput) -Level HEADER

    $scannedRoots = New-Object System.Collections.Generic.List[string]
    $cachePaths   = Get-KnownCachePaths

    foreach ($cache in $cachePaths) {
        Write-Log ($script:Lang.Scan_CacheLocation -f $cache.Label) -Level SCAN
        Invoke-DirectoryWalk -RootPath $cache.Path -TargetVariants $targetVariants -VerboseMode $VerboseMode -ExcludePaths @() -Results $results
        $scannedRoots.Add($cache.Path)
    }

    $excludeForDrives = New-Object System.Collections.Generic.List[string]
    foreach ($r in $scannedRoots) { $excludeForDrives.Add($r) }
    if ($ExcludeHeavySystemFolders) {
        foreach ($r in (Get-HeavySystemExclusions)) { $excludeForDrives.Add($r) }
    }

    $driveRoots = Get-ScanRoots -IncludeNetworkDrives:$IncludeNetworkDrives
    foreach ($root in $driveRoots) {
        Write-Log ($script:Lang.Scan_Drive -f $root) -Level SCAN
        Invoke-DirectoryWalk -RootPath $root -TargetVariants $targetVariants -VerboseMode $VerboseMode -ExcludePaths $excludeForDrives -Results $results
    }

    if ($results.Count -eq 0) {
        Write-Log ($script:Lang.Scan_NoMatches -f $FileNameInput) -Level WARN
    } else {
        Write-Log ($script:Lang.Scan_Completed -f $results.Count) -Level SUCCESS
    }

    return $results
}
