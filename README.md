# Prepare DOS games for Batocera

I got my roms from these magnet links:

[Dos Games Collection 2015- Part 1-3 (0 to J)](<magnet:?xt=urn:btih:CBCFAF75AD0A6D59B9E54C96CE9132640919EDBA&dn=DOS%20Games%20Collection%202015%20-%20Part%201-3%20(0%20to%20J)&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.bittor.pw%3A1337%2Fannounce&tr=udp%3A%2F%2Fpublic.popcorn-tracker.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969&tr=udp%3A%2F%2Fopen.demonii.com%3A1337%2Fannounce&tr=udp%3A%2F%2Fglotorrents.pw%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337>)

[Dos Games Collection 2015- Part 2-3 (K to P)](<magnet:?xt=urn:btih:FBD802E92D464CC5BEAAFC8A127B624450380BC4&dn=DOS%20Games%20Collection%202015%20-%20Part%202-3%20(K%20to%20P)&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.bittor.pw%3A1337%2Fannounce&tr=udp%3A%2F%2Fpublic.popcorn-tracker.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969&tr=udp%3A%2F%2Fopen.demonii.com%3A1337%2Fannounce&tr=udp%3A%2F%2Fglotorrents.pw%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337>)

[Dos Games Collection 2015- Part 3-3 (Q to Z)](<magnet:?xt=urn:btih:2C6DB1409ABFD4A6502D6ED4156C1B97A3452F45&dn=DOS%20Games%20Collection%202015%20-%20Part%203-3%20(Q%20to%20Z)&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce&tr=udp%3A%2F%2Ftracker.bittor.pw%3A1337%2Fannounce&tr=udp%3A%2F%2Fpublic.popcorn-tracker.org%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.dler.org%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969&tr=udp%3A%2F%2Fopen.demonii.com%3A1337%2Fannounce&tr=udp%3A%2F%2Fglotorrents.pw%3A6969%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftorrent.gresille.org%3A80%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337>)

`Prepare-BatoceraDos.ps1` extracts each `.7z` game archive into its own `<game name>.pc` folder and prepares a `dosbox.bat` launcher where possible. These folders can be copied to Batocera's DOS games directory, including on a Raspberry Pi 5.

## Requirements

- Windows PowerShell (the `powershell.exe` included with Windows).
- 7-Zip installed, or a path to its command-line executable supplied with `-SevenZipPath`.
- Enough free space for the extracted games. The original archives remain in place, so extraction uses additional disk space.

## Quick start

1. Put your `.7z` files in the `Games` folder beside the script, or supply another folder with `-Source`.
2. Open PowerShell in the folder containing `Prepare-BatoceraDos.ps1`.
3. Preview the work:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Prepare-BatoceraDos.ps1 -WhatIf
   ```

4. Extract and prepare the games:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Prepare-BatoceraDos.ps1
   ```

5. Check `Batocera-DOS\review.txt` for games needing manual setup.
6. Copy the resulting `.pc` folders to Batocera as described below.

`-ExecutionPolicy Bypass` applies to the PowerShell process launched by these commands; it does not permanently change your execution policy.

## Choose your source and destination

Point to the folder containing your archives:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Prepare-BatoceraDos.ps1 -Source "F:\DOS Games"
```

Choose both the source and output folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Prepare-BatoceraDos.ps1 -Source "F:\DOS Games" -Destination "F:\roms\dos"
```

Add `-WhatIf` to either command to preview without extracting files or writing reports. Use quotes around paths containing spaces. Relative paths such as `.\Games` are relative to your current PowerShell directory.

## Arguments

| Argument        | Purpose                                                                                                                             | Default                                                |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `-Source`       | Folder containing `.7z` archives or already extracted game folders.                                                                 | `Games` beside the script.                             |
| `-Destination`  | Folder that will receive the prepared `.pc` folders and reports.                                                                    | `Batocera-DOS` beside the script.                      |
| `-SevenZipPath` | Full path to the 7-Zip command-line executable.                                                                                     | Searches PATH and standard 7-Zip installation folders. |
| `-WhatIf`       | Preview planned operations without creating output.                                                                                 | Off.                                                   |
| `-Overwrite`    | Regenerate launchers instead of preserving `dosbox.bat` files copied from the source. Existing destination games are still skipped. | Off.                                                   |

