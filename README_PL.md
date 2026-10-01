# Windows 11 Junk File Removal v2.0

**Skrypt czyszczenia i konserwacji systemu Windows**

Interaktywny skrypt PowerShell pomagający zwolnić miejsce i uporządkować
system Windows 10/11. Pozwala wybrać pliki tymczasowe systemu i użytkownika,
pamięci podręczne popularnych aplikacji, pozostałości po aktualizacjach,
zawartość Kosza oraz zrzuty pamięci do usunięcia.

Skrypt udostępnia również zarządzanie dziennikami zdarzeń i punktami
przywracania systemu. Opcjonalny etap **DISM** analizuje magazyn składników
Windows i usuwa zastąpione składniki, pomagając ograniczyć zajmowane przez
nie miejsce. Operacja **ResetBase** jest nieodwracalna i uniemożliwia
odinstalowanie już zainstalowanych aktualizacji.

---

## 📋 Wymagania

- **System:** Windows 10 lub Windows 11
- **PowerShell:** Windows PowerShell 5.1 albo PowerShell 7.x, również Preview
- **Uprawnienia:** konto użytkownika należące do grupy **Administratorzy**
  albo dostęp do poświadczeń konta administratora wymaganych przez UAC

## 🚀 Uruchomienie

### Metoda 1 — Eksplorator plików

Kliknij prawym przyciskiem myszy `WIN11_SYSTEM_CLEANER.ps1` i wybierz
**Uruchom za pomocą programu PowerShell** (*Run with PowerShell*).
Jeśli skrypt nie ma uprawnień administratora, poprosi o ich nadanie przez UAC.

### Metoda 2 — Terminal otwarty w folderze skryptu

W Eksploratorze plików otwórz folder ze skryptem, kliknij prawym przyciskiem
myszy jego puste miejsce i wybierz **Otwórz w terminalu** (*Open in Terminal*).
Upewnij się, że aktywna karta korzysta z PowerShell, wpisz polecenie i naciśnij
Enter:

```powershell
.\WIN11_SYSTEM_CLEANER.ps1
```

Jeśli terminal nie jest uruchomiony jako administrator, skrypt poprosi
o podniesienie uprawnień przez UAC.

### Metoda 3 — Terminal uruchomiony jako administrator

Kliknij prawym przyciskiem myszy przycisk **Start** i wybierz
**Terminal (Administrator)** lub **Windows Terminal (Administrator)**.
Przejdź do folderu ze skryptem:

```powershell
Set-Location "C:\ścieżka\do\temp-cleaner"
.\WIN11_SYSTEM_CLEANER.ps1
```

Jeśli zasady wykonywania skryptów blokują uruchomienie, postępuj zgodnie
z polityką bezpieczeństwa komputera. Skrypt samodzielnie nie zmienia tych
zasad.

## 🌐 Język i menu

Interfejs jest wybierany na podstawie języka systemowego Windows (**LOCALE**):
polski LOCALE wyświetla polski interfejs, a pozostałe — angielski.

- **1–6:** przełączanie poszczególnych opcji czyszczenia
- **7:** zaznaczenie wszystkich opcji lub wyczyszczenie zaznaczenia
- **0**, następnie **Enter:** wyjście z programu
- **Enter:** uruchomienie zaznaczonych operacji

Zaznaczone pozycje są oznaczone zieloną gwiazdką. Operacje zaczynają się
bez dodatkowego pytania o potwierdzenie. Skrypt wyświetla przypomnienie
o zamknięciu przeglądarek oraz prosi o wybór punktów przywracania do usunięcia.
Po wybraniu istniejących punktów do usunięcia skrypt utworzy nowy punkt po
zakończeniu operacji. Naciśnięcie Enter bez wyboru anuluje zarządzanie punktami
i nie tworzy nowego.

