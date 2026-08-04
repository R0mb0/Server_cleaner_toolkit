#Requires -Version 5.1
<#
    ServerCleaner-Portable.ps1
    --------------------------
    Versione a FILE SINGOLO di ServerCleaner.ps1, generata automaticamente il
    2026-08-04 unendo lo script principale, tutti i moduli in
    Modules\*.ps1 e tutte le lingue in Lang\*.psd1 (incorporate come dati,
    non piu' come file esterni).

    Nessuna dipendenza da altri file: puoi copiare SOLO questo .ps1 su
    qualunque Windows Server 2016+ e lanciarlo direttamente, senza portare
    con te le cartelle Modules\ e Lang\.

    IMPORTANTE: questo file e' generato automaticamente. Per sviluppare
    nuove funzionalita' o correggere bug si lavora sulla versione modulare
    (ServerCleaner.ps1 + Modules\ + Lang\); questo file va poi rigenerato
    da quella (chiedi di "rigenerare la versione portable" dopo ogni
    modifica) per restare allineato.
#>

# Dati di lingua incorporati (generati da Lang\*.psd1 della versione modulare).
$script:AllLanguageData = @{
    it = @{
    AppTitle        = 'Server Cleaner Toolkit'
    Press_Enter     = 'Premi INVIO per continuare...'
    Invalid_Choice  = 'Scelta non valida. Riprova.'
    Exiting         = 'Chiusura dello script...'
    Confirm_Yes     = 'si'
    Confirm_No      = 'no'
    Confirm_Prompt  = 'Sei sicuro di voler procedere? (si/no)'

    MainMenu_Header      = 'MENU PRINCIPALE'
    MainMenu_Description = 'Seleziona quale operazione svolgere:'
    MainMenu_Option1     = 'Cambia lingua'
    MainMenu_Option2     = 'Elimina un file (purge)'
    MainMenu_Option3     = 'Visualizza i log'
    Option_Exit          = 'Esci'
    Option_Back          = 'Torna indietro'

    LangMenu_Header      = 'CAMBIO LINGUA'
    LangMenu_Description = 'Scegli la lingua da utilizzare per questa sessione (la lingua attuale è contrassegnata con *):'
    LangMenu_Changed     = 'Lingua impostata su: {0}'

    Purge_Header         = 'PURGE FILE'
    Purge_Description    = 'Cerca ed elimina un file dal server.'
    Purge_NotImplemented = 'Questa funzione sarà disponibile nelle prossime fasi di sviluppo (Fase 3/4).'

    Logs_Header      = 'REGISTRO OPERAZIONI'
    Logs_Description = 'Seleziona il numero del log da aprire.'
    Logs_None        = 'Nessun log presente nella cartella dello script.'
    Logs_Viewing     = 'Visualizzazione log: {0}'
    Logs_PageIndicator = 'Pagina {0} di {1}'
    Logs_PagerHelp      = 'INVIO per continuare, 0 per tornare alla lista.'
    Logs_EndOfFile      = 'Fine del file.'

    Elevation_Requesting = 'Privilegi amministrativi richiesti, riavvio in corso...'
    Elevation_Failed     = 'Impossibile ottenere i privilegi amministrativi. Lo script verrà chiuso.'

    Purge_AskFileName = 'Inserisci il nome (anche parziale) del file da cercare:'

    LogMode_Header      = 'MODALITÀ DI REGISTRAZIONE'
    LogMode_Description = 'Scegli come registrare la scansione nel file di log:'
    LogMode_Full        = 'Completa: registra ogni file osservato durante la scansione'
    LogMode_MatchesOnly = 'Solo corrispondenze: registra solo i file trovati e le operazioni principali'

    LogLimit_Header       = 'LIMITE DIMENSIONE LOG'
    LogLimit_Description  = 'Vuoi impostare una dimensione massima per il file di log?'
    LogLimit_None         = 'Nessun limite'
    LogLimit_Custom       = 'Imposta un limite (es. 500MB, 2GB)'
    LogLimit_EnterValue   = 'Inserisci la dimensione massima (es. 500MB oppure 2GB):'
    LogLimit_InvalidValue = 'Formato non valido. Esempio: 500MB oppure 2GB.'

    Exclusions_Prompt = 'Le cartelle di sistema molto pesanti (WinSxS, System32, cache di Windows Defender, ecc.) raramente contengono documenti utente. Le cache web (IIS/ASP.NET/XAMPP) restano comunque sempre incluse.'
    Exclusions_Header = 'ESCLUSIONE CARTELLE DI SISTEMA'
    Exclusions_Yes    = 'Sì, escludile dalla scansione (più veloce)'
    Exclusions_No     = 'No, scansiona anche quelle'

    Purge_Cancelled = 'Operazione annullata dall''utente.'

    Purge_SummaryHeader      = 'RIEPILOGO IMPOSTAZIONI'
    Purge_SummaryFile        = 'File da cercare: {0}'
    Purge_SummaryLogMode     = 'Modalità di log: {0}'
    Purge_SummaryLogLimit    = 'Limite log: {0}'
    Purge_SummaryExclusions  = 'Esclusione cartelle pesanti: {0}'
    Purge_ConfirmStart       = 'Vuoi avviare la scansione con queste impostazioni?'
    Purge_ScanCancelled      = 'Scansione annullata dall''utente.'

    Scan_Starting      = 'Avvio scansione per: {0}'
    Scan_CacheLocation = 'Controllo cache: {0}'
    Scan_Drive         = 'Scansione unità: {0}'
    Scan_Folder        = 'Cartella: {0}'
    Scan_Match         = 'Corrispondenza: {0}'
    Scan_Hidden        = ' [nascosto]'
    Scan_Link          = ' [collegamento]'
    Scan_Completed     = 'Scansione completata. Corrispondenze trovate: {0}'
    Scan_NoMatches     = 'Nessuna corrispondenza trovata per: {0}'
    Scan_LogTruncated  = 'Limite dimensione log raggiunto: le righe successive non verranno più salvate su file (la scansione prosegue comunque).'
    Scan_AccessDenied  = 'Accesso negato, cartella saltata: {0}'
    Scan_ItemError     = 'Elemento saltato per errore: {0} ({1})'

    Results_Header           = 'RISULTATI RICERCA'
    Results_Description      = 'Seleziona il numero dell''elemento da eliminare, oppure l''ultima opzione per eliminarli tutti.'
    Results_DeleteAll        = 'Elimina tutte le {0} corrispondenze trovate'
    Results_ConfirmDeleteOne = 'Sei sicuro di voler eliminare questo file?'
    Results_ConfirmDeleteAll = 'Sei sicuro di voler eliminare TUTTE le {0} corrispondenze trovate?'
    Results_Deleted          = 'Eliminato: {0}'
    Results_DeleteFailed     = 'Impossibile eliminare {0}: {1}'
    Results_ReturningToMain  = 'Nessuna corrispondenza rimanente: ritorno al menu principale.'

    App_UnexpectedError = 'Si è verificato un errore imprevisto: {0}'
    }
    en = @{
    AppTitle        = 'Server Cleaner Toolkit'
    Press_Enter     = 'Press ENTER to continue...'
    Invalid_Choice  = 'Invalid choice. Try again.'
    Exiting         = 'Closing the script...'
    Confirm_Yes     = 'yes'
    Confirm_No      = 'no'
    Confirm_Prompt  = 'Are you sure you want to proceed? (yes/no)'

    MainMenu_Header      = 'MAIN MENU'
    MainMenu_Description = 'Select which operation to perform:'
    MainMenu_Option1     = 'Change language'
    MainMenu_Option2     = 'Delete a file (purge)'
    MainMenu_Option3     = 'View logs'
    Option_Exit          = 'Exit'
    Option_Back          = 'Go back'

    LangMenu_Header      = 'LANGUAGE SETTINGS'
    LangMenu_Description = 'Choose the language to use for this session (current language marked with *):'
    LangMenu_Changed     = 'Language set to: {0}'

    Purge_Header         = 'FILE PURGE'
    Purge_Description    = 'Search for and delete a file from the server.'
    Purge_NotImplemented = 'This feature will be available in upcoming development phases (Phase 3/4).'

    Logs_Header      = 'OPERATION LOGS'
    Logs_Description = 'Select the number of the log to open.'
    Logs_None        = 'No logs found in the script folder.'
    Logs_Viewing     = 'Viewing log: {0}'
    Logs_PageIndicator = 'Page {0} of {1}'
    Logs_PagerHelp      = 'Press ENTER to continue, 0 to return to the list.'
    Logs_EndOfFile      = 'End of file.'

    Elevation_Requesting = 'Administrator privileges required, restarting...'
    Elevation_Failed     = 'Could not obtain administrator privileges. The script will close.'

    Purge_AskFileName = 'Enter the (even partial) name of the file to search for:'

    LogMode_Header      = 'LOGGING MODE'
    LogMode_Description = 'Choose how to record the scan in the log file:'
    LogMode_Full        = 'Full: log every file observed during the scan'
    LogMode_MatchesOnly = 'Matches only: log only the files found and the main operations'

    LogLimit_Header       = 'LOG SIZE LIMIT'
    LogLimit_Description  = 'Do you want to set a maximum size for the log file?'
    LogLimit_None         = 'No limit'
    LogLimit_Custom       = 'Set a limit (e.g. 500MB, 2GB)'
    LogLimit_EnterValue   = 'Enter the maximum size (e.g. 500MB or 2GB):'
    LogLimit_InvalidValue = 'Invalid format. Example: 500MB or 2GB.'

    Exclusions_Prompt = 'Heavy system folders (WinSxS, System32, Windows Defender cache, etc.) rarely contain user documents. Web caches (IIS/ASP.NET/XAMPP) are always included regardless.'
    Exclusions_Header = 'SYSTEM FOLDER EXCLUSION'
    Exclusions_Yes    = 'Yes, exclude them from the scan (faster)'
    Exclusions_No     = 'No, scan those too'

    Purge_Cancelled = 'Operation cancelled by the user.'

    Purge_SummaryHeader      = 'SETTINGS SUMMARY'
    Purge_SummaryFile        = 'File to search for: {0}'
    Purge_SummaryLogMode     = 'Log mode: {0}'
    Purge_SummaryLogLimit    = 'Log limit: {0}'
    Purge_SummaryExclusions  = 'Exclude heavy folders: {0}'
    Purge_ConfirmStart       = 'Do you want to start the scan with these settings?'
    Purge_ScanCancelled      = 'Scan cancelled by the user.'

    Scan_Starting      = 'Starting scan for: {0}'
    Scan_CacheLocation = 'Checking cache: {0}'
    Scan_Drive         = 'Scanning drive: {0}'
    Scan_Folder        = 'Folder: {0}'
    Scan_Match         = 'Match: {0}'
    Scan_Hidden        = ' [hidden]'
    Scan_Link          = ' [link]'
    Scan_Completed     = 'Scan completed. Matches found: {0}'
    Scan_NoMatches     = 'No matches found for: {0}'
    Scan_LogTruncated  = 'Log size limit reached: further lines will no longer be saved to file (the scan continues anyway).'
    Scan_AccessDenied  = 'Access denied, folder skipped: {0}'
    Scan_ItemError     = 'Item skipped due to an error: {0} ({1})'

    Results_Header           = 'SEARCH RESULTS'
    Results_Description      = 'Select the number of the item to delete, or the last option to delete them all.'
    Results_DeleteAll        = 'Delete all {0} matches found'
    Results_ConfirmDeleteOne = 'Are you sure you want to delete this file?'
    Results_ConfirmDeleteAll = 'Are you sure you want to delete ALL {0} matches found?'
    Results_Deleted          = 'Deleted: {0}'
    Results_DeleteFailed     = 'Could not delete {0}: {1}'
    Results_ReturningToMain  = 'No matches left: returning to the main menu.'

    App_UnexpectedError = 'An unexpected error occurred: {0}'
    }
    fr = @{
    AppTitle        = 'Server Cleaner Toolkit'
    Press_Enter     = 'Appuyez sur ENTRÉE pour continuer...'
    Invalid_Choice  = 'Choix invalide. Veuillez réessayer.'
    Exiting         = 'Fermeture du script...'
    Confirm_Yes     = 'oui'
    Confirm_No      = 'non'
    Confirm_Prompt  = 'Êtes-vous sûr de vouloir continuer ? (oui/non)'

    MainMenu_Header      = 'MENU PRINCIPAL'
    MainMenu_Description = 'Sélectionnez l''opération à effectuer :'
    MainMenu_Option1     = 'Changer de langue'
    MainMenu_Option2     = 'Supprimer un fichier (purge)'
    MainMenu_Option3     = 'Afficher les journaux'
    Option_Exit          = 'Quitter'
    Option_Back          = 'Retour'

    LangMenu_Header      = 'PARAMÈTRES DE LANGUE'
    LangMenu_Description = 'Choisissez la langue à utiliser pour cette session (langue actuelle marquée d''un *) :'
    LangMenu_Changed     = 'Langue définie sur : {0}'

    Purge_Header         = 'SUPPRESSION DE FICHIER'
    Purge_Description    = 'Rechercher et supprimer un fichier du serveur.'
    Purge_NotImplemented = 'Cette fonctionnalité sera disponible dans les prochaines phases de développement (Phase 3/4).'

    Logs_Header      = 'JOURNAUX DES OPÉRATIONS'
    Logs_Description = 'Sélectionnez le numéro du journal à ouvrir.'
    Logs_None        = 'Aucun journal trouvé dans le dossier du script.'
    Logs_Viewing     = 'Affichage du journal : {0}'
    Logs_PageIndicator = 'Page {0} sur {1}'
    Logs_PagerHelp      = 'Appuyez sur ENTRÉE pour continuer, 0 pour revenir à la liste.'
    Logs_EndOfFile      = 'Fin du fichier.'

    Elevation_Requesting = 'Privilèges administrateur requis, redémarrage en cours...'
    Elevation_Failed     = 'Impossible d''obtenir les privilèges administrateur. Le script va se fermer.'

    Purge_AskFileName = 'Saisissez le nom (même partiel) du fichier à rechercher :'

    LogMode_Header      = 'MODE DE JOURNALISATION'
    LogMode_Description = 'Choisissez comment enregistrer l''analyse dans le journal :'
    LogMode_Full        = 'Complet : enregistre chaque fichier observé pendant l''analyse'
    LogMode_MatchesOnly = 'Correspondances uniquement : enregistre seulement les fichiers trouvés et les opérations principales'

    LogLimit_Header       = 'LIMITE DE TAILLE DU JOURNAL'
    LogLimit_Description  = 'Voulez-vous définir une taille maximale pour le fichier journal ?'
    LogLimit_None         = 'Aucune limite'
    LogLimit_Custom       = 'Définir une limite (ex. 500Mo, 2Go)'
    LogLimit_EnterValue   = 'Saisissez la taille maximale (ex. 500MB ou 2GB) :'
    LogLimit_InvalidValue = 'Format invalide. Exemple : 500MB ou 2GB.'

    Exclusions_Prompt = 'Les dossiers système très volumineux (WinSxS, System32, cache Windows Defender, etc.) contiennent rarement des documents utilisateur. Les caches web (IIS/ASP.NET/XAMPP) restent de toute façon toujours inclus.'
    Exclusions_Header = 'EXCLUSION DES DOSSIERS SYSTÈME'
    Exclusions_Yes    = 'Oui, les exclure de l''analyse (plus rapide)'
    Exclusions_No     = 'Non, analyser aussi ces dossiers'

    Purge_Cancelled = 'Opération annulée par l''utilisateur.'

    Purge_SummaryHeader      = 'RÉCAPITULATIF DES PARAMÈTRES'
    Purge_SummaryFile        = 'Fichier à rechercher : {0}'
    Purge_SummaryLogMode     = 'Mode de journalisation : {0}'
    Purge_SummaryLogLimit    = 'Limite du journal : {0}'
    Purge_SummaryExclusions  = 'Exclusion des dossiers volumineux : {0}'
    Purge_ConfirmStart       = 'Voulez-vous démarrer l''analyse avec ces paramètres ?'
    Purge_ScanCancelled      = 'Analyse annulée par l''utilisateur.'

    Scan_Starting      = 'Démarrage de l''analyse pour : {0}'
    Scan_CacheLocation = 'Vérification du cache : {0}'
    Scan_Drive         = 'Analyse du lecteur : {0}'
    Scan_Folder        = 'Dossier : {0}'
    Scan_Match         = 'Correspondance : {0}'
    Scan_Hidden        = ' [caché]'
    Scan_Link          = ' [raccourci]'
    Scan_Completed     = 'Analyse terminée. Correspondances trouvées : {0}'
    Scan_NoMatches     = 'Aucune correspondance trouvée pour : {0}'
    Scan_LogTruncated  = 'Limite de taille du journal atteinte : les lignes suivantes ne seront plus enregistrées dans le fichier (l''analyse continue quand même).'
    Scan_AccessDenied  = 'Accès refusé, dossier ignoré : {0}'
    Scan_ItemError     = 'Élément ignoré en raison d''une erreur : {0} ({1})'

    Results_Header           = 'RÉSULTATS DE LA RECHERCHE'
    Results_Description      = 'Sélectionnez le numéro de l''élément à supprimer, ou la dernière option pour tout supprimer.'
    Results_DeleteAll        = 'Supprimer toutes les {0} correspondances trouvées'
    Results_ConfirmDeleteOne = 'Êtes-vous sûr de vouloir supprimer ce fichier ?'
    Results_ConfirmDeleteAll = 'Êtes-vous sûr de vouloir supprimer TOUTES les {0} correspondances trouvées ?'
    Results_Deleted          = 'Supprimé : {0}'
    Results_DeleteFailed     = 'Impossible de supprimer {0} : {1}'
    Results_ReturningToMain  = 'Plus aucune correspondance : retour au menu principal.'

    App_UnexpectedError = 'Une erreur inattendue s''est produite : {0}'
    }
    de = @{
    AppTitle        = 'Server Cleaner Toolkit'
    Press_Enter     = 'Drücken Sie die EINGABETASTE, um fortzufahren...'
    Invalid_Choice  = 'Ungültige Auswahl. Bitte erneut versuchen.'
    Exiting         = 'Skript wird beendet...'
    Confirm_Yes     = 'ja'
    Confirm_No      = 'nein'
    Confirm_Prompt  = 'Sind Sie sicher, dass Sie fortfahren möchten? (ja/nein)'

    MainMenu_Header      = 'HAUPTMENÜ'
    MainMenu_Description = 'Wählen Sie die auszuführende Operation aus:'
    MainMenu_Option1     = 'Sprache ändern'
    MainMenu_Option2     = 'Datei löschen (purge)'
    MainMenu_Option3     = 'Protokolle anzeigen'
    Option_Exit          = 'Beenden'
    Option_Back          = 'Zurück'

    LangMenu_Header      = 'SPRACHEINSTELLUNGEN'
    LangMenu_Description = 'Wählen Sie die Sprache für diese Sitzung (aktuelle Sprache mit * markiert):'
    LangMenu_Changed     = 'Sprache eingestellt auf: {0}'

    Purge_Header         = 'DATEI LÖSCHEN'
    Purge_Description    = 'Eine Datei auf dem Server suchen und löschen.'
    Purge_NotImplemented = 'Diese Funktion wird in den nächsten Entwicklungsphasen verfügbar sein (Phase 3/4).'

    Logs_Header      = 'VORGANGSPROTOKOLLE'
    Logs_Description = 'Wählen Sie die Nummer des zu öffnenden Protokolls.'
    Logs_None        = 'Keine Protokolle im Skriptordner gefunden.'
    Logs_Viewing     = 'Protokoll wird angezeigt: {0}'
    Logs_PageIndicator = 'Seite {0} von {1}'
    Logs_PagerHelp      = 'EINGABETASTE für weiter, 0 für zurück zur Liste.'
    Logs_EndOfFile      = 'Ende der Datei.'

    Elevation_Requesting = 'Administratorrechte erforderlich, Neustart läuft...'
    Elevation_Failed     = 'Administratorrechte konnten nicht erlangt werden. Das Skript wird beendet.'

    Purge_AskFileName = 'Geben Sie den (auch teilweisen) Namen der zu suchenden Datei ein:'

    LogMode_Header      = 'PROTOKOLLIERUNGSMODUS'
    LogMode_Description = 'Wählen Sie, wie der Scan im Protokoll erfasst werden soll:'
    LogMode_Full        = 'Vollständig: protokolliert jede während des Scans beobachtete Datei'
    LogMode_MatchesOnly = 'Nur Treffer: protokolliert nur gefundene Dateien und die wichtigsten Vorgänge'

    LogLimit_Header       = 'PROTOKOLLGRÖSSENLIMIT'
    LogLimit_Description  = 'Möchten Sie eine maximale Größe für die Protokolldatei festlegen?'
    LogLimit_None         = 'Kein Limit'
    LogLimit_Custom       = 'Ein Limit festlegen (z. B. 500MB, 2GB)'
    LogLimit_EnterValue   = 'Geben Sie die maximale Größe ein (z. B. 500MB oder 2GB):'
    LogLimit_InvalidValue = 'Ungültiges Format. Beispiel: 500MB oder 2GB.'

    Exclusions_Prompt = 'Umfangreiche Systemordner (WinSxS, System32, Windows Defender-Cache usw.) enthalten selten Benutzerdokumente. Web-Caches (IIS/ASP.NET/XAMPP) werden trotzdem immer eingeschlossen.'
    Exclusions_Header = 'AUSSCHLUSS VON SYSTEMORDNERN'
    Exclusions_Yes    = 'Ja, vom Scan ausschließen (schneller)'
    Exclusions_No     = 'Nein, auch diese durchsuchen'

    Purge_Cancelled = 'Vorgang vom Benutzer abgebrochen.'

    Purge_SummaryHeader      = 'EINSTELLUNGSÜBERSICHT'
    Purge_SummaryFile        = 'Zu suchende Datei: {0}'
    Purge_SummaryLogMode     = 'Protokollierungsmodus: {0}'
    Purge_SummaryLogLimit    = 'Protokolllimit: {0}'
    Purge_SummaryExclusions  = 'Ausschluss umfangreicher Ordner: {0}'
    Purge_ConfirmStart       = 'Möchten Sie den Scan mit diesen Einstellungen starten?'
    Purge_ScanCancelled      = 'Scan vom Benutzer abgebrochen.'

    Scan_Starting      = 'Suche wird gestartet für: {0}'
    Scan_CacheLocation = 'Cache wird geprüft: {0}'
    Scan_Drive         = 'Laufwerk wird durchsucht: {0}'
    Scan_Folder        = 'Ordner: {0}'
    Scan_Match         = 'Treffer: {0}'
    Scan_Hidden        = ' [versteckt]'
    Scan_Link          = ' [Verknüpfung]'
    Scan_Completed     = 'Scan abgeschlossen. Gefundene Treffer: {0}'
    Scan_NoMatches     = 'Keine Treffer gefunden für: {0}'
    Scan_LogTruncated  = 'Protokollgrößenlimit erreicht: weitere Zeilen werden nicht mehr in der Datei gespeichert (der Scan wird trotzdem fortgesetzt).'
    Scan_AccessDenied  = 'Zugriff verweigert, Ordner übersprungen: {0}'
    Scan_ItemError     = 'Element aufgrund eines Fehlers übersprungen: {0} ({1})'

    Results_Header           = 'SUCHERGEBNISSE'
    Results_Description      = 'Wählen Sie die Nummer des zu löschenden Elements, oder die letzte Option, um alle zu löschen.'
    Results_DeleteAll        = 'Alle {0} gefundenen Treffer löschen'
    Results_ConfirmDeleteOne = 'Sind Sie sicher, dass Sie diese Datei löschen möchten?'
    Results_ConfirmDeleteAll = 'Sind Sie sicher, dass Sie ALLE {0} gefundenen Treffer löschen möchten?'
    Results_Deleted          = 'Gelöscht: {0}'
    Results_DeleteFailed     = 'Konnte {0} nicht löschen: {1}'
    Results_ReturningToMain  = 'Keine Treffer mehr übrig: Rückkehr zum Hauptmenü.'

    App_UnexpectedError = 'Ein unerwarteter Fehler ist aufgetreten: {0}'
    }
    es = @{
    AppTitle        = 'Server Cleaner Toolkit'
    Press_Enter     = 'Presione ENTRAR para continuar...'
    Invalid_Choice  = 'Opción no válida. Inténtelo de nuevo.'
    Exiting         = 'Cerrando el script...'
    Confirm_Yes     = 'si'
    Confirm_No      = 'no'
    Confirm_Prompt  = '¿Está seguro de que desea continuar? (si/no)'

    MainMenu_Header      = 'MENÚ PRINCIPAL'
    MainMenu_Description = 'Seleccione la operación a realizar:'
    MainMenu_Option1     = 'Cambiar idioma'
    MainMenu_Option2     = 'Eliminar un archivo (purge)'
    MainMenu_Option3     = 'Ver registros'
    Option_Exit          = 'Salir'
    Option_Back          = 'Volver'

    LangMenu_Header      = 'CONFIGURACIÓN DE IDIOMA'
    LangMenu_Description = 'Elija el idioma a utilizar en esta sesión (idioma actual marcado con *):'
    LangMenu_Changed     = 'Idioma configurado en: {0}'

    Purge_Header         = 'ELIMINACIÓN DE ARCHIVO'
    Purge_Description    = 'Buscar y eliminar un archivo del servidor.'
    Purge_NotImplemented = 'Esta función estará disponible en las próximas fases de desarrollo (Fase 3/4).'

    Logs_Header      = 'REGISTROS DE OPERACIONES'
    Logs_Description = 'Seleccione el número del registro que desea abrir.'
    Logs_None        = 'No se encontraron registros en la carpeta del script.'
    Logs_Viewing     = 'Viendo registro: {0}'
    Logs_PageIndicator = 'Página {0} de {1}'
    Logs_PagerHelp      = 'Presione ENTRAR para continuar, 0 para volver a la lista.'
    Logs_EndOfFile      = 'Fin del archivo.'

    Elevation_Requesting = 'Se requieren privilegios de administrador, reiniciando...'
    Elevation_Failed     = 'No se pudieron obtener privilegios de administrador. El script se cerrará.'

    Purge_AskFileName = 'Introduzca el nombre (aunque sea parcial) del archivo a buscar:'

    LogMode_Header      = 'MODO DE REGISTRO'
    LogMode_Description = 'Elija cómo registrar el análisis en el archivo de registro:'
    LogMode_Full        = 'Completo: registra cada archivo observado durante el análisis'
    LogMode_MatchesOnly = 'Solo coincidencias: registra solo los archivos encontrados y las operaciones principales'

    LogLimit_Header       = 'LÍMITE DE TAMAÑO DEL REGISTRO'
    LogLimit_Description  = '¿Desea establecer un tamaño máximo para el archivo de registro?'
    LogLimit_None         = 'Sin límite'
    LogLimit_Custom       = 'Establecer un límite (ej. 500MB, 2GB)'
    LogLimit_EnterValue   = 'Introduzca el tamaño máximo (ej. 500MB o 2GB):'
    LogLimit_InvalidValue = 'Formato no válido. Ejemplo: 500MB o 2GB.'

    Exclusions_Prompt = 'Las carpetas de sistema muy pesadas (WinSxS, System32, caché de Windows Defender, etc.) rara vez contienen documentos de usuario. Las cachés web (IIS/ASP.NET/XAMPP) siempre se incluyen de todos modos.'
    Exclusions_Header = 'EXCLUSIÓN DE CARPETAS DE SISTEMA'
    Exclusions_Yes    = 'Sí, excluirlas del análisis (más rápido)'
    Exclusions_No     = 'No, analizar también esas carpetas'

    Purge_Cancelled = 'Operación cancelada por el usuario.'

    Purge_SummaryHeader      = 'RESUMEN DE CONFIGURACIÓN'
    Purge_SummaryFile        = 'Archivo a buscar: {0}'
    Purge_SummaryLogMode     = 'Modo de registro: {0}'
    Purge_SummaryLogLimit    = 'Límite del registro: {0}'
    Purge_SummaryExclusions  = 'Excluir carpetas pesadas: {0}'
    Purge_ConfirmStart       = '¿Desea iniciar el análisis con esta configuración?'
    Purge_ScanCancelled      = 'Análisis cancelado por el usuario.'

    Scan_Starting      = 'Iniciando análisis de: {0}'
    Scan_CacheLocation = 'Comprobando caché: {0}'
    Scan_Drive         = 'Analizando unidad: {0}'
    Scan_Folder        = 'Carpeta: {0}'
    Scan_Match         = 'Coincidencia: {0}'
    Scan_Hidden        = ' [oculto]'
    Scan_Link          = ' [acceso directo]'
    Scan_Completed     = 'Análisis completado. Coincidencias encontradas: {0}'
    Scan_NoMatches     = 'No se encontraron coincidencias para: {0}'
    Scan_LogTruncated  = 'Límite de tamaño del registro alcanzado: las líneas siguientes ya no se guardarán en el archivo (el análisis continúa de todos modos).'
    Scan_AccessDenied  = 'Acceso denegado, carpeta omitida: {0}'
    Scan_ItemError     = 'Elemento omitido debido a un error: {0} ({1})'

    Results_Header           = 'RESULTADOS DE LA BÚSQUEDA'
    Results_Description      = 'Seleccione el número del elemento a eliminar, o la última opción para eliminarlos todos.'
    Results_DeleteAll        = 'Eliminar todas las {0} coincidencias encontradas'
    Results_ConfirmDeleteOne = '¿Está seguro de que desea eliminar este archivo?'
    Results_ConfirmDeleteAll = '¿Está seguro de que desea eliminar TODAS las {0} coincidencias encontradas?'
    Results_Deleted          = 'Eliminado: {0}'
    Results_DeleteFailed     = 'No se pudo eliminar {0}: {1}'
    Results_ReturningToMain  = 'No quedan coincidencias: volviendo al menú principal.'

    App_UnexpectedError = 'Se produjo un error inesperado: {0}'
    }
    pt = @{
    AppTitle        = 'Server Cleaner Toolkit'
    Press_Enter     = 'Pressione ENTER para continuar...'
    Invalid_Choice  = 'Opção inválida. Tente novamente.'
    Exiting         = 'Fechando o script...'
    Confirm_Yes     = 'sim'
    Confirm_No      = 'não'
    Confirm_Prompt  = 'Tem certeza de que deseja continuar? (sim/não)'

    MainMenu_Header      = 'MENU PRINCIPAL'
    MainMenu_Description = 'Selecione a operação a realizar:'
    MainMenu_Option1     = 'Alterar idioma'
    MainMenu_Option2     = 'Excluir um arquivo (purge)'
    MainMenu_Option3     = 'Ver logs'
    Option_Exit          = 'Sair'
    Option_Back          = 'Voltar'

    LangMenu_Header      = 'CONFIGURAÇÕES DE IDIOMA'
    LangMenu_Description = 'Escolha o idioma a utilizar nesta sessão (idioma atual marcado com *):'
    LangMenu_Changed     = 'Idioma definido para: {0}'

    Purge_Header         = 'EXCLUSÃO DE ARQUIVO'
    Purge_Description    = 'Procurar e excluir um arquivo do servidor.'
    Purge_NotImplemented = 'Esta função estará disponível nas próximas fases de desenvolvimento (Fase 3/4).'

    Logs_Header      = 'REGISTROS DE OPERAÇÕES'
    Logs_Description = 'Selecione o número do log que deseja abrir.'
    Logs_None        = 'Nenhum log encontrado na pasta do script.'
    Logs_Viewing     = 'Visualizando log: {0}'
    Logs_PageIndicator = 'Página {0} de {1}'
    Logs_PagerHelp      = 'Pressione ENTER para continuar, 0 para voltar à lista.'
    Logs_EndOfFile      = 'Fim do arquivo.'

    Elevation_Requesting = 'Privilégios de administrador necessários, reiniciando...'
    Elevation_Failed     = 'Não foi possível obter privilégios de administrador. O script será fechado.'

    Purge_AskFileName = 'Digite o nome (mesmo que parcial) do arquivo a ser pesquisado:'

    LogMode_Header      = 'MODO DE REGISTRO'
    LogMode_Description = 'Escolha como registrar a varredura no arquivo de log:'
    LogMode_Full        = 'Completo: registra cada arquivo observado durante a varredura'
    LogMode_MatchesOnly = 'Somente correspondências: registra apenas os arquivos encontrados e as operações principais'

    LogLimit_Header       = 'LIMITE DE TAMANHO DO LOG'
    LogLimit_Description  = 'Deseja definir um tamanho máximo para o arquivo de log?'
    LogLimit_None         = 'Sem limite'
    LogLimit_Custom       = 'Definir um limite (ex. 500MB, 2GB)'
    LogLimit_EnterValue   = 'Digite o tamanho máximo (ex. 500MB ou 2GB):'
    LogLimit_InvalidValue = 'Formato inválido. Exemplo: 500MB ou 2GB.'

    Exclusions_Prompt = 'Pastas de sistema muito pesadas (WinSxS, System32, cache do Windows Defender, etc.) raramente contêm documentos do usuário. Os caches web (IIS/ASP.NET/XAMPP) sempre são incluídos de qualquer forma.'
    Exclusions_Header = 'EXCLUSÃO DE PASTAS DE SISTEMA'
    Exclusions_Yes    = 'Sim, excluí-las da varredura (mais rápido)'
    Exclusions_No     = 'Não, varrer essas pastas também'

    Purge_Cancelled = 'Operação cancelada pelo usuário.'

    Purge_SummaryHeader      = 'RESUMO DAS CONFIGURAÇÕES'
    Purge_SummaryFile        = 'Arquivo a pesquisar: {0}'
    Purge_SummaryLogMode     = 'Modo de log: {0}'
    Purge_SummaryLogLimit    = 'Limite do log: {0}'
    Purge_SummaryExclusions  = 'Excluir pastas pesadas: {0}'
    Purge_ConfirmStart       = 'Deseja iniciar a varredura com estas configurações?'
    Purge_ScanCancelled      = 'Varredura cancelada pelo usuário.'

    Scan_Starting      = 'Iniciando varredura para: {0}'
    Scan_CacheLocation = 'Verificando cache: {0}'
    Scan_Drive         = 'Varrendo unidade: {0}'
    Scan_Folder        = 'Pasta: {0}'
    Scan_Match         = 'Correspondência: {0}'
    Scan_Hidden        = ' [oculto]'
    Scan_Link          = ' [atalho]'
    Scan_Completed     = 'Varredura concluída. Correspondências encontradas: {0}'
    Scan_NoMatches     = 'Nenhuma correspondência encontrada para: {0}'
    Scan_LogTruncated  = 'Limite de tamanho do log atingido: as próximas linhas não serão mais salvas no arquivo (a varredura continua mesmo assim).'
    Scan_AccessDenied  = 'Acesso negado, pasta ignorada: {0}'
    Scan_ItemError     = 'Item ignorado devido a um erro: {0} ({1})'

    Results_Header           = 'RESULTADOS DA PESQUISA'
    Results_Description      = 'Selecione o número do item a excluir, ou a última opção para excluir todos.'
    Results_DeleteAll        = 'Excluir todas as {0} correspondências encontradas'
    Results_ConfirmDeleteOne = 'Tem certeza de que deseja excluir este arquivo?'
    Results_ConfirmDeleteAll = 'Tem certeza de que deseja excluir TODAS as {0} correspondências encontradas?'
    Results_Deleted          = 'Excluído: {0}'
    Results_DeleteFailed     = 'Não foi possível excluir {0}: {1}'
    Results_ReturningToMain  = 'Nenhuma correspondência restante: voltando ao menu principal.'

    App_UnexpectedError = 'Ocorreu um erro inesperado: {0}'
    }
}

# ==== Contenuto originale: Modules\Core.Elevation.ps1 ====
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


# ==== Contenuto originale: Modules\Core.I18n.ps1 ====
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
        Versione "a file singolo": invece di leggere un file .psd1 dal disco,
        restituisce i dati gia' incorporati in $script:AllLanguageData in
        cima a questo file. Firma identica alla versione modulare (LangFolder
        non e' piu' usato, ma resta per compatibilita' con chi la richiama).
    #>
    param(
        [Parameter(Mandatory)]
        [string]$LangCode,

        [string]$LangFolder
    )

    if (-not $script:AllLanguageData.ContainsKey($LangCode)) {
        throw "Lingua non disponibile: $LangCode"
    }

    return $script:AllLanguageData[$LangCode]
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
        Write-Host (Format-MenuOption ($i + 1) "$($script:LanguageDisplayNames[$code])$marker")
    }
    Write-Host ''
    Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray

    $choice = Read-MenuChoice -MinValue 0 -MaxValue $codes.Count
    if ($choice -eq 0) { return }

    $selectedCode        = $codes[$choice - 1]
    $script:CurrentLangCode = $selectedCode
    $script:Lang            = Import-LanguageStrings -LangCode $selectedCode -LangFolder $script:LangFolderPath

    Write-Host ''
    Write-Host ($script:Lang.LangMenu_Changed -f $script:LanguageDisplayNames[$selectedCode]) -ForegroundColor Green
    Start-Sleep -Seconds 1
}