The source and destination must be different folders. The destination cannot be inside an input game folder.

If 7-Zip is not detected automatically:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Prepare-BatoceraDos.ps1 -Source "F:\DOS Games" -SevenZipPath "C:\Program Files\7-Zip\7z.exe"
```

## What the script processes

- It reads `.7z` archives directly inside `-Source`; it does not search subfolders for more archives.
- Each immediate subfolder of `-Source` is treated as an already extracted game and copied into its own `.pc` folder.
- Other archive types, including `.zip`, are ignored.
- One archive becomes one game folder. An archive containing multiple games is not split into separate games.
- Internal files and subdirectories are preserved.
- Archives and source folders are retained without modification.
- Existing destination folders are skipped, including when `-Overwrite` is supplied.
- Failed extractions are reported, and their temporary files are cleaned up.

## Output layout

For example, `Games\Example Game (1992).7z` produces:

```text
Batocera-DOS/
  Example Game (1992).pc/
    GAME.EXE
    ...other extracted files and folders...
    dosbox.bat
  preparation-report.csv
  review.txt
```

`preparation-report.csv` lists each source, output path, status, selected launcher, and notes. Open it in a text editor or spreadsheet.

`review.txt` lists failed extractions, uncertain launcher choices, missing executables, and paths needing manual DOS short-name handling. Games that extract successfully still receive `.pc` folders even if a launcher cannot be generated.

During a preview, the final prepared count is zero because no games have actually been extracted.

## Copy games to Batocera

Copy the `.pc` folders into:

```text
/userdata/roms/dos
```

From Windows, the usual network location is:

```text
\\BATOCERA\share\roms\dos
```

If necessary, replace `BATOCERA` with your device's hostname or IP address. Copy the individual `.pc` folders so they sit directly inside `roms\dos`. The preparation reports can stay on your Windows PC.

Refresh Batocera's game list after copying. The `.pc` directory layout is documented in the [Batocera DOS guide](https://wiki.batocera.org/systems:dos).

## Review and fix launchers

The script preserves an existing root-level `dosbox.bat` by default. It can also create a wrapper that calls a packaged `dosbox.bat` inside a subfolder. Otherwise, it guesses among `.exe`, `.com`, and `.bat` files while excluding common setup utilities. Multiple candidates are flagged for review.

A generated launcher does not guarantee that the game is ready to play. Some games require installation, CD mounting, command-line arguments, or emulator settings.

To correct a launcher, edit `dosbox.bat` in the output game's `.pc` folder. For a game executable in the root, a basic launcher is:

```bat
@echo off
C:
cd \
GAME.EXE
exit
```

For an executable inside a `GAME` subfolder, add `cd GAME` before `GAME.EXE`. To launch a batch file, use `call START.BAT`. Use the actual filenames from that game. Save launchers as plain ASCII with Windows CRLF line endings.

Paths with long names or unsupported characters are flagged instead of generating a launcher that assumes a DOS short-name alias. Resolve those paths manually for your emulator.

Edit prepared output directly when fixing a game: rerunning the script skips existing destination games. To prepare a fresh copy, choose a new destination folder.

## Troubleshooting

- **7-Zip was not found:** Install 7-Zip or supply `-SevenZipPath`.
- **Running scripts is disabled:** Use the `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` commands above.
- **No archives or game folders found:** Check `-Source`. Only `.7z` files directly in that folder and its immediate game subfolders are processed.
- **Skipping existing output:** The game's `.pc` folder already exists. Use another destination to generate a fresh copy.
- **Extraction failed:** Read `review.txt` or the CSV report, and try opening the source archive in 7-Zip to check it.
- **Game appears but does not start:** Verify `dosbox.bat` and consult the Batocera DOS guide for game-specific installation, disc mounting, and emulator setup.