Po każdej serii operacji skrypt wyświetla podsumowanie: znaną liczbę
usuniętych plików, szacowaną ilość zwolnionego miejsca, pominięte elementy,
wyczyszczone dzienniki oraz usunięte i utworzone punkty przywracania.
`cleanmgr` i część operacji systemowych nie udostępniają dokładnych statystyk.
Szczegółowy log można zapisać do `%LOCALAPPDATA%\Windows11JunkFileRemoval\Logs`.
Domyślna odpowiedź to **Nie** — naciśnij Enter. Następnie skrypt wraca do menu.

## 🧹 Zakres działania

1. Usuwanie plików tymczasowych Windows i bieżącego użytkownika, pamięci
   podręcznej shaderów DirectX oraz wybranych raportów błędów Windows.
2. Ciche uruchomienie Oczyszczania dysku (`cleanmgr`) na wykrytych dyskach.
   Skrypt korzysta z tymczasowego profilu kategorii, pomija kategorię folderu
   **Pobrane** i przywraca poprzednie ustawienia profilu. Parametr
   `/AUTOCLEAN` usuwa pozostałości po poprzednich aktualizacjach Windows.
3. Wyszukiwanie i usuwanie zrzutów pamięci i awarii w typowych lokalizacjach.
4. Wyświetlanie punktów przywracania i wybór konkretnych lub wszystkich do
   usunięcia. Nowy punkt jest tworzony tylko po wybraniu istniejących punktów;
   Enter bez wyboru anuluje bez tworzenia punktu.
5. Czyszczenie dostępnych dzienników zdarzeń po wybraniu tej opcji w menu.
6. Analiza magazynu składników DISM, standardowe czyszczenie i uruchomienie
   `/ResetBase /Defer`.

Opcja 1 obejmuje również pamięci podręczne **Chrome, Edge, Firefox i Discord**.
Podczas tej operacji skrypt usuwa pobrane pliki Windows Update, pamięć
podręczną Optymalizacji dostarczania i zawartość Kosza, jeśli odpowiednie
narzędzie systemowe jest dostępne. Kategoria folderu Pobrane użytkownika
jest wyłączona z czyszczenia `cleanmgr`.

## ⚠️ Ważne ostrzeżenia

- `cleanmgr` działa bez standardowego okna i przetwarza wszystkie wykryte
  dyski. W zależności od dostępnych kategorii może usunąć zawartość Kosza lub
  poprzednie instalacje Windows. Przed zatwierdzeniem sprawdź wybrane opcje.
- **`/ResetBase` jest nieodwracalne.** Wybranie opcji DISM uruchamia tę
  operację bez dodatkowego pytania. Po jej wykonaniu nie można
  odinstalować zainstalowanych aktualizacji Windows ani przywrócić
  poprzednich wersji zastąpionych składników. Punkt przywracania nie cofnie
  tych zmian.
- Czyszczenie dzienników usuwa historię diagnostyczną i audytową, w tym
  dziennik **Security**, jeśli system zezwoli na jego wyczyszczenie. Może to
  utrudnić diagnostykę; nie zaleca się rutynowego używania tej opcji.
- Pliki używane przez system lub aplikacje mogą pozostać na dysku. Skrypt
  pomija dowiązania/reparse points podczas czyszczenia katalogów i raportuje
  pominięte elementy.

## 🎨 Wygląd konsoli

Skrypt ustawia granatowe tło RGB (`#0B1220`) i kontrastowe kolory tekstu.
Terminale z obsługą sekwencji VT otrzymują jawne kolory RGB; starsze konsole
korzystają z tymczasowej zmiany palety, jeśli jest dostępna. Skrypt próbuje
przywrócić zmienione ustawienia konsoli przy zamykaniu. Niektóre terminale
mogą ograniczać zmianę kolorów lub stosować własny motyw.

## 📦 Starszy skrypt

Plik `clean.cmd` pozostaje bez zmian. Nie zaleca się jego używania, ponieważ
usuwa zawartość `Windows\Logs` i `SoftwareDistribution` bez osobnego wyboru
tych operacji.

---

**Autor:** Jacek Żaczek
