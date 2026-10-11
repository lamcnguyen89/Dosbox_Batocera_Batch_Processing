<#
.SYNOPSIS
Extract each .7z archive into its own Batocera DOS game folder.
.DESCRIPTION
Output: Destination\<archive name>.pc\<original game files> and dosbox.bat.
Copy the .pc folders to /userdata/roms/dos (network: \\BATOCERA\share\roms\dos).
This DOS folder format also applies to Raspberry Pi 5. CD mounts, installation,
emulator settings and game-specific configuration may still need manual setup.
Requires 7-Zip for archives. Existing extracted folders are also supported.
Source files are retained. Existing destination games are skipped.
Launcher selection is a heuristic; review.txt lists uncertain/missing launchers.
.EXAMPLE
.\Prepare-BatoceraDos.ps1 -WhatIf
.EXAMPLE
.\Prepare-BatoceraDos.ps1
.EXAMPLE
.\Prepare-BatoceraDos.ps1 -Source .\Games -Destination F:\roms\dos -SevenZipPath 'C:\Program Files\7-Zip\7z.exe'
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Source,
    [string]$Destination,
    [string]$SevenZipPath,
    [switch]$Overwrite # Replace copied dosbox.bat files; never overwrite destination games.
)

$scriptDirectory = $PSScriptRoot
if (-not $scriptDirectory) { $scriptDirectory = (Get-Location).Path }
if (-not $Source) { $Source = Join-Path $scriptDirectory 'Games' }
if (-not $Destination) { $Destination = Join-Path $scriptDirectory 'Batocera-DOS' }
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$sourceItem = Get-Item -LiteralPath $Source
if (-not $sourceItem.PSIsContainer) { throw "Source must be a directory: $Source" }
$Source = $sourceItem.FullName
$Destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
if ($Destination.TrimEnd('\', '/') -ieq $Source.TrimEnd('\', '/')) {
    throw 'Use a separate Destination directory to keep output separate from source games.'
}
$destinationPrefix = $Destination.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
$items = @(Get-ChildItem -LiteralPath $Source -Force | Where-Object {
    ($_.PSIsContainer -or $_.Extension -ieq '.7z') -and
    $_.FullName.TrimEnd('\', '/') -ine $Destination.TrimEnd('\', '/')
} | Sort-Object Name)
if (-not $items.Count) { Write-Host "No .7z archives or game folders found in $Source"; return }

$archives = @($items | Where-Object { -not $_.PSIsContainer })
if ($archives.Count -and -not $WhatIfPreference) {
    if ($SevenZipPath) {
        $SevenZipPath = (Get-Item -LiteralPath $SevenZipPath).FullName
    } else {
        $sevenZip = Get-Command 7z.exe, 7za.exe, 7zz.exe -ErrorAction SilentlyContinue |
            Select-Object -First 1
        if ($sevenZip) { $SevenZipPath = $sevenZip.Source }
        else {
            foreach ($base in @($env:ProgramFiles, [Environment]::GetEnvironmentVariable('ProgramFiles(x86)'))) {
                if ($base) {
                    $candidate = Join-Path $base '7-Zip\7z.exe'
                    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                        $SevenZipPath = $candidate
                        break
                    }
                }
            }
        }
    }
    if (-not $SevenZipPath) {
        throw "7-Zip was not found. Install 7-Zip or pass -SevenZipPath 'C:\path\to\7z.exe'."
    }
}

$skip = '^(setup|install|instal|config|uninst|readme|help|dosbox|patch|update|upgrade|unpack|extract|pkunzip|pkzip|arj|lha|view|manual|catalog|sound|sndsetup|setsound|vesa|univbe|mouse|himem|emm|fix|crack|test|reset)|^demo\d*$'
$review = New-Object 'System.Collections.Generic.List[string]'
$results = New-Object 'System.Collections.Generic.List[object]'

function Get-RelativeGamePath([string]$Root, [string]$Path) {
    $Path.Substring($Root.TrimEnd('\', '/').Length).TrimStart('\', '/').Replace('/', '\')
}

function Write-DosLauncher([string]$Root, [IO.FileInfo]$Executable) {
    $relative = Get-RelativeGamePath $Root $Executable.FullName
    # Do not silently emit a long path that DOSBox would require an 8.3 alias for.
    foreach ($part in ($relative -split '\\')) {
        if ($part -notmatch '^[A-Za-z0-9_!~-]{1,8}(\.[A-Za-z0-9_!~-]{1,3})?$') {
            return $false
        }
    }
    $lines = @('@echo off', 'C:', 'cd \')
    $relativeDirectory = [IO.Path]::GetDirectoryName($relative)
    if ($relativeDirectory) { $lines += "cd $relativeDirectory" }
    if ($Executable.Extension -ieq '.bat') { $lines += "call $($Executable.Name)" }
    else { $lines += $Executable.Name }
    $lines += 'exit'
    [IO.File]::WriteAllText((Join-Path $Root 'dosbox.bat'),
        ($lines -join [Environment]::NewLine) + [Environment]::NewLine, [Text.Encoding]::ASCII)
    return $true
}

function Prepare-Game([string]$Root, [string]$Name) {
    $bat = Join-Path $Root 'dosbox.bat'
    if ((Test-Path -LiteralPath $bat -PathType Leaf) -and -not $Overwrite) {
        return [pscustomobject]@{ Launcher = 'dosbox.bat (preserved)'; Review = '' }
    }
    $files = @(Get-ChildItem -LiteralPath $Root -Recurse -File)
    # Prefer a packaged launcher in a wrapper directory over guessing an EXE.
    $packaged = @($files | Where-Object { $_.Name -ieq 'dosbox.bat' -and $_.FullName -ine $bat })
    if (-not $Overwrite -and $packaged.Count -eq 1) {
        $chosen = $packaged[0]
        $reason = ''
    } else {
        $tokens = @(($Name -replace '\(.*?\)', '' -replace '[^A-Za-z0-9 ]', ' ').ToLower() -split '\s+' |
            Where-Object { $_.Length -ge 3 })
        $ranked = @($files | Where-Object {
            $_.Extension -in @('.exe', '.com', '.bat') -and
            $_.BaseName -notmatch $skip -and $_.Name -ine 'dosbox.bat'
        } | ForEach-Object {
            $score = 0
            foreach ($token in $tokens) {
                if ($token.StartsWith($_.BaseName.ToLower()) -or $_.BaseName.ToLower().StartsWith($token)) {
                    $score += 100
                }
            }
            if ($_.Extension -ieq '.bat') { $score += 20 }
            elseif ($_.Extension -ieq '.exe') { $score += 10 }
            [pscustomobject]@{ File = $_; Score = $score }
        } | Sort-Object @{ Expression = { $_.Score }; Descending = $true },
            @{ Expression = { $_.File.FullName }; Descending = $false })
        if (-not $ranked.Count) {
            return [pscustomobject]@{ Launcher = ''; Review = 'No game executable found; add dosbox.bat manually (installation or disc mounting may be required).' }
        }
        $chosen = $ranked[0].File
        $reason = ''
        if ($ranked.Count -gt 1) {
            $reason = 'Guessed launcher; verify it. Candidates: ' +
                (($ranked | ForEach-Object { Get-RelativeGamePath $Root $_.File.FullName }) -join ', ')
        }
    }
    $relative = Get-RelativeGamePath $Root $chosen.FullName
    if (-not (Write-DosLauncher $Root $chosen)) {
        return [pscustomobject]@{ Launcher = ''; Review = "Launcher path needs DOS 8.3 names; add dosbox.bat manually: $relative" }
    }
    return [pscustomobject]@{ Launcher = $relative; Review = $reason }
}

$priorResults = @{}
$reportPath = Join-Path $Destination 'preparation-report.csv'
if (Test-Path -LiteralPath $reportPath -PathType Leaf) {
    foreach ($row in @(Import-Csv -LiteralPath $reportPath)) { $priorResults[$row.Output] = $row }
}
foreach ($folder in @($items | Where-Object { $_.PSIsContainer })) {
    $folderPrefix = $folder.FullName.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if ($Destination.StartsWith($folderPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Destination cannot be inside an input game folder: $($folder.FullName)"
    }
}
$prepared = 0
$failed = 0
foreach ($item in $items) {
    $name = if ($item.PSIsContainer) { $item.Name } else { $item.BaseName }
    $name = $name -replace '\.(pc|dos)$', ''
    $target = Join-Path $Destination "$name.pc"
    if (Test-Path -LiteralPath $target) {
        Write-Host "Skipping existing output: $target"
        $notes = 'Existing output retained.'
        $launcher = ''
        if ($priorResults.ContainsKey($target)) {
            $notes = $priorResults[$target].Notes
            $launcher = $priorResults[$target].Launcher
            if ($notes -and $notes -ne 'Existing output retained.') { $review.Add("$name.pc : $notes") }
        }
        $results.Add([pscustomobject]@{ Source = $item.FullName; Output = $target; Status = 'Skipped'; Launcher = $launcher; Notes = $notes })
        continue
    }
    if (-not $PSCmdlet.ShouldProcess($target, "Extract/copy '$($item.Name)' and prepare DOS launcher")) { continue }
    [IO.Directory]::CreateDirectory($Destination) | Out-Null
    $staging = Join-Path $Destination ('.prepare-' + [guid]::NewGuid().ToString('N'))
    try {
        [IO.Directory]::CreateDirectory($staging) | Out-Null
        if ($item.PSIsContainer) {
            Get-ChildItem -LiteralPath $item.FullName -Force | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination $staging -Recurse -Force
            }
        } else {
            # x preserves subdirectories; e would flatten and mix up game files.
            $global:LASTEXITCODE = 0
            $extractLog = @(& $SevenZipPath x $item.FullName "-o$staging" -y -bd -bso1 -bsp0 2>&1)
            if ($LASTEXITCODE -ne 0) {
                throw ("7-Zip exit code {0}: {1}" -f $LASTEXITCODE, ($extractLog -join [Environment]::NewLine))
            }
        }
        if (-not @(Get-ChildItem -LiteralPath $staging -Force).Count) { throw 'Archive/game folder is empty.' }
        $launch = Prepare-Game $staging $name
        # Only publish successful extractions. Games needing review still get .pc folders.
        Move-Item -LiteralPath $staging -Destination $target
        $prepared++
        if ($launch.Review) { $review.Add("$name.pc : $($launch.Review)") }
        $results.Add([pscustomobject]@{ Source = $item.FullName; Output = $target; Status = 'Prepared'; Launcher = $launch.Launcher; Notes = $launch.Review })
        Write-Host "$name.pc -> $($launch.Launcher)"
    } catch {
        $failed++
        $review.Add("$name.pc : FAILED: $($_.Exception.Message)")
        $results.Add([pscustomobject]@{ Source = $item.FullName; Output = $target; Status = 'Failed'; Launcher = ''; Notes = $_.Exception.Message })
        Write-Warning "$($item.Name): $($_.Exception.Message)"
    } finally {
        if (Test-Path -LiteralPath $staging) {
            $resolvedStaging = (Get-Item -LiteralPath $staging).FullName
            if (-not $resolvedStaging.StartsWith($destinationPrefix, [StringComparison]::OrdinalIgnoreCase) -or
                [IO.Path]::GetFileName($resolvedStaging) -notmatch '^\.prepare-[a-f0-9]{32}$') {
                throw "Refusing to clean up unexpected path: $resolvedStaging"
            }
            Remove-Item -LiteralPath $resolvedStaging -Recurse -Force
        }
    }
}
if (-not $WhatIfPreference -and $results.Count -and $PSCmdlet.ShouldProcess($Destination, 'Write preparation reports')) {
    [IO.Directory]::CreateDirectory($Destination) | Out-Null
    $results | Export-Csv -LiteralPath (Join-Path $Destination 'preparation-report.csv') -NoTypeInformation -Encoding UTF8
    $review | Set-Content -LiteralPath (Join-Path $Destination 'review.txt') -Encoding UTF8
}
Write-Host "$prepared game(s) prepared; $failed failed; $($review.Count) need review. Output: $Destination"
