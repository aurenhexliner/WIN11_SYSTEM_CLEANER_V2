# Windows 11 Junk File Removal v2.0

## 🖥️ Graphical edition — GUI v2.0

Prefer a desktop app? Download the self-contained Windows x64 GUI. It includes the cleanup script and shows live progress, prompts, and the final summary in the Activity panel.

**[⬇️ Download GUI (Windows x64)](https://github.com/aurenhexliner/WIN11_SYSTEM_CLEANER_V2/releases/download/WIN11_JUNK_FILE_REMOVAL_GUI_V2/Win11JunkFileRemovalGui.exe)** · **[📦 View the GUI release and all files](https://github.com/aurenhexliner/WIN11_SYSTEM_CLEANER_V2/releases/tag/WIN11_JUNK_FILE_REMOVAL_GUI_V2)**

[📄 GUI guide (English)](https://github.com/aurenhexliner/WIN11_SYSTEM_CLEANER_V2/releases/download/WIN11_JUNK_FILE_REMOVAL_GUI_V2/README_GUI.txt) · [📄 GUI guide (Polski)](https://github.com/aurenhexliner/WIN11_SYSTEM_CLEANER_V2/releases/download/WIN11_JUNK_FILE_REMOVAL_GUI_V2/README_GUI_PL.txt) · [⚖️ Licence](https://github.com/aurenhexliner/WIN11_SYSTEM_CLEANER_V2/releases/download/WIN11_JUNK_FILE_REMOVAL_GUI_V2/LICENCE.txt)

**Windows system cleanup and maintenance script**

An interactive PowerShell utility to help reclaim disk space and clean up
Windows 10/11. Choose whether to remove temporary system and user files,
popular application caches, Windows Update remnants, Recycle Bin contents,
and memory dumps.

The script also provides tools for managing Windows event logs and restore
points. Its optional **DISM** stage analyzes the Windows component store and
removes superseded components to help reduce the space they use. The
**ResetBase** operation is irreversible and prevents uninstalling updates
that are currently installed.

---

## 📋 Requirements

- **Operating system:** Windows 10 or Windows 11
- **PowerShell:** Windows PowerShell 5.1 or PowerShell 7.x, including Preview
- **Permissions:** a user account in the **Administrators** group, or access
  to administrator credentials when prompted by UAC

## 🚀 Run

### Method 1 — File Explorer

Right-click `WIN11_SYSTEM_CLEANER.ps1` and select **Run with PowerShell**.
If the script is not already elevated, it will request administrator
permissions through UAC.

### Method 2 — Open a terminal in the script folder

In File Explorer, open the folder containing the script, right-click an empty
area, and select **Open in Terminal**. Make sure the active tab is running
PowerShell, enter the command below, and press Enter:

```powershell
.\WIN11_SYSTEM_CLEANER.ps1
```

If the terminal is not running as administrator, the script will request
elevation through UAC.

### Method 3 — Start Terminal as administrator

Right-click the **Start** button and select **Terminal (Admin)** or
**Windows Terminal (Admin)**. Navigate to the script folder:

```powershell
Set-Location "C:\path\to\temp-cleaner"
.\WIN11_SYSTEM_CLEANER.ps1
```

If execution-policy settings block the script, follow your computer’s
security policy. The script does not change execution policies.

## 🌐 Language and menu

The interface follows the Windows system locale (**LOCALE**): Polish locale
displays the Polish interface; all other locales display English.

- **1–6:** toggle individual cleanup options
- **7:** select all options or clear the selection
- **0**, then **Enter:** exit the program
- **Enter:** run the selected operations

Selected options are marked with a green asterisk. Operations start without
additional confirmation prompts. The script displays a reminder to close
browsers and asks which restore points to remove when restore-point
management is selected. Choosing existing points schedules a new restore point
after all selected operations. Pressing Enter without a selection cancels
restore-point management and does not create a point.

After each run, the script displays a summary with the known number of files
removed, estimated space reclaimed, skipped items, event logs cleared, and
restore points removed and created. `cleanmgr` and some system operations do
not provide exact statistics. A detailed log can be saved to
`%LOCALAPPDATA%\Windows11JunkFileRemoval\Logs`. The default answer is **No**
— press Enter. The script then returns to the menu.

## 🧹 Scope

1. Remove Windows and current-user temporary files, the DirectX shader cache,
   and selected Windows Error Reporting files.
2. Run Disk Cleanup (`cleanmgr`) silently on detected drives. The script uses
   a temporary category profile, excludes the **Downloads** folder category,
   and restores the profile’s previous settings. `/AUTOCLEAN` removes remnants
   of previous Windows upgrades.
3. Search for and remove memory and crash dumps in common locations.
4. List restore points and select specific or all points for deletion. A new
   restore point is created only when existing points are selected; pressing
   Enter without a selection cancels without creating one.
5. Clear accessible Windows event logs when this option is selected.
6. Analyze the DISM component store, perform standard cleanup, and run
   `/ResetBase /Defer`.

Option 1 also covers caches for **Chrome, Edge, Firefox, and Discord**. It
also removes downloaded Windows Update files, the Delivery Optimization
cache, and Recycle Bin contents when the required system commands are
available. The user’s Downloads folder category is excluded from `cleanmgr`.

## ⚠️ Important warnings

- `cleanmgr` runs without its standard UI and processes all detected drives.
  Depending on available categories, it may remove Recycle Bin contents or
  previous Windows installations. Review the selected options before
  confirming.
- **`/ResetBase` is irreversible.** Selecting the DISM option starts this
  operation without an additional confirmation. After it completes, installed Windows
  updates can no longer be uninstalled, and previous versions of superseded
  components cannot be restored. A restore point will not undo these changes.
- Event-log cleanup removes diagnostic and audit history, including the
  **Security** log if Windows allows it to be cleared. This can make
  troubleshooting harder, so routine use is not recommended.
- Files in use by Windows or applications may remain. The script skips
  reparse points when cleaning directories and reports skipped items.

## 🎨 Console colors

The script applies a dark navy RGB background (`#0B1220`) and high-contrast
text colors. Terminals with VT support receive explicit RGB colors; older
consoles use a temporary palette change when available. The script attempts
to restore modified console settings on exit. Some terminals may restrict
color changes or render them according to their own theme.

## 📦 Legacy script

The `clean.cmd` file is unchanged. Its use is not recommended because it
deletes the contents of `Windows\Logs` and `SoftwareDistribution` without
separately selecting those operations.

---

**Author:** Jacek Żaczek