# ==== Contenuto originale: Modules\Core.Logging.ps1 ====
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


# ==== Contenuto originale: Modules\Core.Menu.ps1 ====
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


# ==== Contenuto originale: Modules\Core.LogViewer.ps1 ====
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
            Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray
            Read-MenuChoice -MinValue 0 -MaxValue 0 | Out-Null
            return
        }

        for ($i = 0; $i -lt $logFiles.Count; $i++) {
            Write-Host (Format-MenuOption ($i + 1) $logFiles[$i].Name)
        }
        Write-Host ''
        Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray

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
            Write-Host (Format-MenuOption 0 $script:Lang.Option_Back) -ForegroundColor DarkGray
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


# ==== Contenuto originale: Modules\Core.Search.ps1 ====
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
        # AllowEmptyString: file come ".htaccess", ".config", ".ses" (che
        # iniziano con un punto e non hanno altro prima) hanno un BaseName
        # vuoto per definizione ([IO.Path]::GetFileNameWithoutExtension
        # considera tutto il nome come estensione). Senza questo attributo
        # PowerShell rifiuta di bindare la stringa vuota a un parametro
        # obbligatorio, facendo fallire il confronto invece di
        # semplicemente concludere "non corrisponde".
        [Parameter(Mandatory)]
        [AllowEmptyString()]
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

    # NB: qui si controlla solo "il nome del file contiene il termine
    # cercato" e non il contrario. Un controllo "il termine cercato contiene
    # il nome del file" sembrava utile in teoria, ma in pratica genera falsi
    # positivi enormi con ricerche lunghe: un file chiamato "dir.gif" veniva
    # segnalato come corrispondenza di "DIRIGENTE" solo
    # perche' "dir" e' una sottostringa di "dirigente". Non e' quello che
    # serve: l'utente vuole trovare file il cui nome contiene (anche solo in
    # parte) quello che ha digitato, non il contrario.
    if ($targetNormalized.Length -ge 3) {
        if ($candidateNormalized.Contains($targetNormalized)) { return $true }
        if ($candidateNoCopy.Contains($targetNormalized))     { return $true }
        if (-not [string]::IsNullOrWhiteSpace($targetStripped) -and $targetStripped.Length -ge 3 -and $candidateStripped.Contains($targetStripped)) {
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


# ==== Contenuto originale: Modules\Core.Purge.ps1 ====
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
        # Niente [Parameter(Mandatory)]: quando la ricerca non trova nulla,
        # arriva qui una lista vuota, e PowerShell rifiuterebbe di bindare
        # una collezione vuota a un parametro obbligatorio.
        [System.Collections.Generic.List[object]]$Results
    )

    while ($true) {
        if (-not $Results -or $Results.Count -eq 0) {
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
    } catch {
        # Rete di sicurezza: un errore imprevisto qui non deve far sparire lo
        # script silenziosamente nel menu principale (il Clear-Host della
        # schermata successiva cancellerebbe subito qualunque messaggio
        # stampato al volo). Si registra nel log e si mostra a schermo,
        # fermando l'esecuzione finche' l'utente non preme INVIO.
        Write-Log ($script:Lang.App_UnexpectedError -f $_.Exception.Message) -Level ERROR
        Write-Host ''
        Write-Host ($script:Lang.App_UnexpectedError -f $_.Exception.Message) -ForegroundColor Red
        Write-Host ''
        Write-Host $script:Lang.Press_Enter -ForegroundColor DarkGray
        Read-Host | Out-Null
    } finally {
        # Va sempre eseguito, anche se l'utente annulla a meta' wizard o la
        # ricerca viene interrotta da un errore imprevisto, per non lasciare
        # il file di log aperto.
        Stop-OperationLog
    }
}


# ==== Contenuto originale: ServerCleaner.ps1 (corpo principale) ====
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
# In questa versione a file singolo le funzioni dei moduli sono gia'
# definite piu' sopra in questo stesso file (vedi sezioni 'Contenuto
# originale: Modules\...').

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
    Write-Host (Format-MenuOption 1 $script:Lang.MainMenu_Option1)
    Write-Host (Format-MenuOption 2 $script:Lang.MainMenu_Option2)
    Write-Host (Format-MenuOption 3 $script:Lang.MainMenu_Option3)
    Write-Host ''
    Write-Host (Format-MenuOption 0 $script:Lang.Option_Exit) -ForegroundColor DarkGray
}

while ($true) {
    Show-MainMenu
    $choice = Read-MenuChoice -MinValue 0 -MaxValue 3

    # Rete di sicurezza finale: qualunque errore imprevisto non gestito nelle
    # singole funzioni di menu viene comunque intercettato qui, mostrato a
    # schermo (con traccia tecnica) e messo in pausa, invece di far
    # scomparire lo script nel nulla al ridisegno della schermata successiva.
    try {
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
    } catch {
        Write-Host ''
        Write-Host ($script:Lang.App_UnexpectedError -f $_.Exception.Message) -ForegroundColor Red
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
        Write-Host ''
        Write-Host $script:Lang.Press_Enter -ForegroundColor DarkGray
        Read-Host | Out-Null
    }
}
