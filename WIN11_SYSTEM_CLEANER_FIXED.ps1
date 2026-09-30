`   1#requires -Version 5.1

$ErrorActionPreference = 'Stop'
$script:RemovedItems = 0
$script:FreedBytes = 0
$script:SkippedItems = 0
$script:BulkMode = $false
$script:Language = 'en'
try {
    $script:Language = if ((Get-WinSystemLocale).Name -like 'pl*') { 'pl' } else { 'en' }
}
catch {
    if ((Get-UICulture).Name -like 'pl*') { $script:Language = 'pl' }
}

try {
    $Host.UI.RawUI.BackgroundColor = [ConsoleColor]::Darkblue
    $Host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
    Clear-Host
}
catch { }

$script:TextMap = @{
    'WINDOWS 11  |  PORZADKI SYSTEMOWE' = @{ pl = 'WINDOWS 11  |  PORZĄDKI SYSTEMOWE'; en = 'WINDOWS 11  |  SYSTEM CLEANUP' }
    'Bezpieczne czyszczenie plikow tymczasowych i wybranych pamieci podrecznych' = @{ pl = 'Bezpieczne czyszczenie plików tymczasowych i wybranych pamięci podręcznych'; en = 'Safe cleanup of temporary files and selected caches' }
    'Folder Pobrane jest pomijany przez ten skrypt.' = @{ pl = 'Folder Pobrane jest pomijany przez ten skrypt.'; en = 'The Downloads folder is excluded by this script.' }
    'Objete potwierdzeniem zbiorczym.' = @{ pl = 'Objęte potwierdzeniem zbiorczym.'; en = 'Covered by the bulk confirmation.' }
    'brak plikow' = @{ pl = 'brak plików'; en = 'no files found' }
    'Nie usunieto' = @{ pl = 'Nie usunięto'; en = 'Could not remove' }
    'usuniieto' = @{ pl = 'usunięto'; en = 'removed' }
    'usunięto' = @{ pl = 'usunięto'; en = 'removed' }
    'elementow' = @{ pl = 'elementów'; en = 'items' }
    'ok.' = @{ pl = 'ok.'; en = 'approx.' }
    'Pominieto' = @{ pl = 'Pominięto'; en = 'Skipped' }
    'np. pliki uzywane lub dowiazania' = @{ pl = 'np. pliki używane lub dowiązania'; en = 'for example, files in use or reparse points' }
    'Czyszczenie plikow tymczasowych i cache' = @{ pl = 'Czyszczenie plików tymczasowych i pamięci podręcznej'; en = 'Temporary files and cache cleanup' }
    'Zamknij przegladarki i aplikacje, aby zwiekszyc skutecznosc.' = @{ pl = 'Zamknij przeglądarki i aplikacje, aby zwiększyć skuteczność.'; en = 'Close browsers and apps first for best results.' }
    'Rozpoczac czyszczenie?' = @{ pl = 'Rozpocząć czyszczenie?'; en = 'Start cleanup?' }
    'Pominieto czyszczenie.' = @{ pl = 'Pominięto czyszczenie.'; en = 'Cleanup skipped.' }
    'Tymczasowe pliki Windows' = @{ pl = 'Tymczasowe pliki Windows'; en = 'Windows temporary files' }
    'Tymczasowe pliki biezacego uzytkownika' = @{ pl = 'Tymczasowe pliki bieżącego użytkownika'; en = 'Current user temporary files' }
    'Lokalny katalog Temp uzytkownika' = @{ pl = 'Lokalny katalog Temp użytkownika'; en = 'User local Temp folder' }
    'Pamiec podreczna shaderow DirectX' = @{ pl = 'Pamięć podręczna shaderów DirectX'; en = 'DirectX shader cache' }
    'Archiwalne raporty bledow Windows' = @{ pl = 'Archiwalne raporty błędów Windows'; en = 'Archived Windows error reports' }
    'Oczekujace raporty bledow Windows' = @{ pl = 'Oczekujące raporty błędów Windows'; en = 'Queued Windows error reports' }
    'Cache aplikacji' = @{ pl = 'Pamięć podręczna aplikacji'; en = 'Application cache' }
    'Czyszczenie pobranych plikow Windows Update wymaga zatrzymania uslug.' = @{ pl = 'Czyszczenie pobranych plików Windows Update wymaga zatrzymania usług.'; en = 'Cleaning downloaded Windows Update files requires stopping services.' }
    'Usunac pliki pobrane przez Windows Update?' = @{ pl = 'Usunąć pobrane pliki Windows Update?'; en = 'Delete downloaded Windows Update files?' }
    'Nie udalo sie ponownie uruchomic uslugi' = @{ pl = 'Nie udało się ponownie uruchomić usługi'; en = 'Could not restart service' }
    'Usunac cache Optymalizacji dostarczania Windows?' = @{ pl = 'Usunąć pamięć podręczną optymalizacji dostarczania Windows?'; en = 'Delete the Windows Delivery Optimization cache?' }
    'Usunieto cache Optymalizacji dostarczania.' = @{ pl = 'Usunięto pamięć podręczną optymalizacji dostarczania.'; en = 'Delivery Optimization cache removed.' }
    'Oproznic Kosz? Ta operacja trwale usuwa jego zawartosc.' = @{ pl = 'Opróżnić Kosz? Ta operacja trwale usuwa jego zawartość.'; en = 'Empty the Recycle Bin? This permanently deletes its contents.' }
    'Oprozniono Kosz biezacego uzytkownika.' = @{ pl = 'Opróżniono Kosz bieżącego użytkownika.'; en = 'Emptied the current user''s Recycle Bin.' }
    'Nie znaleziono polecenia Clear-RecycleBin; Kosz pozostawiono bez zmian.' = @{ pl = 'Nie znaleziono polecenia Clear-RecycleBin; Kosz pozostawiono bez zmian.'; en = 'Clear-RecycleBin is unavailable; the Recycle Bin was left unchanged.' }
    'Wbudowane Oczyszczanie dysku' = @{ pl = 'Wbudowane Oczyszczanie dysku'; en = 'Built-in Disk Cleanup' }
    'Koncowy etap: DISM i magazyn skladnikow' = @{ pl = 'Końcowy etap: DISM i magazyn składników'; en = 'Final stage: DISM and the component store' }
    'Nie znaleziono programu DISM.' = @{ pl = 'Nie znaleziono programu DISM.'; en = 'DISM was not found.' }
    'DISM wykona kolejno analize, standardowe czyszczenie i ResetBase /Defer.' = @{ pl = 'DISM kolejno przeanalizuje magazyn, wykona standardowe czyszczenie i ResetBase /Defer.'; en = 'DISM will analyze the component store, run standard cleanup, then ResetBase /Defer.' }
    'RESETBASE JEST NIEODWRACALNE:' = @{ pl = 'RESETBASE JEST NIEODWRACALNE:'; en = 'RESETBASE IS IRREVERSIBLE:' }
    'po wykonaniu nie bedzie mozna odinstalowac obecnie zainstalowanych aktualizacji Windows;' = @{ pl = 'po wykonaniu nie będzie można odinstalować obecnie zainstalowanych aktualizacji Windows;'; en = 'installed Windows updates can no longer be uninstalled;' }
    'nie bedzie mozna przywrocic poprzednich wersji zastapionych skladnikow;' = @{ pl = 'nie będzie można przywrócić poprzednich wersji zastąpionych składników;'; en = 'previous versions of superseded components cannot be restored;' }
    'punkt przywracania nie cofnie tych zmian.' = @{ pl = 'punkt przywracania nie cofnie tych zmian.'; en = 'a restore point will not undo these changes.' }
    'Analiza magazynu skladnikow (bez wprowadzania zmian)...' = @{ pl = 'Analiza magazynu składników (bez wprowadzania zmian)...'; en = 'Analyzing the component store (no changes will be made)...' }
    'Analiza DISM zakonczyla sie kodem' = @{ pl = 'Analiza DISM zakończyła się kodem'; en = 'DISM analysis exited with code' }
    'dalsze kroki pominieto.' = @{ pl = 'dalsze kroki pominięto.'; en = 'remaining steps skipped.' }
    'Standardowe czyszczenie zastapionych skladnikow...' = @{ pl = 'Standardowe czyszczenie zastąpionych składników...'; en = 'Cleaning up superseded components...' }
    'Standardowe czyszczenie DISM zakonczylo sie kodem' = @{ pl = 'Standardowe czyszczenie DISM zakończyło się kodem'; en = 'Standard DISM cleanup exited with code' }
    'ResetBase pominieto.' = @{ pl = 'ResetBase pominięto.'; en = 'ResetBase skipped.' }
    'Uruchamiam ResetBase /Defer (bez mozliwosci odinstalowania aktualizacji)...' = @{ pl = 'Uruchamiam ResetBase /Defer (bez możliwości odinstalowania aktualizacji)...'; en = 'Running ResetBase /Defer (updates will no longer be uninstallable)...' }
    'ResetBase DISM zakonczyl sie kodem' = @{ pl = 'ResetBase DISM zakończył się kodem'; en = 'DISM ResetBase exited with code' }
    'Ciche cleanmgr na wszystkich dyskach (wszystkie kategorie oprocz Pobrane)' = @{ pl = 'Ciche cleanmgr na wszystkich dyskach (wszystkie kategorie oprócz Pobrane)'; en = 'Run cleanmgr silently on all drives (all categories except Downloads)' }
    'Uruchamiam ciche cleanmgr: wszystkie skonfigurowane kategorie na wykrytych dyskach.' = @{ pl = 'Uruchamiam ciche cleanmgr: wszystkie skonfigurowane kategorie na wykrytych dyskach.'; en = 'Running cleanmgr silently for all configured categories on detected drives.' }
    'Kategoria Pobrane/Downloads jest jawnie wylaczona. Kosz i poprzednie instalacje moga zostac usuniete.' = @{ pl = 'Kategoria Pobrane/Downloads jest wyłączona. Kosz i poprzednie instalacje mogą zostać usunięte.'; en = 'Downloads is explicitly excluded. The Recycle Bin and previous Windows installations may be removed.' }
    'Profil cleanmgr jest tymczasowy i zostanie przywrocony po zakonczeniu.' = @{ pl = 'Profil cleanmgr jest tymczasowy i zostanie przywrócony po zakończeniu.'; en = 'The temporary cleanmgr profile will be restored when cleanup finishes.' }
    'Nie znaleziono cleanmgr.exe.' = @{ pl = 'Nie znaleziono cleanmgr.exe.'; en = 'cleanmgr.exe was not found.' }
    'Czyszczenie kategorii cleanmgr (profil tymczasowy' = @{ pl = 'Czyszczenie kategorii cleanmgr (profil tymczasowy'; en = 'Cleaning cleanmgr categories (temporary profile' }
    'zakonczyl sie kodem' = @{ pl = 'zakończył się kodem'; en = 'exited with code' }
    'Usuwanie pozostalosci po poprzednich aktualizacjach Windows...' = @{ pl = 'Usuwanie pozostałości po poprzednich aktualizacjach Windows...'; en = 'Removing remnants of previous Windows upgrades...' }
    'Ciche czyszczenie cleanmgr zakonczone.' = @{ pl = 'Ciche czyszczenie cleanmgr zakończone.'; en = 'Silent cleanmgr cleanup complete.' }
    'Zrzuty pamieci i awarii' = @{ pl = 'Zrzuty pamięci i awarii'; en = 'Memory and crash dumps' }
    'Nie znaleziono zrzutow w typowych lokalizacjach.' = @{ pl = 'Nie znaleziono zrzutów w typowych lokalizacjach.'; en = 'No dumps were found in the usual locations.' }
    'Lista obejmuje tylko standardowe lokalizacje zrzutow systemu i aplikacji.' = @{ pl = 'Lista obejmuje tylko standardowe lokalizacje zrzutów systemu i aplikacji.'; en = 'Only standard Windows and application dump locations are listed.' }
    'Usunac pokazane zrzuty' = @{ pl = 'Usunąć pokazane zrzuty'; en = 'Delete the listed dumps' }
    'Dzienniki zdarzen Windows' = @{ pl = 'Dzienniki zdarzeń Windows'; en = 'Windows event logs' }
    'Ta operacja usuwa historie diagnostyczna i audytowa, w tym dziennik Security.' = @{ pl = 'Ta operacja usuwa historię diagnostyczną i audytową, w tym dziennik Security.'; en = 'This removes diagnostic and audit history, including the Security log.' }
    'Nie zalecamy jej rutynowo; moze utrudnic diagnostyke problemow.' = @{ pl = 'Nie zalecamy tej operacji rutynowo; może utrudnić diagnozowanie problemów.'; en = 'This is not recommended routinely; it can make troubleshooting harder.' }
    'Aby wyczyscic wszystkie dzienniki, wpisz DZIENNIKI' = @{ pl = 'Aby wyczyścić wszystkie dzienniki, wpisz DZIENNIKI'; en = 'Type EVENTLOGS to clear all logs' }
    'Dzienniki pozostawiono bez zmian.' = @{ pl = 'Dzienniki pozostawiono bez zmian.'; en = 'Event logs were left unchanged.' }
    'wevtutil nie mogl pobrac listy dziennikow (kod' = @{ pl = 'wevtutil nie mógł pobrać listy dzienników (kod'; en = 'wevtutil could not retrieve the log list (exit code' }
    'Wyczyszczono dostepne dzienniki zdarzen.' = @{ pl = 'Wyczyszczono dostępne dzienniki zdarzeń.'; en = 'Accessible event logs were cleared.' }
    'Dzienniki niedostepne lub chronione, pozostawione bez zmian:' = @{ pl = 'Dzienniki niedostępne lub chronione, pozostawione bez zmian:'; en = 'Inaccessible or protected logs left unchanged:' }
    'Punkty przywracania systemu' = @{ pl = 'Punkty przywracania systemu'; en = 'System restore points' }
    'Nie mozna odczytac punktow przywracania:' = @{ pl = 'Nie można odczytać punktów przywracania:'; en = 'Could not read restore points:' }
    'Sprawdz, czy Ochrona systemu jest wlaczona dla dysku systemowego.' = @{ pl = 'Sprawdź, czy Ochrona systemu jest włączona dla dysku systemowego.'; en = 'Check whether System Protection is enabled for the system drive.' }
    'System nie zglasza dostepnych punktow przywracania.' = @{ pl = 'System nie zgłasza dostępnych punktów przywracania.'; en = 'The system reports no available restore points.' }
    '  Nr       Data utworzenia         Opis' = @{ pl = '  Nr       Data utworzenia         Opis'; en = '  No.      Creation date           Description' }
    'Podaj numery do usuniecia, oddzielone przecinkami; ALL usuwa wszystkie; Enter anuluje.' = @{ pl = 'Podaj numery do usunięcia, oddzielone przecinkami; ALL usuwa wszystkie; Enter anuluje.'; en = 'Enter comma-separated numbers to delete; ALL deletes all; Enter cancels.' }
    'Numery punktow' = @{ pl = 'Numery punktów'; en = 'Restore point numbers' }
    'Nieprawidlowy lub nieistniejacy numer:' = @{ pl = 'Nieprawidłowy lub nieistniejący numer:'; en = 'Invalid or unknown number:' }
    'Niczego nie usunieto.' = @{ pl = 'Niczego nie usunięto.'; en = 'Nothing was deleted.' }
    'Do usuniecia:' = @{ pl = 'Do usunięcia:'; en = 'Selected for deletion:' }
    'Aby potwierdzic, wpisz USUN PUNKTY' = @{ pl = 'Aby potwierdzić, wpisz USUŃ PUNKTY'; en = 'Type DELETE RESTORE POINTS to confirm' }
    'Punkty pozostawiono bez zmian.' = @{ pl = 'Punkty pozostawiono bez zmian.'; en = 'Restore points were left unchanged.' }
    'Nie mozna zaladowac SrClient.dll.' = @{ pl = 'Nie można załadować SrClient.dll.'; en = 'Could not load SrClient.dll.' }
    'Nie znaleziono funkcji SRRemoveRestorePoint.' = @{ pl = 'Nie znaleziono funkcji SRRemoveRestorePoint.'; en = 'SRRemoveRestorePoint was not found.' }
    'Nie udalo sie usunac punktu' = @{ pl = 'Nie udało się usunąć punktu'; en = 'Could not delete restore point' }
    'Windows odmowil usuniecia tego punktu; moze byc chroniony lub zarzadzany przez system.' = @{ pl = 'Windows odmówił usunięcia tego punktu; może być chroniony lub zarządzany przez system.'; en = 'Windows denied deletion; this point may be protected or system-managed.' }
    'Czy po zmianach utworzyc nowy punkt przywracania?' = @{ pl = 'Czy po zmianach utworzyć nowy punkt przywracania?'; en = 'Create a new restore point after cleanup?' }
    'Punkt po czyszczeniu systemu' = @{ pl = 'Punkt po czyszczeniu systemu'; en = 'After system cleanup' }
    'Utworzono nowy punkt przywracania.' = @{ pl = 'Utworzono nowy punkt przywracania.'; en = 'A new restore point was created.' }
    'Nie utworzono punktu przywracania:' = @{ pl = 'Nie utworzono punktu przywracania:'; en = 'Could not create a restore point:' }
    'Windows moze ograniczac tworzenie punktow do jednego na 24 godziny.' = @{ pl = 'Windows może ograniczać tworzenie punktów do jednego na 24 godziny.'; en = 'Windows may limit restore point creation to once every 24 hours.' }
    'Bezpieczne czyszczenie (Temp, cache przegladarek, WER, opcjonalnie Windows Update)' = @{ pl = 'Bezpieczne czyszczenie (Temp, pamięci podręczne przeglądarek, WER i Windows Update)'; en = 'Safe cleanup (Temp, browser caches, WER, optional Windows Update)' }
    'DISM: analiza, czyszczenie i ResetBase (blokuje odinstalowanie aktualizacji)' = @{ pl = 'DISM: analiza, czyszczenie i ResetBase (blokuje odinstalowanie aktualizacji)'; en = 'DISM: analyze, clean up, and ResetBase (prevents update uninstall)' }
    'Wcisnij cyfre 1-6, aby wybrac warianty czyszczenia.' = @{ pl = 'Wciśnij cyfrę 1–6, aby wybrać warianty czyszczenia.'; en = 'Press 1–6 to select cleanup options.' }
    'Zarzadzaj punktami przywracania (wybor konkretnych punktow)' = @{ pl = 'Zarządzaj punktami przywracania (wybierz konkretne punkty)'; en = 'Manage restore points (select specific points)' }
    'Wyszukaj i opcjonalnie usun zrzuty DMP' = @{ pl = 'Wyszukaj i opcjonalnie usuń zrzuty DMP'; en = 'Find and optionally delete DMP files' }
    'Wyczysc wszystkie dzienniki zdarzen (operacja ryzykowna)' = @{ pl = 'Wyczyść dzienniki zdarzeń (operacja ryzykowna)'; en = 'Clear event logs (risky operation)' }
    'Wybrane operacje:' = @{ pl = 'Wybrane operacje:'; en = 'Selected operations:' }
    'UWAGA: DISM ResetBase jest nieodwracalne i blokuje odinstalowanie aktualizacji Windows.' = @{ pl = 'UWAGA: DISM ResetBase jest nieodwracalne i blokuje odinstalowanie aktualizacji Windows.'; en = 'WARNING: DISM ResetBase is irreversible and prevents uninstalling Windows updates.' }
    'cleanmgr obejmie wszystkie wykryte dyski; moze usunac Kosz i poprzednie instalacje Windows.' = @{ pl = 'cleanmgr obejmie wszystkie wykryte dyski; może usunąć Kosz i poprzednie instalacje Windows.'; en = 'cleanmgr will process all detected drives and may remove the Recycle Bin and previous Windows installations.' }
    'Pobrane/Downloads jest wylaczone z profilu.' = @{ pl = 'Pobrane/Downloads jest wyłączone z profilu.'; en = 'Downloads is excluded from the profile.' }
    'Potwierdzenie obejmuje wszystkie pozycje, w tym wyczyszczenie logow, zarzadzanie punktami przywracania oraz nieodwracalne ResetBase.' = @{ pl = 'Potwierdzenie obejmuje wszystkie pozycje, w tym czyszczenie logów, zarządzanie punktami przywracania i nieodwracalne ResetBase.'; en = 'This confirms all options, including event-log cleanup, restore-point management, and irreversible ResetBase.' }
    'Czy uruchomic wybrane operacje?' = @{ pl = 'Czy uruchomić wybrane operacje?'; en = 'Run the selected operations?' }
    'Nie wybrano zadnej operacji.' = @{ pl = 'Nie wybrano żadnej operacji.'; en = 'No operations selected.' }
    'ENTER - zatwierdz wybor' = @{ pl = 'ENTER – zatwierdź wybór'; en = 'ENTER – confirm selection' }
    'ZAZNACZ WSZYSTKIE opcje (ponowne 7 odznacza wszystkie)' = @{ pl = 'ZAZNACZ WSZYSTKIE opcje (ponowne 7 odznacza wszystkie)'; en = 'SELECT ALL options (press 7 again to clear all)' }
    'BLAD w opcji' = @{ pl = 'BŁĄD w opcji'; en = 'ERROR in option' }
    'Ten skrypt jest przeznaczony dla systemu Windows.' = @{ pl = 'Ten skrypt jest przeznaczony dla systemu Windows.'; en = 'This script is intended for Windows.' }
    'Skrypt wymaga uprawnien administratora. Otwieram okno UAC...' = @{ pl = 'Skrypt wymaga uprawnień administratora. Otwieram okno UAC...'; en = 'Administrator privileges are required. Opening the UAC prompt...' }
    'Sesja zakonczyla sie.' = @{ pl = 'Sesja zakończyła się.'; en = 'Session finished.' }
    'Usuniete elementy:' = @{ pl = 'Usunięte elementy:'; en = 'Items removed:' }
    'Pominiete:' = @{ pl = 'Pominięte:'; en = 'Skipped:' }
    'Szacowane dane:' = @{ pl = 'Szacowane dane:'; en = 'Estimated data:' }
    'Pobrane/Downloads pozostaly poza zakresem skryptu.' = @{ pl = 'Pobrane/Downloads pozostają poza zakresem skryptu.'; en = 'Downloads remains outside this script''s cleanup scope.' }
    'Nacisnij Enter, aby zamknac' = @{ pl = 'Naciśnij Enter, aby zamknąć'; en = 'Press Enter to close' }
    'Nacisnij Enter, aby kontynuowac' = @{ pl = 'Naciśnij Enter, aby kontynuować'; en = 'Press Enter to continue' }
    'Opcja' = @{ pl = 'Opcja'; en = 'Option' }
    'Tymczasowe pliki' = @{ pl = 'Tymczasowe pliki'; en = 'Temporary files' }
    'Pamiec' = @{ pl = 'Pamięć'; en = 'Storage' }
    'Pobrane' = @{ pl = 'Pobrane'; en = 'Downloads' }
    '[T/N]' = @{ pl = '[T/N]'; en = '[Y/N]' }
}

function Convert-LocalizedText {
    param([AllowNull()][object]$Text)
    if ($null -eq $Text) { return $null }
    $result = [string]$Text
    $keys = @($script:TextMap.Keys | Sort-Object { $_.Length } -Descending)
    foreach ($source in $keys) {
        if ($result.Contains($source)) {
            $result = $result.Replace($source, $script:TextMap[$source][$script:Language])
        }
    }
    return $result
}

function Write-Host {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [AllowNull()][object[]]$Object,
        [ConsoleColor]$ForegroundColor,
        [ConsoleColor]$BackgroundColor,
        [switch]$NoNewline
    )
    $text = if ($Object) { $Object -join ' ' } else { '' }
    $nativeParameters = @{ Object = (Convert-LocalizedText $text); NoNewline = $NoNewline }
    if ($PSBoundParameters.ContainsKey('ForegroundColor')) { $nativeParameters.ForegroundColor = $ForegroundColor }
    if ($PSBoundParameters.ContainsKey('BackgroundColor')) { $nativeParameters.BackgroundColor = $BackgroundColor }
    Microsoft.PowerShell.Utility\Write-Host @nativeParameters
}

function Read-Host {
    [CmdletBinding()]
    param([string]$Prompt)
    Microsoft.PowerShell.Utility\Read-Host -Prompt (Convert-LocalizedText $Prompt)
}

function Write-Rule {
    $width = 76
    try {
        $width = [Console]::WindowWidth
    }
    catch {
        try { $width = $Host.UI.RawUI.WindowSize.Width } catch { }
    }
    if ($width -lt 1) { $width = 76 }
    Write-Host ('_' * $width) -ForegroundColor Cyan
}

function Write-Header {
    Clear-Host
    Write-Host ''
    Write-Host '  WINDOWS 11  |  PORZADKI SYSTEMOWE' -ForegroundColor White
    Write-Host '  Bezpieczne czyszczenie plikow tymczasowych i wybranych pamieci podrecznych' -ForegroundColor Gray
    Write-Rule
    Write-Host '  Folder Pobrane jest pomijany przez ten skrypt.' -ForegroundColor Yellow
    Write-Host ''
}

function Write-Section {
    param([Parameter(Mandatory)][string]$Title)
    Write-Host ''
    Write-Rule
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Rule
}

function Read-YesNo {
    param([Parameter(Mandatory)][string]$Prompt)
    $answer = Read-Host "$Prompt [T/N]"
    return $answer -match '^(t|tak|y|yes)$'
}

function Get-ConfirmationToken {
    param(
        [Parameter(Mandatory)][ValidateSet('EventLogs', 'RestorePoints')][string]$Purpose
    )
    if ($script:Language -eq 'pl') {
        if ($Purpose -eq 'EventLogs') { return 'DZIENNIKI' }
        return 'USUN PUNKTY'
    }
    if ($Purpose -eq 'EventLogs') { return 'EVENTLOGS' }
    return 'DELETE RESTORE POINTS'
}

function Confirm-SelectedAction {
    param([Parameter(Mandatory)][string]$Prompt)
    if ($script:BulkMode) {
        Write-Host 'Objete potwierdzeniem zbiorczym.' -ForegroundColor DarkGray
        return $true
    }
    return Read-YesNo -Prompt $Prompt
}

function Complete-Operation {
    Write-Rule
    Start-Sleep -Seconds 1
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Remove-DirectoryContents {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return
    }

    $items = @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)
    if ($items.Count -eq 0) {
        Write-Host "  - $Label : brak plikow" -ForegroundColor DarkGray
        Complete-Operation
        return
    }

    $removed = 0
    $skipped = 0
    $bytes = 0L
    foreach ($item in $items) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $skipped++
            continue
        }

        try {
            $itemBytes = 0L
            if ($item.PSIsContainer) {
                $itemBytes = (Get-ChildItem -LiteralPath $item.FullName -File -Force -Recurse -ErrorAction SilentlyContinue |
                    Measure-Object -Property Length -Sum).Sum
            }
            else {
                $itemBytes = $item.Length
            }
            Remove-Item -LiteralPath $item.FullName -Force -Recurse -ErrorAction Stop
            $bytes += $itemBytes
            $removed++
        }
        catch {
            $skipped++
            Write-Host "    Nie usunieto: $($item.FullName) [$($_.Exception.Message)]" -ForegroundColor DarkYellow
        }
    }

    $script:RemovedItems += $removed
    $script:SkippedItems += $skipped
    $script:FreedBytes += $bytes
    $size = if ($bytes -ge 1GB) { '{0:N2} GB' -f ($bytes / 1GB) } else { '{0:N0} MB' -f ($bytes / 1MB) }
    Write-Host "  + $Label : usunieto $removed elementow, ok. $size" -ForegroundColor Green
    if ($skipped -gt 0) {
        Write-Host "    Pominieto (np. pliki uzywane lub dowiazania): $skipped" -ForegroundColor DarkYellow
    }
    Complete-Operation
}

function Get-BrowserCacheDirectories {
    $paths = [Collections.Generic.List[string]]::new()

    foreach ($browserRoot in @(
        (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data')
    )) {
        if (Test-Path -LiteralPath $browserRoot -PathType Container) {
            foreach ($profile in Get-ChildItem -LiteralPath $browserRoot -Directory -Force -ErrorAction SilentlyContinue) {
                foreach ($cacheName in @('Cache', 'Code Cache', 'GPUCache', 'Service Worker\CacheStorage')) {
                    $paths.Add((Join-Path $profile.FullName $cacheName))
                }
            }
        }
    }

    foreach ($profileRoot in @(
        (Join-Path $env:LOCALAPPDATA 'Mozilla\Firefox\Profiles'),
        (Join-Path $env:APPDATA 'Mozilla\Firefox\Profiles')
    )) {
        if (Test-Path -LiteralPath $profileRoot -PathType Container) {
            foreach ($profile in Get-ChildItem -LiteralPath $profileRoot -Directory -Force -ErrorAction SilentlyContinue) {
                $paths.Add((Join-Path $profile.FullName 'cache2'))
            }
        }
    }

    foreach ($discordRoot in @(
        (Join-Path $env:APPDATA 'discord'),
        (Join-Path $env:LOCALAPPDATA 'Discord')
    )) {
        foreach ($cacheName in @('Cache', 'Code Cache', 'GPUCache')) {
            $paths.Add((Join-Path $discordRoot $cacheName))
        }
    }

    return $paths.ToArray()
}

function Invoke-SafeCleanup {
    Write-Section 'Czyszczenie plikow tymczasowych i cache'
    Write-Host 'Zamknij przegladarki i aplikacje, aby zwiekszyc skutecznosc.' -ForegroundColor Gray

    if (-not (Confirm-SelectedAction 'Rozpoczac czyszczenie?')) {
        Write-Host 'Pominieto czyszczenie.' -ForegroundColor DarkGray
        return
    }

    $tempPaths = @(
        [pscustomobject]@{ Path = (Join-Path $env:windir 'Temp'); Label = 'Tymczasowe pliki Windows' },
        [pscustomobject]@{ Path = $env:TEMP; Label = 'Tymczasowe pliki biezacego uzytkownika' },
        [pscustomobject]@{ Path = (Join-Path $env:LOCALAPPDATA 'Temp'); Label = 'Lokalny katalog Temp uzytkownika' },
        [pscustomobject]@{ Path = (Join-Path $env:LOCALAPPDATA 'D3DSCache'); Label = 'Pamiec podreczna shaderow DirectX' }
    )
    foreach ($entry in $tempPaths) {
        Remove-DirectoryContents -Path $entry.Path -Label $entry.Label
    }

    Remove-DirectoryContents -Path (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive') -Label 'Archiwalne raporty bledow Windows'
    Remove-DirectoryContents -Path (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue') -Label 'Oczekujace raporty bledow Windows'

    $cachePaths = Get-BrowserCacheDirectories
    foreach ($path in $cachePaths) {
        Remove-DirectoryContents -Path $path -Label "Cache aplikacji: $([IO.Path]::GetFileName($path))"
    }

    Write-Host ''
    Write-Host 'Czyszczenie pobranych plikow Windows Update wymaga zatrzymania uslug.' -ForegroundColor Gray
    if (Confirm-SelectedAction 'Usunac pliki pobrane przez Windows Update?') {
        $serviceNames = @('wuauserv', 'bits')
        $serviceStates = @{}
        foreach ($name in $serviceNames) {
            $service = Get-Service -Name $name -ErrorAction SilentlyContinue
            if ($service) {
                $serviceStates[$name] = $service.Status
            }
        }

        try {
            foreach ($name in $serviceStates.Keys) {
                if ($serviceStates[$name] -eq 'Running') {
                    Stop-Service -Name $name -Force -ErrorAction Stop
                }
            }
            Remove-DirectoryContents -Path (Join-Path $env:windir 'SoftwareDistribution\Download') -Label 'Pobrane pliki Windows Update'
        }
        finally {
            foreach ($name in $serviceStates.Keys) {
                if ($serviceStates[$name] -eq 'Running') {
                    try {
                        if ((Get-Service -Name $name).Status -ne 'Running') {
                            Start-Service -Name $name -ErrorAction Stop
                        }
                    }
                    catch {
                        Write-Host "  Nie udalo sie ponownie uruchomic uslugi $name : $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        }
    }

    if (Get-Command -Name Delete-DeliveryOptimizationCache -ErrorAction SilentlyContinue) {
        if (Confirm-SelectedAction 'Usunac cache Optymalizacji dostarczania Windows?') {
            Delete-DeliveryOptimizationCache -Force
            Write-Host '  + Usunieto cache Optymalizacji dostarczania.' -ForegroundColor Green
            Complete-Operation
        }
    }

    if (Confirm-SelectedAction 'Oproznic Kosz? Ta operacja trwale usuwa jego zawartosc.') {
        if (Get-Command -Name Clear-RecycleBin -ErrorAction SilentlyContinue) {
            Clear-RecycleBin -Force -ErrorAction Stop
            Write-Host '  + Oprozniono Kosz biezacego uzytkownika.' -ForegroundColor Green
            Complete-Operation
        }
        else {
            Write-Host 'Nie znaleziono polecenia Clear-RecycleBin; Kosz pozostawiono bez zmian.' -ForegroundColor Yellow
        }
    }
}

function Invoke-DismCleanup {
    Write-Section 'Koncowy etap: DISM i magazyn skladnikow'
    $dism = Join-Path $env:windir 'System32\dism.exe'
    if (-not (Test-Path -LiteralPath $dism -PathType Leaf)) {
        throw 'Nie znaleziono programu DISM.'
    }

    Write-Host 'DISM wykona kolejno analize, standardowe czyszczenie i ResetBase /Defer.' -ForegroundColor Gray
    Write-Host 'RESETBASE JEST NIEODWRACALNE:' -ForegroundColor Red
    Write-Host '  - po wykonaniu nie bedzie mozna odinstalowac obecnie zainstalowanych aktualizacji Windows;' -ForegroundColor Yellow
    Write-Host '  - nie bedzie mozna przywrocic poprzednich wersji zastapionych skladnikow;' -ForegroundColor Yellow
    Write-Host '  - punkt przywracania nie cofnie tych zmian.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'Analiza magazynu skladnikow (bez wprowadzania zmian)...' -ForegroundColor Cyan
    & $dism /Online /Cleanup-Image /AnalyzeComponentStore
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Analiza DISM zakonczyla sie kodem $LASTEXITCODE; dalsze kroki pominieto." -ForegroundColor Red
        return
    }

    Complete-Operation
    Write-Host ''
    Write-Host 'Standardowe czyszczenie zastapionych skladnikow...' -ForegroundColor Cyan
    & $dism /Online /Cleanup-Image /StartComponentCleanup
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Standardowe czyszczenie DISM zakonczylo sie kodem $LASTEXITCODE; ResetBase pominieto." -ForegroundColor Red
        return
    }

    Complete-Operation
    Write-Host ''
    Write-Host 'Uruchamiam ResetBase /Defer (bez mozliwosci odinstalowania aktualizacji)...' -ForegroundColor Yellow
    & $dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase /Defer
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ResetBase DISM zakonczyl sie kodem $LASTEXITCODE." -ForegroundColor Red
    }
}

function Invoke-DiskCleanup {
    Write-Section 'Wbudowane Oczyszczanie dysku'
    Write-Host 'Uruchamiam ciche cleanmgr: wszystkie skonfigurowane kategorie na wykrytych dyskach.' -ForegroundColor Gray
    Write-Host 'Kategoria Pobrane/Downloads jest jawnie wylaczona. Kosz i poprzednie instalacje moga zostac usuniete.' -ForegroundColor Yellow
    Write-Host 'Profil cleanmgr jest tymczasowy i zostanie przywrocony po zakonczeniu.' -ForegroundColor Gray
    $cleanmgr = Join-Path $env:windir 'System32\cleanmgr.exe'
    if (-not (Test-Path -LiteralPath $cleanmgr)) {
        throw 'Nie znaleziono cleanmgr.exe.'
    }

    $volumeCachesPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
    $handlers = @(Get-ChildItem -LiteralPath $volumeCachesPath -ErrorAction Stop)
    do {
        $profileId = Get-Random -Minimum 1000 -Maximum 10000
        $flagName = 'StateFlags{0:D4}' -f $profileId
        $profileInUse = $false
        foreach ($handler in $handlers) {
            if ($handler.GetValueNames() -contains $flagName) {
                $profileInUse = $true
                break
            }
        }
    } while ($profileInUse)

    $originalFlags = @{}
    try {
        foreach ($handler in $handlers) {
            $keyPath = $handler.PSPath
            $hasExistingValue = $handler.GetValueNames() -contains $flagName
            $originalFlags[$keyPath] = [pscustomobject]@{
                HadValue = $hasExistingValue
                Value = if ($hasExistingValue) { $handler.GetValue($flagName) } else { $null }
                Kind = if ($hasExistingValue) { $handler.GetValueKind($flagName) } else { $null }
            }
            $selectedValue = if ($handler.PSChildName -eq 'DownloadsFolder') { 0 } else { 2 }
            New-ItemProperty -LiteralPath $keyPath -Name $flagName -Value $selectedValue -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        }

        Write-Host "Czyszczenie kategorii cleanmgr (profil tymczasowy $profileId)..." -ForegroundColor Cyan
        $process = Start-Process -FilePath $cleanmgr -ArgumentList @("/sagerun:$profileId") -WindowStyle Hidden -PassThru -Wait
        if ($process.ExitCode -ne 0) {
            Write-Host "  cleanmgr /sagerun:$profileId zakonczyl sie kodem $($process.ExitCode)." -ForegroundColor Red
        }
        Complete-Operation

        Write-Host 'Usuwanie pozostalosci po poprzednich aktualizacjach Windows...' -ForegroundColor Cyan
        $process = Start-Process -FilePath $cleanmgr -ArgumentList @('/AUTOCLEAN') -WindowStyle Hidden -PassThru -Wait
        if ($process.ExitCode -ne 0) {
            Write-Host "  cleanmgr /AUTOCLEAN zakonczyl sie kodem $($process.ExitCode)." -ForegroundColor Red
        }
    }
    finally {
        foreach ($keyPath in $originalFlags.Keys) {
            $saved = $originalFlags[$keyPath]
            if ($saved.HadValue) {
                New-ItemProperty -LiteralPath $keyPath -Name $flagName -Value $saved.Value -PropertyType $saved.Kind -Force -ErrorAction Stop | Out-Null
            }
            else {
                Remove-ItemProperty -LiteralPath $keyPath -Name $flagName -ErrorAction SilentlyContinue
            }
        }
    }
    Write-Host '  Ciche czyszczenie cleanmgr zakonczone.' -ForegroundColor Green
}


function Invoke-DumpCleanup {
    Write-Section 'Zrzuty pamieci i awarii'
    $candidates = @(
        (Join-Path $env:windir 'MEMORY.DMP'),
        (Join-Path $env:windir 'Minidump'),
        (Join-Path $env:LOCALAPPDATA 'CrashDumps')
    )

    $dumpFiles = [Collections.Generic.List[IO.FileInfo]]::new()
    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $dumpFiles.Add((Get-Item -LiteralPath $path -Force))
        }
        elseif (Test-Path -LiteralPath $path -PathType Container) {
            foreach ($file in Get-ChildItem -LiteralPath $path -File -Force -Recurse -ErrorAction SilentlyContinue) {
                if ($file.Extension -in @('.dmp', '.mdmp')) {
                    $dumpFiles.Add($file)
                }
            }
        }
    }

    if ($dumpFiles.Count -eq 0) {
        Write-Host 'Nie znaleziono zrzutow w typowych lokalizacjach.' -ForegroundColor DarkGray
        return
    }

    $dumpFiles = @($dumpFiles | Sort-Object FullName -Unique)
    foreach ($file in $dumpFiles) {
        Write-Host ('  {0,8:N0} MB  {1}' -f ($file.Length / 1MB), $file.FullName) -ForegroundColor Gray
    }
    Write-Host 'Lista obejmuje tylko standardowe lokalizacje zrzutow systemu i aplikacji.' -ForegroundColor DarkGray
    if (-not (Confirm-SelectedAction "Usunac pokazane zrzuty ($($dumpFiles.Count))?")) {
        return
    }

    foreach ($file in $dumpFiles) {
        try {
            Remove-Item -LiteralPath $file.FullName -Force -Recurse -ErrorAction Stop
            $script:RemovedItems++
            $script:FreedBytes += $file.Length
            Write-Host "  + Usunieto: $($file.FullName)" -ForegroundColor Green
        }
        catch {
            $script:SkippedItems++
            Write-Host "  - Nie usunieto: $($file.FullName) [$($_.Exception.Message)]" -ForegroundColor DarkYellow
        }
    }
}

function Clear-EventLogs {
    Write-Section 'Dzienniki zdarzen Windows'
    Write-Host 'Ta operacja usuwa historie diagnostyczna i audytowa, w tym dziennik Security.' -ForegroundColor Yellow
    Write-Host 'Nie zalecamy jej rutynowo; moze utrudnic diagnostyke problemow.' -ForegroundColor Yellow
    if (-not $script:BulkMode) {
        $confirmation = Read-Host 'Aby wyczyscic wszystkie dzienniki, wpisz DZIENNIKI'
        if ($confirmation -cne 'DZIENNIKI') {
            Write-Host 'Dzienniki pozostawiono bez zmian.' -ForegroundColor Gray
            return
        }
    }

    $logs = @(& wevtutil.exe el)
    if ($LASTEXITCODE -ne 0) {
        throw "wevtutil nie mogl pobrac listy dziennikow (kod $LASTEXITCODE)."
    }
    $failedLogs = [Collections.Generic.List[string]]::new()
    foreach ($log in $logs) {
        if ([string]::IsNullOrWhiteSpace($log)) { continue }
        try {
            $null = & wevtutil.exe cl $log 2>&1
            $exitCode = $LASTEXITCODE
        }
        catch {
            $exitCode = 1
        }
        if ($exitCode -ne 0) {
            $failedLogs.Add($log)
        }
    }
    if ($failedLogs.Count -eq 0) {
        Write-Host 'Wyczyszczono dostepne dzienniki zdarzen.' -ForegroundColor Green
    }
    else {
        Write-Host "Dzienniki niedostepne lub chronione, pozostawione bez zmian: $($failedLogs.Count)." -ForegroundColor Yellow
        foreach ($log in $failedLogs) {
            Write-Host "  - $log" -ForegroundColor DarkYellow
        }
    }
}

function Invoke-RestorePointManagement {
    Write-Section 'Punkty przywracania systemu'
    try {
        $points = @(Get-CimInstance -Namespace 'root/default' -ClassName SystemRestore -ErrorAction Stop | Sort-Object SequenceNumber)
    }
    catch {
        try {
            $points = @(Get-ComputerRestorePoint -ErrorAction Stop | Sort-Object SequenceNumber)
        }
        catch {
            Write-Host "Nie mozna odczytac punktow przywracania: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host 'Sprawdz, czy Ochrona systemu jest wlaczona dla dysku systemowego.' -ForegroundColor Gray
            return
        }
    }
    if ($points.Count -eq 0) {
        Write-Host 'System nie zglasza dostepnych punktow przywracania.' -ForegroundColor DarkGray
    }
    else {
        Write-Host '  Nr       Data utworzenia         Opis' -ForegroundColor Gray
        foreach ($point in $points) {
            $created = [string]$point.CreationTime
            try {
                $created = [System.Management.ManagementDateTimeConverter]::ToDateTime($created).ToString('yyyy-MM-dd HH:mm')
            }
            catch { }
            Write-Host ('  {0,-8} {1,-23} {2}' -f $point.SequenceNumber, $created, $point.Description) -ForegroundColor White
        }
    }

    Write-Host ''
    Write-Host 'Podaj numery do usuniecia, oddzielone przecinkami; ALL usuwa wszystkie; Enter anuluje.' -ForegroundColor Gray
    $selection = Read-Host 'Numery punktow'
    $toDelete = @()
    if ($selection -match '^\s*ALL\s*$') {
        $toDelete = $points
    }
    elseif (-not [string]::IsNullOrWhiteSpace($selection)) {
        $requested = @($selection -split ',' | ForEach-Object { $_.Trim() })
        foreach ($value in $requested) {
            if ($value -notmatch '^\d+$' -or -not ($points.SequenceNumber -contains [uint32]$value)) {
                Write-Host "Nieprawidlowy lub nieistniejacy numer: $value. Niczego nie usunieto." -ForegroundColor Red
                return
            }
        }
        $toDelete = @($points | Where-Object { $requested -contains ([string]$_.SequenceNumber) })
    }

    if ($toDelete.Count -gt 0) {
        Write-Host "Do usuniecia: $((@($toDelete | ForEach-Object { $_.SequenceNumber }) -join ', '))" -ForegroundColor Yellow
        $confirmed = $script:BulkMode
        if (-not $confirmed) {
            $confirmation = Read-Host 'Aby potwierdzic, wpisz USUN PUNKTY'
            $confirmed = $confirmation -ceq 'USUN PUNKTY'
        }
        if (-not $confirmed) {
            Write-Host 'Punkty pozostawiono bez zmian.' -ForegroundColor Gray
        }
        else {
            if (-not ('RestorePointNative' -as [type])) {
                Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class RestorePointNative
{
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern IntPtr LoadLibrary(string fileName);

    [DllImport("kernel32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
    private static extern IntPtr GetProcAddress(IntPtr module, string procedureName);

    [UnmanagedFunctionPointer(CallingConvention.Winapi)]
    private delegate uint RemoveRestorePointDelegate(uint sequenceNumber);

    public static uint Remove(uint sequenceNumber)
    {
        IntPtr module = LoadLibrary("SrClient.dll");
        if (module == IntPtr.Zero)
            throw new InvalidOperationException("Nie mozna zaladowac SrClient.dll.");

        IntPtr address = GetProcAddress(module, "SRRemoveRestorePoint");
        if (address == IntPtr.Zero)
            throw new InvalidOperationException("Nie znaleziono funkcji SRRemoveRestorePoint.");

        var remove = (RemoveRestorePointDelegate)Marshal.GetDelegateForFunctionPointer(
            address, typeof(RemoveRestorePointDelegate));
        return remove(sequenceNumber);
    }
}
'@
            }
            foreach ($point in $toDelete) {
                $result = [RestorePointNative]::Remove([uint32]$point.SequenceNumber)
                if ($result -eq 0) {
                    Write-Host "  + Usunieto punkt $($point.SequenceNumber): $($point.Description)" -ForegroundColor Green
                }
                else {
                    $failureReason = [ComponentModel.Win32Exception]::new([int]$result).Message
                    Write-Host "  - Nie udalo sie usunac punktu $($point.SequenceNumber): $failureReason (kod $result)." -ForegroundColor Red
                    if ($result -eq 5) {
                        Write-Host '    Windows odmowil usuniecia tego punktu; moze byc chroniony lub zarzadzany przez system.' -ForegroundColor DarkYellow
                    }
                }
                Complete-Operation
            }
        }
    }

    if (Read-YesNo 'Czy po zmianach utworzyc nowy punkt przywracania?') {
        try {
            $restorePointDescription = if ($script:Language -eq 'pl') { 'Punkt po czyszczeniu systemu' } else { 'After system cleanup' }
            Checkpoint-Computer -Description $restorePointDescription -RestorePointType MODIFY_SETTINGS
            Write-Host 'Utworzono nowy punkt przywracania.' -ForegroundColor Green
        }
        catch {
            Write-Host "Nie utworzono punktu przywracania: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host 'Windows moze ograniczac tworzenie punktow do jednego na 24 godziny.' -ForegroundColor Gray
        }
    }
}

function Invoke-MainMenu {
    while ($true) {
        $selected = [Collections.Generic.HashSet[string]]::new()
        $options = [ordered]@{
            '1' = 'Bezpieczne czyszczenie (Temp, cache przegladarek, WER, opcjonalnie Windows Update)'
            '2' = 'Ciche cleanmgr na wszystkich dyskach (wszystkie kategorie oprocz Pobrane)'
            '3' = 'Wyszukaj i opcjonalnie usun zrzuty DMP'
            '4' = 'Zarzadzaj punktami przywracania (wybor konkretnych punktow)'
            '5' = 'Wyczysc wszystkie dzienniki zdarzen (operacja ryzykowna)'
            '6' = 'DISM: analiza, czyszczenie i ResetBase (blokuje odinstalowanie aktualizacji)'
        }

        $finishMenu = $false
        while (-not $finishMenu) {
            Write-Header
            Write-Host '  Wcisnij cyfre 1-6, aby wybrac warianty czyszczenia.' -ForegroundColor Gray
            Write-Host ''

            foreach ($key in $options.Keys) {
                $isSelected = $selected.Contains([string]$key)
                $marker = if ($isSelected) { '*' } else { ' ' }
                $color = if ($isSelected) { [ConsoleColor]::Green } elseif ($key -eq '6') { [ConsoleColor]::Yellow } else { [ConsoleColor]::White }
                Write-Host ('  [{0}] {1}  {2}' -f $marker, $key, $options[$key]) -ForegroundColor $color
            }
            $allSelected = $selected.Count -eq $options.Count
            $allMarker = if ($allSelected) { '*' } else { ' ' }
            $allColor = if ($allSelected) { [ConsoleColor]::Green } else { [ConsoleColor]::Cyan }
            Write-Host ('  [{0}] 7  ZAZNACZ WSZYSTKIE opcje (ponowne 7 odznacza wszystkie)' -f $allMarker) -ForegroundColor $allColor
            Write-Host ''
            Write-Host 'ENTER - zatwierdz wybor' -ForegroundColor Gray

            $keyInfo = [Console]::ReadKey($true)
            $pressed = [string]$keyInfo.KeyChar
            if ($pressed -eq '7') {
                if ($selected.Count -eq $options.Count) {
                    $selected.Clear()
                }
                else {
                    foreach ($key in $options.Keys) {
                        [void]$selected.Add([string]$key)
                    }
                }
                continue
            }
            if ($pressed -match '^[1-6]$') {
                if (-not $selected.Add($pressed)) {
                    [void]$selected.Remove($pressed)
                }
                continue
            }
            if ($keyInfo.Key -ne [ConsoleKey]::Enter) {
                continue
            }

            if ($selected.Count -eq 0) {
                Write-Host 'Nie wybrano zadnej operacji.' -ForegroundColor DarkYellow
                Start-Sleep -Milliseconds 900
                continue
            }

            $choices = @($options.Keys | Where-Object { $selected.Contains([string]$_) })
            Write-Host ''
            Write-Host 'Wybrane operacje:' -ForegroundColor Cyan
            foreach ($choice in $choices) {
                Write-Host "  * $choice  $($options[$choice])" -ForegroundColor Green
            }
            $script:BulkMode = $selected.Count -eq $options.Count
            if ($selected.Contains('6')) {
                Write-Host 'UWAGA: DISM ResetBase jest nieodwracalne i blokuje odinstalowanie aktualizacji Windows.' -ForegroundColor Yellow
                Write-Host 'Punkt przywracania nie cofnie tych zmian.' -ForegroundColor Yellow
            }
            if ($selected.Contains('2')) {
                Write-Host 'cleanmgr obejmie wszystkie wykryte dyski; moze usunac Kosz i poprzednie instalacje Windows.' -ForegroundColor Yellow
                Write-Host 'Pobrane/Downloads jest wylaczone z profilu.' -ForegroundColor Yellow
            }
            if ($script:BulkMode) {
                Write-Host 'Potwierdzenie obejmuje wszystkie pozycje, w tym wyczyszczenie logow, zarzadzanie punktami przywracania oraz nieodwracalne ResetBase.' -ForegroundColor Yellow
            }
            if (-not (Read-YesNo 'Czy uruchomic wybrane operacje?')) {
                $script:BulkMode = $false
                $selected.Clear()
                continue
            }

            foreach ($choice in $choices) {
                Write-Section "Opcja $choice"
                try {
                    switch ($choice) {
                        '1' { Invoke-SafeCleanup }
                        '2' { Invoke-DiskCleanup }
                        '3' { Invoke-DumpCleanup }
                        '4' { Invoke-RestorePointManagement }
                        '5' { Clear-EventLogs }
                        '6' { Invoke-DismCleanup }
                    }
                }
                catch {
                    Write-Host ''
                    Write-Host "BLAD w opcji ${choice}: $($_.Exception.Message)" -ForegroundColor Red
                }

                Complete-Operation
            }

            $script:BulkMode = $false
            $finishMenu = $true
        }
    }
}

if (-not $IsWindows -and [Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Ten skrypt jest przeznaczony dla systemu Windows.'
}

if (-not (Test-IsAdministrator)) {
    Write-Host 'Skrypt wymaga uprawnien administratora. Otwieram okno UAC...' -ForegroundColor Yellow
    $hostExe = Join-Path $PSHOME 'powershell.exe'
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $hostExe = Join-Path $PSHOME 'pwsh.exe'
    }
    Start-Process -FilePath $hostExe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

try {
    Invoke-MainMenu
}
finally {
    Write-Header
    Write-Host '  Sesja zakonczyla sie.' -ForegroundColor Cyan
    if ($script:RemovedItems -gt 0 -or $script:SkippedItems -gt 0) {
        Write-Host "  Usuniete elementy: $script:RemovedItems | Pominiete: $script:SkippedItems | Szacowane dane: $([math]::Round($script:FreedBytes / 1GB, 2)) GB" -ForegroundColor Gray
    }
    Write-Host '  Pobrane/Downloads pozostaly poza zakresem skryptu.' -ForegroundColor Green
    Write-Rule
    [void](Read-Host 'Nacisnij Enter, aby zamknac')
}