# DTSpotifyBlock - Spotify Ad Blocker & Patcher
# https://github.com/DT-Deville/DTSpotifyBlock
# Requires: Windows 10+, PowerShell 5+

[CmdletBinding()]
param
(

    [Parameter(HelpMessage = "Pin a specific Spotify version to install.")]
    [Alias("v")]
    [string]$version,

    [Parameter(HelpMessage = 'Custom path to Spotify installation directory. Default is %APPDATA%\Spotify.')]
    [string]$SpotifyPath,

    [Parameter(HelpMessage = "Use the GitHub Pages mirror for downloading patch files.")]
    [Alias("m")]
    [switch]$mirror,

    [Parameter(HelpMessage = "Enable DevTools inside Spotify.")]
    [Alias("dev")]
    [switch]$devtools,

    [Parameter(HelpMessage = "Remove podcasts, episodes, and audiobooks from the home feed.")]
    [switch]$podcasts_off,

    [Parameter(HelpMessage = "Remove promotional ad-like blocks from the home feed.")]
    [switch]$adsections_off,

    [Parameter(HelpMessage = 'Disable canvas from homepage')]
    [switch]$canvashome_off,
    
    [Parameter(HelpMessage = 'Do not disable podcasts/episodes/audiobooks from homepage.')]
    [switch]$podcasts_on,
    
    [Parameter(HelpMessage = "Prevent Spotify from updating itself automatically.")]
    [switch]$block_update_on,
    
    [Parameter(HelpMessage = "Allow Spotify to update automatically.")]
    [switch]$block_update_off,
    
    [Parameter(HelpMessage = 'Change limit for clearing audio cache.')]
    [Alias('cl')]
    [int]$cache_limit,
    
    [Parameter(HelpMessage = "Auto-remove Microsoft Store version of Spotify if detected.")]
    [switch]$confirm_uninstall_ms_spoti,
    
    [Parameter(HelpMessage = 'Overwrite outdated or unsupported version of Spotify with the recommended version.')]
    [Alias('sp-over')]
    [switch]$confirm_spoti_recomended_over,
    
    [Parameter(HelpMessage = 'Uninstall outdated or unsupported version of Spotify and install the recommended version.')]
    [Alias('sp-uninstall')]
    [switch]$confirm_spoti_recomended_uninstall,
    
    [Parameter(HelpMessage = "Skip ad-blocking patches (use for Spotify Premium accounts).")]
    [switch]$premium,

    [Parameter(HelpMessage = "Stop Spotify from launching on Windows startup.")]
    [switch]$DisableStartup,
    
    [Parameter(HelpMessage = "Automatically open Spotify when patching finishes.")]
    [switch]$start_spoti,
    
    [Parameter(HelpMessage = 'Experimental features operated by Spotify.')]
    [switch]$exp_spotify,

    [Parameter(HelpMessage = 'Enable top search bar.')]
    [switch]$topsearchbar,

    [Parameter(HelpMessage = 'Enable new fullscreen mode (Experimental)')]
    [switch]$newFullscreenMode,

    [Parameter(HelpMessage = 'disable subfeed filter chips on home.')]
    [switch]$homesub_off,
    
    [Parameter(HelpMessage = 'Do not hide the icon of collaborations in playlists.')]
    [switch]$hide_col_icon_off,
    
    [Parameter(HelpMessage = 'Disable new right sidebar.')]
    [switch]$rightsidebar_off,

    [Parameter(HelpMessage = 'it`s killing the heart icon, you`re able to save and choose the destination for any song, playlist, or podcast')]
    [switch]$plus,

    [Parameter(HelpMessage = 'Enable funny progress bar.')]
    [switch]$funnyprogressBar,

    [Parameter(HelpMessage = 'New theme activated (new right and left sidebar, some cover change)')]
    [switch]$new_theme,

    [Parameter(HelpMessage = 'Enable right sidebar coloring to match cover color)')]
    [switch]$rightsidebarcolor,
    
    [Parameter(HelpMessage = 'Returns old lyrics')]
    [switch]$old_lyrics,

    [Parameter(HelpMessage = 'Disable native lyrics')]
    [switch]$lyrics_block,

    [Parameter(HelpMessage = 'Do not create desktop shortcut.')]
    [switch]$no_shortcut,

    [Parameter(HelpMessage = 'Static color for lyrics.')]
    [ArgumentCompleter({ param($cmd, $param, $wordToComplete)
            [array] $validValues = @('blue', 'blueberry', 'discord', 'drot', 'default', 'forest', 'fresh', 'github', 'lavender', 'orange', 'postlight', 'pumpkin', 'purple', 'radium', 'relish', 'red', 'sandbar', 'spotify', 'spotify#2', 'strawberry', 'turquoise', 'yellow', 'zing', 'pinkle', 'krux', 'royal', 'oceano')
            $validValues -like "*$wordToComplete*"
        })]
    [string]$lyrics_stat,

    [Parameter(HelpMessage = 'Accumulation of track listening history with Goofy.')]
    [string]$urlform_goofy = $null,

    [Parameter(HelpMessage = 'Accumulation of track listening history with Goofy.')]
    [string]$idbox_goofy = $null,

    [Parameter(HelpMessage = 'Error log ru string.')]
    [switch]$err_ru,
    
    [Parameter(HelpMessage = 'Select the desired language to use for installation. Default is the detected system language.')]
    [Alias('l')]
    [string]$language,

    [Parameter(HelpMessage = 'Fully automated install with zero prompts.')]
    [switch]$silent,

    [Parameter(HelpMessage = 'Check if Spotify is already patched, without making any changes.')]
    [switch]$check,

    [Parameter(HelpMessage = 'Clear Spotify cache files to free up space and fix slowdowns.')]
    [switch]$clean_cache,

    [Parameter(HelpMessage = 'Restore original Spotify files from backup without reinstalling.')]
    [switch]$backup_restore,

    [Parameter(HelpMessage = 'Save a full install log to your Desktop.')]
    [switch]$log,

    [Parameter(HelpMessage = 'Uninstall DTSpotifyBlock AND wipe all Spotify cache and preferences for a clean slate.')]
    [switch]$uninstall_clean
)

# Ignore errors from `Stop-Process`
$PSDefaultParameterValues['Stop-Process:ErrorAction'] = [System.Management.Automation.ActionPreference]::SilentlyContinue

# ── Logging ──────────────────────────────────────────────────────────────────
$logLines = [System.Collections.Generic.List[string]]::new()
$logPath  = Join-Path ([Environment]::GetFolderPath('Desktop')) "DTSpotifyBlock_log.txt"

function Write-Log {
    param([string]$Message, [string]$Color = 'White')
    $ts = Get-Date -Format 'HH:mm:ss'
    $logLines.Add("[$ts] $Message")
    Write-Host $Message -ForegroundColor $Color
}

function Save-Log {
    if ($log) {
        $header = "DTSpotifyBlock Install Log — $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $divider = "-" * 60
        ($header, $divider) + $logLines | Set-Content -Path $logPath -Encoding UTF8
        Write-Host "`nLog saved to: $logPath" -ForegroundColor Cyan
    }
}

# ── Progress Bar ─────────────────────────────────────────────────────────────
$script:currentStep = 0
$script:totalSteps  = 7

function Show-Step {
    param([string]$Message)
    $script:currentStep++
    $pct   = [int](($script:currentStep / $script:totalSteps) * 100)
    $filled = [int]($pct / 5)
    $bar   = ('#' * $filled).PadRight(20)
    Write-Host ""
    Write-Host "  [$bar] $pct% " -ForegroundColor Cyan -NoNewline
    Write-Host "Step $script:currentStep/$script:totalSteps — $Message" -ForegroundColor White
    Write-Host ""
    if ($log) { $logLines.Add("[STEP $script:currentStep/$script:totalSteps] $Message") }
}

# ── Colored Summary ───────────────────────────────────────────────────────────
$script:summaryItems = [System.Collections.Generic.List[string]]::new()

function Add-Summary {
    param([string]$Item)
    $script:summaryItems.Add($Item)
}

function Show-Summary {
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────┐" -ForegroundColor Green
    Write-Host "  │     DTSpotifyBlock — Applied         │" -ForegroundColor Green
    Write-Host "  ├─────────────────────────────────────┤" -ForegroundColor Green
    foreach ($item in $script:summaryItems) {
        Write-Host "  │  ✔ $($item.PadRight(33))│" -ForegroundColor Green
    }
    Write-Host "  └─────────────────────────────────────┘" -ForegroundColor Green
    Write-Host ""
}

# ── Network Diagnostics ───────────────────────────────────────────────────────
function Test-Network {
    param([string]$Url)
    try {
        $req = [System.Net.WebRequest]::Create($Url)
        $req.Timeout = 8000
        $res = $req.GetResponse()
        $res.Close()
        return $true
    } catch {
        $msg = $_.Exception.Message
        if ($msg -match "403")         { Write-Log "  ERROR: Server returned 403 — URL may be outdated." Red }
        elseif ($msg -match "SSL|TLS") { Write-Log "  ERROR: SSL/TLS handshake failed — try running as Administrator." Red }
        elseif ($msg -match "timed out|timeout") { Write-Log "  ERROR: Connection timed out — check your internet." Red }
        elseif ($msg -match "resolve|DNS")        { Write-Log "  ERROR: DNS failure — no internet connection detected." Red }
        else { Write-Log "  ERROR: $msg" Red }
        return $false
    }
}

# ── -check flag ───────────────────────────────────────────────────────────────
function Invoke-CheckPatch {
    $spExe = Join-Path $env:APPDATA 'Spotify\Spotify.exe'
    $spaBak = Join-Path $env:APPDATA 'Spotify\Apps\xpui.bak'
    $spa    = Join-Path $env:APPDATA 'Spotify\Apps\xpui.spa'

    Write-Host ""
    Write-Host "  DTSpotifyBlock — Patch Status Check" -ForegroundColor Cyan
    Write-Host "  ────────────────────────────────────" -ForegroundColor DarkGray

    if (-not (Test-Path $spExe)) {
        Write-Host "  ✘ Spotify is not installed." -ForegroundColor Red
        return
    }

    $ver = (Get-Item $spExe).VersionInfo.FileVersion
    Write-Host "  Spotify version : $ver" -ForegroundColor White

    if (Test-Path $spaBak) {
        # Read xpui.spa and check for patch marker
        Add-Type -Assembly 'System.IO.Compression.FileSystem'
        try {
            $zip  = [System.IO.Compression.ZipFile]::OpenRead($spa)
            $entry = $zip.GetEntry('xpui.js')
            $reader = New-Object System.IO.StreamReader($entry.Open())
            $content = $reader.ReadToEnd()
            $reader.Close(); $zip.Dispose()

            if ($content -match 'patched_by_dtspotifyblock') {
                Write-Host "  ✔ DTSpotifyBlock patch is ACTIVE" -ForegroundColor Green
                Write-Host "  ✔ Backup (xpui.bak) found" -ForegroundColor Green
            } else {
                Write-Host "  ✘ xpui.bak exists but patch marker not found — may be incomplete." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "  ? Could not read xpui.spa — $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✘ Not patched — no xpui.bak found." -ForegroundColor Red
    }
    Write-Host ""
}

# ── -clean_cache flag ─────────────────────────────────────────────────────────
function Invoke-CleanCache {
    $cachePath = Join-Path $env:LOCALAPPDATA 'Spotify\Storage'
    $dataPath  = Join-Path $env:LOCALAPPDATA 'Spotify\Data'

    Write-Host ""
    Write-Host "  Cleaning Spotify cache..." -ForegroundColor Cyan

    $freed = 0
    foreach ($p in @($cachePath, $dataPath)) {
        if (Test-Path $p) {
            $size = (Get-ChildItem $p -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
            $freed += $size
        }
    }

    $mb = [math]::Round($freed / 1MB, 1)
    Write-Host "  ✔ Cache cleared — freed approx. $mb MB" -ForegroundColor Green
    Write-Host ""
}

# ── -backup_restore flag ──────────────────────────────────────────────────────
function Invoke-BackupRestore {
    $spaBak     = Join-Path $env:APPDATA 'Spotify\Apps\xpui.bak'
    $spa        = Join-Path $env:APPDATA 'Spotify\Apps\xpui.spa'
    $dllBak     = Join-Path $env:APPDATA 'Spotify\Spotify.dll.bak'
    $dll        = Join-Path $env:APPDATA 'Spotify\Spotify.dll'
    $exeBak     = Join-Path $env:APPDATA 'Spotify\Spotify.bak'
    $exe        = Join-Path $env:APPDATA 'Spotify\Spotify.exe'
    $elfBak     = Join-Path $env:APPDATA 'Spotify\chrome_elf.dll.bak'
    $elf        = Join-Path $env:APPDATA 'Spotify\chrome_elf.dll'

    Write-Host ""
    Write-Host "  Restoring from backup..." -ForegroundColor Cyan

    if (-not (Test-Path $spaBak)) {
        Write-Host "  ✘ No backup found (xpui.bak missing). Cannot restore." -ForegroundColor Red
        Write-Host "  Tip: Reinstall Spotify to get a clean copy." -ForegroundColor Yellow
        Write-Host ""
        return
    }

    Stop-SpotifyProcess

    $restored = 0
    foreach ($pair in @(($spaBak,$spa),($dllBak,$dll),($exeBak,$exe),($elfBak,$elf))) {
        if (Test-Path $pair[0]) {
            Copy-Item $pair[0] $pair[1] -Force -ErrorAction SilentlyContinue
            $restored++
        }
    }

    Write-Host "  ✔ Restored $restored file(s) from backup." -ForegroundColor Green
    Write-Host "  Spotify has been reverted to its original state." -ForegroundColor White
    Write-Host ""
}

# ── -uninstall_clean flag ─────────────────────────────────────────────────────
function Invoke-UninstallClean {
    $spDir     = Join-Path $env:APPDATA 'Spotify'
    $cacheDir  = Join-Path $env:LOCALAPPDATA 'Spotify'
    $spExe     = Join-Path $spDir 'Spotify.exe'

    Write-Host ""
    Write-Host "  DTSpotifyBlock Clean Uninstall" -ForegroundColor Cyan
    Write-Host "  This will remove the patch AND wipe all Spotify data." -ForegroundColor Yellow
    Write-Host "  Your playlists and account are stored in the cloud — they will NOT be lost." -ForegroundColor DarkGray
    Write-Host ""

    $confirm = Read-Host "  Continue? [Y/N]"
    if ($confirm -notmatch '^y$') { Write-Host "  Cancelled." -ForegroundColor Yellow; return }

    Stop-SpotifyProcess
    Start-Sleep -Milliseconds 800

    if (Test-Path $spExe) {
        cmd /c $spExe /UNINSTALL /SILENT
        Start-Sleep -Seconds 3
    }

    foreach ($p in @($spDir, $cacheDir)) {
        if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
    }

    Write-Host "  ✔ Spotify and DTSpotifyBlock fully removed." -ForegroundColor Green
    Write-Host "  ✔ Cache and preferences wiped." -ForegroundColor Green
    Write-Host ""
}

function Resolve-LangCode {
    
    # Normalizes and confirms support of the selected language.
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [string]$LanguageCode
    )
    
    $supportLanguages = @(
        'be', 'bn', 'cs', 'de', 'el', 'en', 'es', 'fa', 'fi', 'fil', 'fr', 'hi', 'hu', 
        'id', 'it', 'ja', 'ka', 'ko', 'lv', 'pl', 'pt', 'ro', 'ru', 'sk', 'sr', 'sr-Latn',
        'sv', 'ta', 'tr', 'ua', 'vi', 'zh', 'zh-TW'
    )
    
    # Trim the language code down to two letter code.
    switch -Regex ($LanguageCode) {
        '^be' {
            $returnCode = 'be'
            break
        }
        '^bn' {
            $returnCode = 'bn'
            break
        }
        '^cs' {
            $returnCode = 'cs'
            break
        }
        '^de' {
            $returnCode = 'de'
            break
        }
        '^el' {
            $returnCode = 'el'
            break
        }
        '^en' {
            $returnCode = 'en'
            break
        }
        '^es' {
            $returnCode = 'es'
            break
        }
        '^fa' {
            $returnCode = 'fa'
            break
        }
        '^fi$' {
            $returnCode = 'fi'
            break
        }
        '^fil' {
            $returnCode = 'fil'
            break
        }
        '^fr' {
            $returnCode = 'fr'
            break
        }
        '^hi' {
            $returnCode = 'hi'
            break
        }
        '^hu' {
            $returnCode = 'hu'
            break
        }
        '^id' {
            $returnCode = 'id'
            break
        }
        '^it' {
            $returnCode = 'it'
            break
        }
        '^ja' {
            $returnCode = 'ja'
            break
        }
        '^ka' {
            $returnCode = 'ka'
            break
        }
        '^ko' {
            $returnCode = 'ko'
            break
        }
        '^lv' {
            $returnCode = 'lv'
            break
        }
        '^pl' {
            $returnCode = 'pl'
            break
        }
        '^pt' {
            $returnCode = 'pt'
            break
        }
        '^ro' {
            $returnCode = 'ro'
            break
        }
        '^(ru|py)' {
            $returnCode = 'ru'
            break
        }
        '^sk' {
            $returnCode = 'sk'
            break
        }
        '^(sr|sr-Cyrl)$' {
            $returnCode = 'sr'
            break
        }
        '^sr-Latn' {
            $returnCode = 'sr-Latn'
            break
        }
        '^sv' {
            $returnCode = 'sv'
            break
        }
        '^ta' {
            $returnCode = 'ta'
            break
        }
        '^tr' {
            $returnCode = 'tr'
            break
        }
        '^ua' {
            $returnCode = 'ua'
            break
        }
        '^vi' {
            $returnCode = 'vi'
            break
        }
        '^(zh|zh-CN)$' {
            $returnCode = 'zh'
            break
        }
        '^zh-TW' {
            $returnCode = 'zh-TW'
            break
        }
        Default {
            $returnCode = $PSUICulture
            $long_code = $true
            break
        }
    }
    
    # Checking the long language code
    if ($long_code -and $returnCode -NotIn $supportLanguages) {
        if ($returnCode -match '-') {
            $intermediateCode = $returnCode.Substring(0, $returnCode.LastIndexOf('-'))
            
            if ($intermediateCode -in $supportLanguages) {
                $returnCode = $intermediateCode
            }
            else {
                $returnCode = $returnCode -split "-" | Select-Object -First 1
            }
        }
    }

    if ($returnCode -NotIn $supportLanguages) {

        $returnCode = 'en'
    }
    return $returnCode 
}   

$spInstallPath = Join-Path $env:APPDATA 'Spotify'
$spInstallPathLocal = Join-Path $env:LOCALAPPDATA 'Spotify'

# Use custom install path if -SpotifyPath was provided
if ($SpotifyPath) {
    $spInstallPath = $SpotifyPath
}
$spExeFile = Join-Path $spInstallPath 'Spotify.exe'
$spDllFile = Join-Path $spInstallPath 'Spotify.dll' 
$chrome_elf = Join-Path $spInstallPath 'chrome_elf.dll'
$exe_bak = Join-Path $spInstallPath 'Spotify.bak'
$dll_bak = Join-Path $spInstallPath 'Spotify.dll.bak'
$chrome_elf_bak = Join-Path $spInstallPath 'chrome_elf.dll.bak'
$spUninstaller = Join-Path ([System.IO.Path]::GetTempPath()) 'SpotifyUninstall.exe'
$start_menu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Spotify.lnk'

$needsInstall = $false

# Verify PowerShell version compatibility
$psv = $PSVersionTable.PSVersion.major
if ($psv -ge 7) {
    Import-Module Appx -UseWindowsPowerShell -WarningAction:SilentlyContinue
}

# Enable TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12;

function Exit-WithMessage {
    param(
        [string]$Message = ($lang).StopScript
    )

    Write-Host $Message

    switch ($Host.Name) {
        "Windows PowerShell ISE Host" {
            pause
            break
        }
        default {
            Write-Host ($lang).PressAnyKey
            [void][System.Console]::ReadKey($true)
            break
        }
    }
    Exit
}
function Get-BaseUrl {
    param (
        [Alias("e")]
        [string]$endlink
    )

    return "https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/main" + $endlink
}

function Import-LangPack($clg) {

    $ProgressPreference = 'SilentlyContinue'
    
    try {
        $response = (iwr -Uri (Get-BaseUrl -e "/lang/$clg.ps1") -UseBasicParsing).Content
        Invoke-Expression $response
    }
    catch {
        Write-Host "Error loading $clg language"
        Pause
        Exit
    }
}

# Set language code for script.
$selectedLang = Resolve-LangCode -LanguageCode $Language

$lang = Import-LangPack -clg $selectedLang

Write-Host ($lang).Welcome
Write-Host

# ── Handle single-action flags immediately ────────────────────────────────────

if ($check) {
    Invoke-CheckPatch
    exit
}

if ($clean_cache) {
    Invoke-CleanCache
    Save-Log
    exit
}

if ($backup_restore) {
    Invoke-BackupRestore
    Save-Log
    exit
}

if ($uninstall_clean) {
    Invoke-UninstallClean
    Save-Log
    exit
}

# ── Silent mode: auto-answer all prompts ──────────────────────────────────────
if ($silent) {
    $podcasts_off                      = $true
    $block_update_on                   = $true
    $confirm_uninstall_ms_spoti        = $true
    $confirm_spoti_recomended_over     = $true
}

# ── Version checker — notify if newer DTSpotifyBlock available ────────────────
try {
    $ProgressPreference = 'SilentlyContinue'
    $latestInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/DT-Deville/DTSpotifyBlock/releases/latest" -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($latestInfo -and $latestInfo.tag_name) {
        Write-Host "  Latest DTSpotifyBlock release: " -NoNewline -ForegroundColor DarkGray
        Write-Host $latestInfo.tag_name -ForegroundColor Cyan
        Write-Host ""
    }
} catch { }

# Detect Windows version
$os = Get-CimInstance -ClassName "Win32_OperatingSystem" -ErrorAction SilentlyContinue
if ($os) {
    $osCaption = $os.Caption
}
else {
    $osCaption = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
}
$pattern = "\bWindows (7|8(\.1)?|10|11|12)\b"
$reg = [regex]::Matches($osCaption, $pattern)
$win_os = $reg.Value

$win12 = $win_os -match "\windows 12\b"
$win11 = $win_os -match "\windows 11\b"
$win10 = $win_os -match "\windows 10\b"
$win8_1 = $win_os -match "\windows 8.1\b"
$win8 = $win_os -match "\windows 8\b"
$win7 = $win_os -match "\windows 7\b"

$match_v = "^\d+\.\d+\.\d+\.\d+\.g[0-9a-f]{8}-\d+$"
if ($version) {
    if ($version -match $match_v) {
        $targetVerFull = $version
    }
    else {      
        Write-Warning "Invalid $($version) format. Example: 1.2.13.661.ga588f749-4064"
        Write-Host
    }
}

$isLegacyOS = $win7 -or $win8 -or $win8_1

# Last supported version for Win 7/8/8.1 
$legacyVerFull = "1.2.5.1006.g22820f93-1078"

if (!($version -and $version -match $match_v)) {
    if ($isLegacyOS) { 
        $targetVerFull = $legacyVerFull
    }
    else {  
        # Target version for Win 10 and above 
        $targetVerFull = "1.2.85.513.g45f09625-0"
    }
}
else {
    if ($isLegacyOS) {
        $legacyVerMax = "1.2.5.1006"
        if ([version]($targetVerFull -split ".g")[0] -gt [version]$legacyVerMax) { 

            Write-Warning ("Version {0} is only supported on Windows 10 and above" -f ($targetVerFull -split ".g")[0])   
            Write-Warning ("The recommended version has been automatically changed to {0}, the latest supported version for Windows 7-8.1" -f $legacyVerMax)
            Write-Host
            $targetVerFull = $legacyVerFull
        }
    }
}
$targetVer = ($targetVerFull -split ".g")[0]


function Get {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [int]$MaxRetries = 3,
        [int]$RetrySeconds = 3,
        [string]$OutputPath
    )

    $params = @{
        Uri        = $Url
        TimeoutSec = 15
    }

    if ($OutputPath) {
        $params['OutFile'] = $OutputPath
    }

    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            $response = Invoke-RestMethod @params
            return $response
        }
        catch {
            Write-Warning "Attempt $($i+1) of $MaxRetries failed: $_"
            if ($i -lt $MaxRetries - 1) {
                Start-Sleep -Seconds $RetrySeconds
            }
        }
    }

    Write-Host
    Write-Host "ERROR: " -ForegroundColor Red -NoNewline; Write-Host "Failed to retrieve data from $Url" -ForegroundColor White
    Write-Host
    return $null
}


function Show-InvalidInput {

    Write-Host ($lang).Incorrect"" -ForegroundColor Red -NoNewline
    Write-Host ($lang).Incorrect2"" -NoNewline
    Start-Sleep -Milliseconds 1000
    Write-Host "3" -NoNewline 
    Start-Sleep -Milliseconds 1000
    Write-Host " 2" -NoNewline
    Start-Sleep -Milliseconds 1000
    Write-Host " 1"
    Start-Sleep -Milliseconds 1000     
    Clear-Host
} 

function Remove-UpdateLock {
    $blockFileUpdate = Join-Path $env:LOCALAPPDATA 'Spotify\Update'

    if (Test-Path $blockFileUpdate -PathType Container) {
        $folderUpdateAccess = Get-Acl $blockFileUpdate
        $hasDenyAccessRule = $false
        
        foreach ($accessRule in $folderUpdateAccess.Access) {
            if ($accessRule.AccessControlType -eq 'Deny') {
                $hasDenyAccessRule = $true
                $folderUpdateAccess.RemoveAccessRule($accessRule)
            }
        }
        
        if ($hasDenyAccessRule) {
            Set-Acl $blockFileUpdate $folderUpdateAccess
        }
    }
}
function Format-String {
    param(
        [string] $template,
        [object[]] $arguments
    )
    
    $result = $template
    for ($i = 0; $i -lt $arguments.Length; $i++) {
        $placeholder = "{${i}}"
        $value = $arguments[$i]
        $result = $result -replace [regex]::Escape($placeholder), $value
    }
    
    return $result
}

function Invoke-SpotifyDownload([string]$DownloadFolder) {

    $webClient = New-Object -TypeName System.Net.WebClient

    Import-Module BitsTransfer
        
    $maxX86Version = [Version]"1.2.53"
    $versionParts = $targetVerFull -split '\.'
    $short = [Version]"$($versionParts[0]).$($versionParts[1]).$($versionParts[2])"
    $arch = if ($short -le $maxX86Version) { "win32-x86" } else { "win32-x86_64" }

    $web_Url = "https://upgrade.scdn.co/upgrade/client/$arch/spotify_installer-$targetVerFull.exe"
    $web_Url_fallback = "https://download.scdn.co/SpotifySetup.exe"
    $local_Url = Join-Path $DownloadFolder 'SpotifySetup.exe'
    $web_name_file = "SpotifySetup.exe"

    # Auto-fallback to direct Spotify download if versioned URL returns 403
    try {
        $stcheck = (curl.exe -Is -w "%{http_code}" -o NUL -k $web_Url --retry 1 --ssl-no-revoke --max-time 10 2>$null) | Select-Object -Last 1
        if ($stcheck.trim() -ne "200") {
            Write-Host "Note: Versioned installer returned HTTP $($stcheck.trim()), using latest Spotify installer instead..." -ForegroundColor Yellow
            $web_Url = $web_Url_fallback
        }
    } catch { $web_Url = $web_Url_fallback }

    try { if (curl.exe -V) { $hasCurl = $true } }
    catch { $hasCurl = $false }
    
    try { 
        if ($hasCurl) {
            $stcode = curl.exe -Is -w "%{http_code} \n" -o NUL -k $web_Url --retry 2 --ssl-no-revoke
            if ($stcode.trim() -ne "200") {
                Write-Host "Curl error code: $stcode"; throw
            }
            curl.exe -q -k $web_Url -o $local_Url --progress-bar --retry 3 --ssl-no-revoke
            return
        }
        if (!($hasCurl ) -and $null -ne (Get-Module -Name BitsTransfer -ListAvailable)) {
            $ProgressPreference = 'Continue'
            Start-BitsTransfer -Source  $web_Url -Destination $local_Url  -DisplayName ($lang).Download5 -Description "$targetVer "
            return
        }
        if (!($hasCurl ) -and $null -eq (Get-Module -Name BitsTransfer -ListAvailable)) {
            $webClient.DownloadFile($web_Url, $local_Url) 
            return
        }
    }

    catch {
        Write-Host
        Write-Host ($lang).Download $web_name_file -ForegroundColor RED
        $Error[0].Exception
        Write-Host
        Write-Host ($lang).Download2`n

        Start-Sleep -Milliseconds 5000 
        try { 

            if ($hasCurl) {
                $stcode = curl.exe -Is -w "%{http_code} \n" -o NUL -k $web_Url --retry 2 --ssl-no-revoke
                if ($stcode.trim() -ne "200") {
                    Write-Host "Curl error code: $stcode"; throw
                }
                curl.exe -q -k $web_Url -o $local_Url --progress-bar --retry 3 --ssl-no-revoke
                return
            }
            if (!($hasCurl ) -and $null -ne (Get-Module -Name BitsTransfer -ListAvailable) -and !($hasCurl )) {
                Start-BitsTransfer -Source  $web_Url -Destination $local_Url  -DisplayName ($lang).Download5 -Description "$targetVer "
                return
            }
            if (!($hasCurl ) -and $null -eq (Get-Module -Name BitsTransfer -ListAvailable) -and !($hasCurl )) {
                $webClient.DownloadFile($web_Url, $local_Url) 
                return
            }
        }
        
        catch {
            Write-Host ($lang).Download3 -ForegroundColor RED
            $Error[0].Exception
            Write-Host
            Write-Host ($lang).Download4`n

            if ($DownloadFolder -and (Test-Path $DownloadFolder)) {
                Start-Sleep -Milliseconds 200
                Remove-Item -Recurse -LiteralPath $DownloadFolder -ErrorAction SilentlyContinue
            }
            Exit-WithMessage
        }
    }
} 

function Clear-WorkDir {
    param(
        [string]$Directory,
        [int]$DelayMs = 200
    )
    if ($Directory -and (Test-Path $Directory)) {
        Start-Sleep -Milliseconds $DelayMs
        Remove-Item -Recurse -LiteralPath $Directory -ErrorAction SilentlyContinue -Force
    }
}

function Get-DesktopPath {

    # If the default Dekstop folder does not exist, then try to find it through the registry.
    $ErrorActionPreference = 'SilentlyContinue' 
    if (Test-Path "$env:USERPROFILE\Desktop") {  
        $desktopPath = "$env:USERPROFILE\Desktop"  
    }

    $regedit_desktop_folder = Get-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\"
    $regedit_desktop = $regedit_desktop_folder.'{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}'
 
    if (!(Test-Path "$env:USERPROFILE\Desktop")) {
        $desktopPath = $regedit_desktop
    }
    return $desktopPath
}

function Stop-SpotifyProcess {
    param (
        [int]$maxAttempts = 8
    )

    # Force kill via taskkill first (releases file locks faster)
    $null = & taskkill /F /IM Spotify.exe /T 2>$null
    $null = & taskkill /F /IM SpotifyWebHelper.exe /T 2>$null
    Start-Sleep -Milliseconds 800

    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        $allProcesses = Get-Process -ErrorAction SilentlyContinue

        $spotifyProcesses = $allProcesses | Where-Object { $_.ProcessName -like "*spotify*" }

        if ($spotifyProcesses) {
            foreach ($process in $spotifyProcesses) {
                try {
                    Stop-Process -Id $process.Id -Force
                }
                catch {
                    # Ignore NoSuchProcess exception
                }
            }
            Start-Sleep -Seconds 2
        }
        else {
            break
        }
    }

    if ($attempt -gt $maxAttempts) {
        Write-Host "The maximum number of attempts to terminate a process has been reached."
    }
}


Show-Step "Checking environment"
Stop-SpotifyProcess

# Remove Spotify Windows Store If Any
if ($win10 -or $win11 -or $win8_1 -or $win8 -or $win12) {

    if (Get-AppxPackage -Name SpotifyAB.SpotifyMusic) {
        Write-Host ($lang).MsSpoti`n
        
        if (!($confirm_uninstall_ms_spoti)) {
            do {
                $ch = Read-Host -Prompt ($lang).MsSpoti2
                Write-Host
                if (!($ch -eq 'n' -or $ch -eq 'y')) {
                    Show-InvalidInput
                }
            }
    
            while ($ch -notmatch '^y$|^n$')
        }
        if ($confirm_uninstall_ms_spoti) { $ch = 'y' }
        if ($ch -eq 'y') {      
            $ProgressPreference = 'SilentlyContinue' # Hiding Progress Bars
            if ($confirm_uninstall_ms_spoti) { Write-Host ($lang).MsSpoti3`n }
            if (!($confirm_uninstall_ms_spoti)) { Write-Host ($lang).MsSpoti4`n }
            Get-AppxPackage -Name SpotifyAB.SpotifyMusic | Remove-AppxPackage
        }
        if ($ch -eq 'n') {
            Exit-WithMessage
        }
    }
}

# Clean up any Spotify-blocking entries in the hosts file
$hostsFilePath = Join-Path $Env:windir 'System32\Drivers\Etc\hosts'
$hostsBackupFilePath = Join-Path $Env:windir 'System32\Drivers\Etc\hosts.bak'

if (Test-Path -Path $hostsFilePath) {

    $hosts = [System.IO.File]::ReadAllLines($hostsFilePath)
    $regex = "^(?!#|\|)((?:.*?(?:download|upgrade)\.scdn\.co|.*?spotify).*)"

    if ($hosts -match $regex) {

        Write-Host ($lang).HostInfo`n
        Write-Host ($lang).HostBak`n

        Copy-Item -Path $hostsFilePath -Destination $hostsBackupFilePath -ErrorAction SilentlyContinue

        if ($?) {

            Write-Host ($lang).HostDel

            try {
                $hosts = $hosts | Where-Object { $_ -notmatch $regex }
                [System.IO.File]::WriteAllLines($hostsFilePath, $hosts)
            }
            catch {
                Write-Host ($lang).HostError`n -ForegroundColor Red
                $copyError = $Error[0]
                Write-Host "Error: $($copyError.Exception.Message)`n" -ForegroundColor Red
            }
        }
        else {
            Write-Host ($lang).HostError`n -ForegroundColor Red
            $copyError = $Error[0]
            Write-Host "Error: $($copyError.Exception.Message)`n" -ForegroundColor Red
        }
    }
}

if ($premium) {
    Write-Host ($lang).Prem`n
}

$spAlreadyInstalled = (Test-Path -LiteralPath $spExeFile)

if ($SpotifyPath -and -not $spAlreadyInstalled) {
    Write-Warning "Spotify not found in custom path: $spInstallPath"
    Exit-WithMessage
}

if ($spAlreadyInstalled) {
    
    # Check version Spotify offline
    $installedVer = (Get-Item $spExeFile).VersionInfo.FileVersion
 
    # Version comparison
    # converting strings to arrays of numbers using the -split operator and a foreach loop
    
    $arr1 = $targetVer -split '\.' | foreach { [int]$_ }
    $arr2 = $installedVer -split '\.' | foreach { [int]$_ }

    # compare each element of the array in order from most significant to least significant.
    for ($i = 0; $i -lt $arr1.Length; $i++) {
        if ($arr1[$i] -gt $arr2[$i]) {
            $isOutdated = $true
            break
        }
        elseif ($arr1[$i] -lt $arr2[$i]) {
            $isNewer = $true
            break
        }
    }

    # Old version Spotify (skip if custom path is used)
    if ($isOutdated -and -not $SpotifyPath) {
        if ($confirm_spoti_recomended_over -or $confirm_spoti_recomended_uninstall) {
            Write-Host ($lang).OldV`n
        }
        if (!($confirm_spoti_recomended_over) -and !($confirm_spoti_recomended_uninstall)) {
            do {
                Write-Host (($lang).OldV2 -f $installedVer, $targetVer)
                $ch = Read-Host -Prompt ($lang).OldV3
                Write-Host
                if (!($ch -eq 'n' -or $ch -eq 'y')) {
                    Show-InvalidInput
                }
            }
            while ($ch -notmatch '^y$|^n$')
        }
        if ($confirm_spoti_recomended_over -or $confirm_spoti_recomended_uninstall) { 
            $ch = 'y' 
            Write-Host ($lang).AutoUpd`n
        }
        if ($ch -eq 'y') { 
            $needsInstall = $true 

            if (!($confirm_spoti_recomended_over) -and !($confirm_spoti_recomended_uninstall)) {
                do {
                    $ch = Read-Host -Prompt (($lang).DelOrOver -f $installedVer)
                    Write-Host
                    if (!($ch -eq 'n' -or $ch -eq 'y')) {
                        Show-InvalidInput
                    }
                }
                while ($ch -notmatch '^y$|^n$')
            }
            if ($confirm_spoti_recomended_uninstall) { $ch = 'y' }
            if ($confirm_spoti_recomended_over) { $ch = 'n' }
            if ($ch -eq 'y') {
                Write-Host ($lang).DelOld`n 
                $null = Remove-UpdateLock 
                cmd /c $spExeFile /UNINSTALL /SILENT
                Get-Process -Name SpotifyUninstall -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue
                Start-Sleep -Milliseconds 200
                if (Test-Path $spInstallPath) { Remove-Item -Recurse -Force -LiteralPath $spInstallPath }
                if (Test-Path $spInstallPathLocal) { Remove-Item -Recurse -Force -LiteralPath $spInstallPathLocal }
                if (Test-Path $spUninstaller ) { Remove-Item -Recurse -Force -LiteralPath $spUninstaller }
            }
            if ($ch -eq 'n') { $ch = $null }
        }
        if ($ch -eq 'n') { 
            $versionRollback = $true
        }
    }
    
    # Unsupported version Spotify (skip if custom path is used)
    if ($isNewer -and -not $SpotifyPath) {

        # Submit unsupported version of Spotify to google form for further processing

        $binary = if (Test-Path $spDllFile) {
            $spDllFile
        }
        else {
            $spExeFile
        }

        Start-Job -ScriptBlock {
            param($binary, $win_os, $psv, $targetVer, $installedVer)

            try { 
                $country = [System.Globalization.RegionInfo]::CurrentRegion.EnglishName
                $txt = [IO.File]::ReadAllText($binary)
                $regex = "(?<![\w\-])(\d+)\.(\d+)\.(\d+)\.(\d+)(\.g[0-9a-f]{8})(?![\w\-])"
                $matches = [regex]::Matches($txt, $regex)
                $ver = $matches[0].Value
                $Parameters = @{
                    Uri    = 'https://docs.google.com/forms/d/e/1FAIpQLSegGsAgilgQ8Y36uw-N7zFF6Lh40cXNfyl1ecHPpZcpD8kdHg/formResponse'
                    Method = 'POST'
                    Body   = @{
                        'entry.620327948'  = $ver
                        'entry.1951747592' = $country
                        'entry.1402903593' = $win_os
                        'entry.860691305'  = $psv
                        'entry.2067427976' = $targetVer + " < " + $installedVer
                    }   
                }
                Invoke-WebRequest @Parameters -UseBasicParsing -ErrorAction SilentlyContinue | Out-Null
            }
            catch { }
        } -ArgumentList $binary, $win_os, $psv, $targetVer, $installedVer | Out-Null

        if ($confirm_spoti_recomended_over -or $confirm_spoti_recomended_uninstall) {
            Write-Host ($lang).NewV`n
        }
        if (!($confirm_spoti_recomended_over) -and !($confirm_spoti_recomended_uninstall)) {
            do {
                Write-Host (($lang).NewV2 -f $installedVer, $targetVer)
                $ch = Read-Host -Prompt (($lang).NewV3 -f $installedVer)
                Write-Host
                if (!($ch -eq 'n' -or $ch -eq 'y')) {
                    Show-InvalidInput
                }
            }
            while ($ch -notmatch '^y$|^n$')
        }
        if ($confirm_spoti_recomended_over -or $confirm_spoti_recomended_uninstall) { $ch = 'n' }
        if ($ch -eq 'y') { $needsInstall = $false }
        if ($ch -eq 'n') {
            if (!($confirm_spoti_recomended_over) -and !($confirm_spoti_recomended_uninstall)) {
                do {
                    $ch = Read-Host -Prompt (($lang).Recom -f $targetVer)
                    Write-Host
                    if (!($ch -eq 'n' -or $ch -eq 'y')) {
                        Show-InvalidInput
                    }
                }
                while ($ch -notmatch '^y$|^n$')
            }
            if ($confirm_spoti_recomended_over -or $confirm_spoti_recomended_uninstall) { 
                $ch = 'y' 
                Write-Host ($lang).AutoUpd`n
            }
            if ($ch -eq 'y') {
                $needsInstall = $true
                $versionRollback = $true
                if (!($confirm_spoti_recomended_over) -and !($confirm_spoti_recomended_uninstall)) {
                    do {
                        $ch = Read-Host -Prompt (($lang).DelOrOver -f $installedVer)
                        Write-Host
                        if (!($ch -eq 'n' -or $ch -eq 'y')) {
                            Show-InvalidInput
                        }
                    }
                    while ($ch -notmatch '^y$|^n$')
                }
                if ($confirm_spoti_recomended_uninstall) { $ch = 'y' }
                if ($confirm_spoti_recomended_over) { $ch = 'n' }
                if ($ch -eq 'y') {
                    Write-Host ($lang).DelNew`n
                    $null = Remove-UpdateLock
                    cmd /c $spExeFile /UNINSTALL /SILENT
                    Get-Process -Name SpotifyUninstall -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue
                    Start-Sleep -Milliseconds 200
                    if (Test-Path $spInstallPath) { Remove-Item -Recurse -Force -LiteralPath $spInstallPath }
                    if (Test-Path $spInstallPathLocal) { Remove-Item -Recurse -Force -LiteralPath $spInstallPathLocal }
                    if (Test-Path $spUninstaller ) { Remove-Item -Recurse -Force -LiteralPath $spUninstaller }
                }
                if ($ch -eq 'n') { $ch = $null }
            }

            if ($ch -eq 'n') {
                Clear-WorkDir -Directory $workDir
                Exit-WithMessage
            }
        }
    }
}
# If there is no client or it is outdated, then install (skip if custom path is used)
if (-not $SpotifyPath -and (-not $spAlreadyInstalled -or $needsInstall)) {

    Write-Host ($lang).DownSpoti"" -NoNewline
    Write-Host  $targetVer -ForegroundColor Green
    Write-Host ($lang).DownSpoti2`n
    
    Show-Step "Downloading Spotify $targetVer"
    # Wipe old Spotify binaries while keeping user profile data
    $ErrorActionPreference = 'SilentlyContinue'
    Stop-SpotifyProcess
    Start-Sleep -Milliseconds 600
    $null = Remove-UpdateLock 
    Start-Sleep -Milliseconds 200
    Get-ChildItem $spInstallPath -Exclude 'Users', 'prefs' | Remove-Item -Recurse -Force 
    Start-Sleep -Milliseconds 200

    $workDirName = "DTSpotifyBlock_Temp-$(Get-Date -UFormat '%Y-%m-%d_%H-%M-%S')"
    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) $workDirName
    if (-not (Test-Path -LiteralPath $workDir)) { New-Item -ItemType Directory -Path $workDir | Out-Null }

    # Download Spotify installer
    Invoke-SpotifyDownload -DownloadFolder $workDir
    Write-Host

    Start-Sleep -Milliseconds 200

    Show-Step "Installing Spotify"
    # Run Spotify installer
    $setupExe = Join-Path $workDir 'SpotifySetup.exe'
    Start-Process -FilePath explorer.exe -ArgumentList $setupExe
    while (-not (get-process | Where-Object { $_.ProcessName -eq 'SpotifySetup' })) {}
    wait-process -name SpotifySetup
    Stop-SpotifyProcess

    # Re-read installed version after upgrade
    $installedVer = (Get-Item $spExeFile).VersionInfo.FileVersion

    # Re-read backup binary version
    $backupVer = (Get-Item $exe_bak).VersionInfo.FileVersion
}



# Remove desktop shortcut if requested
if ($no_shortcut) {
    $ErrorActionPreference = 'SilentlyContinue'
    $desktopPath = Get-DesktopPath
    Start-Sleep -Milliseconds 1000
    remove-item "$desktopPath\Spotify.lnk" -Recurse -Force
}

$ch = $null


# Load extended Russian language pack if applicable
if ($selectedLang -eq 'ru' -and [version]$installedVer -ge [version]"1.1.92.644") { 
    
    $ruTranslations = Get -Url (Get-BaseUrl -e "/patches/Augmented%20translation/ru.json")

    if ($ruTranslations -ne $null) {

        $hasRuLang = $true
    }
}

if ($podcasts_off) { 
    Write-Host ($lang).PodcatsOff`n 
    $ch = 'y'
}
if ($podcasts_on) {
    Write-Host ($lang).PodcastsOn`n
    $ch = 'n'
}
if (!($podcasts_off) -and !($podcasts_on)) {

    do {
        $ch = Read-Host -Prompt ($lang).PodcatsSelect
        Write-Host
        if (!($ch -eq 'n' -or $ch -eq 'y')) { Show-InvalidInput }
    }
    while ($ch -notmatch '^y$|^n$')
}
if ($ch -eq 'y') { $hidePodcasts = $true }

$ch = $null

if ($versionRollback) { $upd = "`n" + [string]($lang).DowngradeNote }

else { $upd = "" }

if ($block_update_on) { 
    Write-Host ($lang).UpdBlock`n
    $ch = 'y'
}
if ($block_update_off) {
    Write-Host ($lang).UpdUnblock`n
    $ch = 'n'
}
if (!($block_update_on) -and !($block_update_off)) {
    do {
        $text_upd = [string]($lang).UpdSelect + $upd
        $ch = Read-Host -Prompt $text_upd
        Write-Host
        if (!($ch -eq 'n' -or $ch -eq 'y')) { Show-InvalidInput } 
    }
    while ($ch -notmatch '^y$|^n$')
}
if ($ch -eq 'y') { $allowAutoUpdate = $false }

if (!($new_theme) -and [version]$installedVer -ge [version]"1.2.14.1141") {
    Write-Warning "This version does not support the old theme, use version 1.2.13.661 or below"
    Write-Host
}

if ($ch -eq 'n') {
    $allowAutoUpdate = $true
    $ErrorActionPreference = 'SilentlyContinue'
    if ((Test-Path -LiteralPath $exe_bak) -and $installedVer -eq $backupVer) {
        Remove-Item $spExeFile -Recurse -Force
        Rename-Item $exe_bak $spExeFile
    }
}

$ch = $null

$patchManifest = Get -Url (Get-BaseUrl -e "/patches/patches.json") -RetrySeconds 5
        
if ($patchManifest -eq $null) { 
    Write-Host
    Write-Host "Failed to get patches.json" -ForegroundColor Red
    Clear-WorkDir -Directory $workDir
    Exit-WithMessage
}


function Helper($paramname) {


    function Remove-Json {
        param (
            [Parameter(Mandatory = $true)]
            [Alias("j")]
            [PSObject]$Json,
            
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [Alias("p")]
            [string[]]$Properties
        )
        
        foreach ($Property in $Properties) {
            $Json.psobject.properties.Remove($Property)
        }
    }
    function Move-Json {
        param (
            [Parameter(Mandatory = $true)]
            [Alias("t")]
            [PSObject]$to,
    
            [Parameter(Mandatory = $true)]
            [Alias("n")]
            [string[]]$name,
    
            [Parameter(Mandatory = $true)]
            [Alias("f")]
            [PSObject]$from
        )
    
        foreach ($propertyName in $name) {
            $from | Add-Member -MemberType NoteProperty -Name $propertyName -Value $to.$propertyName
            Remove-Json -j $to -p $propertyName
        }
    }

    switch ( $paramname ) {
        "HtmlLicMin" { 
            # Minify license page
            $name = "patches.json.others."
            $n = "licenses.html"
            $contents = "htmlmin"
            $json = $patchManifest.others
        }
        "HtmlBlank" { 
            # htmlBlank minification
            $name = "patches.json.others."
            $n = "blank.html"
            $contents = "blank.html"
            $json = $patchManifest.others
        }
        "MinJs" { 
            # Minify all JS files
            $contents = "minjs"
            $json = $patchManifest.others
        }
        "MinJson" { 
            # Minify all JS fileson
            $contents = "minjson"
            $json = $patchManifest.others
        }
        "FixCss" { 
            # Remove indent for old theme xpui.css
            $name = "patches.json.others."
            $n = "xpui.css"
            $json = $patchManifest.others
        }
        "Fixjs" { 
            $n = $name
            $contents = "searchFixes"
            $name = "patches.json.others."
            $json = $patchManifest.others
        }
        "Cssmin" { 
            # Minification of all *.css
            $contents = "cssmin"
            $json = $patchManifest.others
        }
        "DisableSentry" { 

            $name = "patches.json.others."
            $n = $fileName
            $contents = "disablesentry"
            $json = $patchManifest.others
        }
        "Discriptions" {  
            # Inject DTSpotifyBlock info into about dialog

            $svg_tg = $patchManifest.others.discriptions.svgtg
            $svg_git = $patchManifest.others.discriptions.svggit
            $svg_faq = $patchManifest.others.discriptions.svgfaq
            $replace = $patchManifest.others.discriptions.replace

            $replacedText = $replace -f $svg_git, $svg_tg, $svg_faq

            $patchManifest.others.discriptions.replace = '$1"' + $replacedText + '"})'

            $name = "patches.json.others."
            $n = "xpui-desktop-modals.js"
            $contents = "discriptions"
            $json = $patchManifest.others
        }
        "OffadsonFullscreen" { 
            # Block premium upsell UI and enable fullscreen mode
            $name = "patches.json.free."
            $n = "xpui.js"
            $contents = $patchManifest.free.psobject.properties.name
            $json = $patchManifest.free
        }
        "ForcedExp" {  
            # Forced disable some exp (xpui.js)
            $installedVerShort = $installedVer -replace '(\d+\.\d+\.\d+)(.\d+)', '$1'
            $Enable = $patchManifest.others.EnableExp
            $Disable = $patchManifest.others.DisableExp
            $Custom = $patchManifest.others.CustomExp

            # causes lags in the main menu 1.2.44-1.2.56
            if ([version]$installedVer -le [version]'1.2.56.502') { Move-Json -n 'HomeCarousels' -t $Enable -f $Disable }

            # disable search suggestions
            Move-Json -n 'SearchSuggestions' -t $Enable -f $Disable

            # disable new scrollbar
            Move-Json -n 'NewOverlayScrollbars' -t $Enable -f $Disable

            # temporarily disable collapsing right sidebar
            Move-Json -n 'PeekNpv' -t $Enable -f $Disable
 
            if ($hidePodcasts) { Move-Json -n 'HomePin' -t $Enable -f $Disable }

            # disabled broken panel from 1.2.37 to 1.2.38
            if ([version]$installedVer -eq [version]'1.2.37.701' -or [version]$installedVer -eq [version]'1.2.38.720' ) { 
                Move-Json -n 'DevicePickerSidePanel' -t $Enable -f $Disable
            }

            if ([version]$installedVer -ge [version]'1.2.41.434' -and $lyrics_block) { Move-Json -n 'Lyrics' -t $Enable -f $Disable } 

            if ([version]$installedVer -eq [version]'1.2.30.1135') { Move-Json -n 'QueueOnRightPanel' -t $Enable -f $Disable }

            if ([version]$installedVer -le [version]'1.2.50.335') {

                if (!($plus)) { Move-Json -n "Plus", "AlignedCurationSavedIn" -t $Enable -f $Disable }
            
            }

            if (!$topsearchbar) {
                Move-Json -n "GlobalNavBar" -t $Enable -f $Disable 
                $Custom.GlobalNavBar.value = "control"
                if ([version]$installedVer -le [version]"1.2.45.454") {
                    Move-Json -n "RecentSearchesDropdown" -t $Enable -f $Disable 
                }
            }
            if ([version]$installedVer -le [version]'1.2.50.335') {

                if (!($funnyprogressbar)) { Move-Json -n 'HeBringsNpb' -t $Enable -f $Disable }
            
            }

            if ([version]$installedVer -le [version]'1.2.62.580') {

                if (!$newFullscreenMode) { Move-Json -n "ImprovedCinemaMode", "ImprovedCinemaModeCanvas" -t $Enable -f $Disable }
            
            }
            # disable subfeed filter chips on home
            if ($homesub_off) { 
                Move-Json -n "HomeSubfeeds" -t $Enable -f $Disable 
            }

            # Old theme
            if (!($new_theme) -and [version]$installedVer -le [version]"1.2.13.661") {

                Move-Json -n 'RightSidebar', 'LeftSidebar' -t $Enable -f $Disable

                Remove-Json -j $Custom -p "NavAlt", 'NavAlt2'
                Remove-Json -j $Enable -p 'RightSidebarLyrics', 'RightSidebarCredits', 'RightSidebar', 'LeftSidebar', 'RightSidebarColors'
            }
            # New theme
            else {
                if ($rightsidebar_off -and [version]$installedVer -lt [version]"1.2.24.756") { 
                    Move-Json -n 'RightSidebar' -t $Enable -from $Disable
                }
                else {
                    if (!($rightsidebarcolor)) { Remove-Json -j $Enable -p 'RightSidebarColors' }
                    
                    if ($old_lyrics) { 
                        Remove-Json -j $Enable -p 'RightSidebarLyrics' 
                        $Custom.LyricsVariationsInNPV.value = "CONTROL"
                    } 
                }
            }
            if (!$premium) { Remove-Json -j $Enable -p 'RemoteDownloads', 'Magpie', 'MagpiePrompting', 'MagpieScheduling', 'MagpieCuration' }

            # Disable unimportant exp
            if ($exp_spotify) {
                $objects = @(
                    @{
                        Object           = $patchManifest.others.CustomExp.psobject.properties
                        PropertiesToKeep = @('LyricsUpsell')
                    },
                    @{
                        Object           = $patchManifest.others.EnableExp.psobject.properties
                        PropertiesToKeep = @('BrowseViaPathfinder', 'HomeViaGraphQLV2')
                    }
                )

                foreach ($obj in $objects) {
                    $propertiesToRemove = $obj.Object.Name | Where-Object { $_ -notin $obj.PropertiesToKeep }
                    $propertiesToRemove | foreach {
                        $obj.Object.Remove($_)
                    }
                }

            }

            $Exp = ($Enable, $Disable, $Custom)

            foreach ($item in $Exp) {
                $itemProperties = $item | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            
                foreach ($key in $itemProperties) {
                    $vers = $item.$key.version
            
                    if (!($vers.to -eq "" -or [version]$vers.to -ge [version]$installedVerShort -and [version]$vers.fr -le [version]$installedVerShort)) {
                        if ($item.PSObject.Properties.Name -contains $key) {
                            $item.PSObject.Properties.Remove($key)
                        }
                    }
                }
            }

            $Enable = $patchManifest.others.EnableExp
            $Disable = $patchManifest.others.DisableExp
            $Custom = $patchManifest.others.CustomExp

            $enableNames = foreach ($item in $Enable.PSObject.Properties.Name) {
                $patchManifest.others.EnableExp.$item.name
            }

            $disableNames = foreach ($item in $Disable.PSObject.Properties.Name) {
                $patchManifest.others.DisableExp.$item.name
            }

            $customNames = foreach ($item in $Custom.PSObject.Properties.Name) {
                $custname = $patchManifest.others.CustomExp.$item.name
                $custvalue = $patchManifest.others.CustomExp.$item.value

                # Create a string with the desired format
                $objectString = "{name:'$custname',value:'$custvalue'}"
                $objectString
            }
               
            # Convert the strings of objects into a single text string
            if ([string]::IsNullOrEmpty($customNames)) { $customTextVariable = '[]' }
            else { $customTextVariable = "[" + ($customNames -join ',') + "]" }
            if ([string]::IsNullOrEmpty($enableNames)) { $enableTextVariable = '[]' }
            else { $enableTextVariable = "['" + ($enableNames -join "','") + "']" }
            if ([string]::IsNullOrEmpty($disableNames)) { $disableTextVariable = '[]' }
            else { $disableTextVariable = "['" + ($disableNames -join "','") + "']" }

            $replacements = @(
                @("enable:[]", "enable:$enableTextVariable"),
                @("disable:[]", "disable:$disableTextVariable"),
                @("custom:[]", "custom:$customTextVariable")
            )

            foreach ($replacement in $replacements) {
                $patchManifest.others.ForcedExp.replace = $patchManifest.others.ForcedExp.replace.Replace($replacement[0], $replacement[1])
            }

            $name = "patches.json.others."
            $n = "xpui.js"
            $contents = "ForcedExp"
            $json = $patchManifest.others
        }
        "RuTranslate" { 
            # Additional translation of some words for the Russian language
            $n = "ru.json"
            $contents = $ruTranslations.psobject.properties.name
            $json = $ruTranslations
        }
        "Binary" { 

            $binary = $patchManifest.others.binary

            if ($allowAutoUpdate) { Remove-Json -j $binary -p 'block_update' }

            if ($premium) { Remove-Json -j $binary -p 'block_slots_2', 'block_slots_3' }

            $name = "patches.json.others.binary."
            $n = "Spotify.exe"
            $contents = $patchManifest.others.binary.psobject.properties.name
            $json = $patchManifest.others.binary
        }
        "Collaborators" { 
            # Remove collaborator icon from playlist view
            $name = "patches.json.others."
            $n = "xpui-routes-playlist.js"
            $contents = "collaboration"
            $json = $patchManifest.others
        }
        "Dev" { 

            $name = "patches.json.others."
            $n = "xpui-routes-desktop-settings.js"
            $contents = "dev-tools"
            $json = $patchManifest.others

        }        
        "VariousofXpui-js" { 

            $VarJs = $patchManifest.VariousJs

            if ($premium) { Remove-Json -j $VarJs -p 'mock', 'upgradeButton', 'upgradeMenu' }

            if ($topsearchbar -or ([version]$installedVer -ne [version]"1.2.45.451" -and [version]$installedVer -ne [version]"1.2.45.454")) { 
                Remove-Json -j $VarJs -p "fixTitlebarHeight"
            }

            if (!($lyrics_block)) { Remove-Json -j $VarJs -p "lyrics-block" }

            else { 
                Remove-Json -j $VarJs -p "lyrics-old-on"
            }

            if (!($devtools)) { Remove-Json -j $VarJs -p "dev-tools" }

            else {
                if ([version]$installedVer -ge [version]"1.2.35.663") {

                    # Create a copy of 'dev-tools'
                    $newDevTools = $patchManifest.VariousJs.'dev-tools'.PSObject.Copy()
                    
                    # Delete the first item and change the version
                    $newDevTools.match = $newDevTools.match[0], $newDevTools.match[2]
                    $newDevTools.replace = $newDevTools.replace[0], $newDevTools.replace[2]
                    $newDevTools.version.fr = '1.2.35'
                    
                    # Assign a copy of 'devtools' to the 'devtools' property in $web json.others
                    $patchManifest.others | Add-Member -Name 'dev-tools' -Value $newDevTools -MemberType NoteProperty
					
                    # leave only first item in $web json.Various Js.'devtools' match & replace
                    $patchManifest.VariousJs.'dev-tools'.match = $patchManifest.VariousJs.'dev-tools'.match[1]
                    $patchManifest.VariousJs.'dev-tools'.replace = $patchManifest.VariousJs.'dev-tools'.replace[1] 
                }
            }

            if ($urlform_goofy -and $idbox_goofy) {
                $patchManifest.VariousJs.goofyhistory.replace = $patchManifest.VariousJs.goofyhistory.replace -f "`"$urlform_goofy`"", "`"$idbox_goofy`""
            }
            else { Remove-Json -j $VarJs -p "goofyhistory" }
            
            if (!($hasRuLang)) { Remove-Json -j $VarJs -p "offrujs" }

            if (!($premium) -or ($cache_limit)) {
                if (!($premium)) { 
                    $productStateInjection += $patchManifest.VariousJs.product_state.add
                }

                if ($cache_limit) { 
        
                    if ($cache_limit -lt 500) { $cache_limit = 500 }
                    if ($cache_limit -gt 20000) { $cache_limit = 20000 }
                        
                    $cacheAddition = $patchManifest.VariousJs.product_state.add2
                    if (!([string]::IsNullOrEmpty($productStateInjection))) { $cacheAddition = ',' + $cacheAddition }
                    $productStateInjection += $cacheAddition -f $cache_limit

                }
                $repl = $patchManifest.VariousJs.product_state.replace
                $patchManifest.VariousJs.product_state.replace = $repl -f "{pairs:{$productStateInjection}}"
            }
            else { Remove-Json -j $VarJs -p 'product_state' }

            
            $name = "patches.json.VariousJs."
            $n = "xpui.js"
            $contents = $patchManifest.VariousJs.psobject.properties.name
            $json = $patchManifest.VariousJs
        }
    }
    $fileContent = $xpui
    $patchMissMsg = "Didn't find variable "
    $installedVerShort = $installedVer -replace '(\d+\.\d+\.\d+)(.\d+)', '$1'

    $contents | foreach { 

        if ( $json.$PSItem.version.to ) { $to = [version]$json.$PSItem.version.to -ge [version]$installedVerShort } else { $to = $true }
        if ( $json.$PSItem.version.fr ) { $fr = [version]$json.$PSItem.version.fr -le [version]$installedVerShort } else { $fr = $false }
        
        $checkVer = $fr -and $to; $translate = $paramname -eq "RuTranslate"

        if ($checkVer -or $translate) {

            if ($json.$PSItem.match.Count -gt 1) {

                $count = $json.$PSItem.match.Count - 1
                $numbers = 0

                While ($numbers -le $count) {

                    # Use Contains first to avoid loading huge regex into memory on large files
                    $matchPattern = $json.$PSItem.match[$numbers]
                    $safeCheck = $fileContent.Contains($matchPattern) -or ($fileContent -match $matchPattern)
                    if ($safeCheck) {
                        $fileContent = $fileContent -replace $matchPattern, $json.$PSItem.replace[$numbers] 
                    }
                    else { 
                        $notlog = "MinJs", "MinJson", "Cssmin", "htmlmin", "MinHtml", "others"
                        if ($paramname -notin $notlog) {
    
                            Write-Host $patchMissMsg -ForegroundColor red -NoNewline 
                            Write-Host "$name$PSItem $numbers"'in'$n
                        }
                    }  
                    $numbers++
                }
            }
            if ($json.$PSItem.match.Count -eq 1) {
                $matchPattern = $json.$PSItem.match
                $safeCheck = $fileContent.Contains($matchPattern) -or ($fileContent -match $matchPattern)
                if ($safeCheck) { 
                    $fileContent = $fileContent -replace $matchPattern, $json.$PSItem.replace 
                }
                else { 
                    $notlog = "MinJs", "MinJson", "Cssmin", "htmlmin", "MinHtml", "others"
                    if ((!($translate) -or $err_ru) -and $paramname -notin $notlog) {
                        Write-Host $patchMissMsg -ForegroundColor red -NoNewline 
                        Write-Host "$name$PSItem"'in'$n
                    }
                }
            }   
        }
    }
    $fileContent
}

function extract ($counts, $method, $name, $helper, $add, $patch) {
    switch ( $counts ) {
        "one" { 
            if ($method -eq "zip") {
                Add-Type -Assembly 'System.IO.Compression.FileSystem'
                $spaPatchPath = Join-Path (Join-Path $spInstallPath 'Apps') 'xpui.spa'
                $zip = [System.IO.Compression.ZipFile]::Open($spaPatchPath, 'update')   
                $file = $zip.GetEntry($name)
                $reader = New-Object System.IO.StreamReader($file.Open())
            }
            if ($method -eq "nonezip") {
                $file = Get-Item (Join-Path (Join-Path (Join-Path $spInstallPath 'Apps') 'xpui') $name)
                $reader = New-Object -TypeName System.IO.StreamReader -ArgumentList $file
            }
            $xpui = $reader.ReadToEnd()
            $reader.Close()
            if ($helper) { $xpui = Helper -paramname $helper } 
            if ($method -eq "zip") { $writer = New-Object System.IO.StreamWriter($file.Open()) }
            if ($method -eq "nonezip") { $writer = New-Object System.IO.StreamWriter -ArgumentList $file }
            $writer.BaseStream.SetLength(0)
            $writer.Write($xpui)
            if ($add) { $add | foreach { $writer.Write([System.Environment]::NewLine + $PSItem ) } }
            $writer.Close()  
            if ($method -eq "zip") { $zip.Dispose() }
        }
        "more" {  
            Add-Type -Assembly 'System.IO.Compression.FileSystem'
            $spaPatchPath = Join-Path (Join-Path $spInstallPath 'Apps') 'xpui.spa'
            $zip = [System.IO.Compression.ZipFile]::Open($spaPatchPath, 'update') 
            $zip.Entries | Where-Object { $_.FullName -like $name -and $_.FullName.Split('/') -notcontains 'dtspotifyblock-inject' } | foreach { 
                $reader = New-Object System.IO.StreamReader($_.Open())
                $xpui = $reader.ReadToEnd()
                $reader.Close()
                $xpui = Helper -paramname $helper 
                $writer = New-Object System.IO.StreamWriter($_.Open())
                $writer.BaseStream.SetLength(0)
                $writer.Write($xpui)
                $writer.Close()
            }
            $zip.Dispose()
        }
        "exe" {
            $ANSI = [Text.Encoding]::GetEncoding(1251)
            $xpui = [IO.File]::ReadAllText($binaryTarget, $ANSI)
            $xpui = Helper -paramname $helper
            [IO.File]::WriteAllText($binaryTarget, $xpui, $ANSI)
        }
    }
}

function injection {
    param(
        [Alias("p")]
        [string]$ArchivePath,

        [Alias("f")]
        [string]$FolderInArchive,

        [Alias("n")]
        [string[]]$FileNames, 

        [Alias("c")]
        [string[]]$FileContents,

        [Alias("i")]
        [string[]]$FilesToInject  # force only specific file/files to connect index.html otherwise all will be connected
    )

    $folderPathInArchive = "$($FolderInArchive)/"

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::Open($ArchivePath, 'Update')
    
    try {
        for ($i = 0; $i -lt $FileNames.Length; $i++) {
            $fileName = $FileNames[$i]
            $fileContent = $FileContents[$i]

            $entry = $archive.GetEntry($folderPathInArchive + $fileName)
            if ($entry -eq $null) {
                $stream = $archive.CreateEntry($folderPathInArchive + $fileName).Open()
            }
            else {
                $stream = $entry.Open()
            }

            $writer = [System.IO.StreamWriter]::new($stream)
            $writer.Write($fileContent)

            $writer.Dispose()
            $stream.Dispose()
        }

        $indexEntry = $archive.Entries | Where-Object { $_.FullName -eq "index.html" }
        if ($indexEntry -ne $null) {
            $indexStream = $indexEntry.Open()
            $reader = [System.IO.StreamReader]::new($indexStream)
            $indexContent = $reader.ReadToEnd()
            $reader.Dispose()
            $indexStream.Dispose()

            $headTagIndex = $indexContent.IndexOf("</head>")
            $scriptTagIndex = $indexContent.IndexOf("<script")

            if ($headTagIndex -ge 0 -or $scriptTagIndex -ge 0) {
                $filesToInject = if ($FilesToInject) { $FilesToInject } else { $FileNames }

                foreach ($fileName in $filesToInject) {
                    if ($fileName.EndsWith(".js")) {
                        $modifiedIndexContent = $indexContent.Insert($scriptTagIndex, "<script defer=`"defer`" src=`"/$FolderInArchive/$fileName`"></script>")
                        $indexContent = $modifiedIndexContent
                    }
                    elseif ($fileName.EndsWith(".css")) {
                        $modifiedIndexContent = $indexContent.Insert($headTagIndex, "<link href=`"/$FolderInArchive/$fileName`" rel=`"stylesheet`">")
                        $indexContent = $modifiedIndexContent
                    }
                }

                $indexEntry.Delete()
                $newIndexEntry = $archive.CreateEntry("index.html").Open()
                $indexWriter = [System.IO.StreamWriter]::new($newIndexEntry)
                $indexWriter.Write($indexContent)
                $indexWriter.Dispose()
                $newIndexEntry.Dispose()

            }
            else {
                Write-Warning "<script or </head> tag was not found in the index.html file in the archive."
            }
        }
        else {
            Write-Warning "index.html not found in xpui.spa"
        }
    }
    finally {
        if ($archive -ne $null) {
            $archive.Dispose()
        }
    }
}


function Extract-WebpackModules {
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputFile
    )

    $scriptStart = Get-Date
    Write-Debug "=== Script execution started ==="
    Write-Debug "Input file: $InputFile"

    function Encode-UTF16LE {
        param([byte[]]$Bytes)
        $str = [System.Text.Encoding]::UTF8.GetString($Bytes)
        [System.Text.Encoding]::Unicode.GetBytes($str)
    }

    $StartMarker = [System.Text.Encoding]::UTF8.GetBytes("var __webpack_modules__={")
    $EndMarker = [System.Text.Encoding]::UTF8.GetBytes("//# sourceMappingURL=xpui-modules.js.map")

    [byte[]]$fileContent = [System.IO.File]::ReadAllBytes($InputFile)

    $isUTF16LE = $false
    if ($fileContent.Length -ge 2 -and $fileContent[0] -eq 0xFF -and $fileContent[1] -eq 0xFE) {
        $isUTF16LE = $true
    }
    elseif ($fileContent.Length -gt 100 -and $fileContent[1] -eq 0x00) {
        $isUTF16LE = $true
    }
    if (-not $isUTF16LE) {
        Write-Error "File is not in UTF-16LE format: $InputFile"
        exit 1
    }

    $searchStartMarker = Encode-UTF16LE -Bytes $StartMarker
    $searchEndMarker = Encode-UTF16LE -Bytes $EndMarker

    function IndexOfBytes($haystack, $needle, [int]$startIndex = 0) {
        if ($startIndex -lt 0) { $startIndex = 0 }
        $haystackLength = $haystack.Length
        $needleLength = $needle.Length
        $searchLimit = $haystackLength - $needleLength
        if ($searchLimit -lt $startIndex) { return -1 }
        $firstNeedleByte = $needle[0]
        for ($i = $startIndex; $i -le $searchLimit; $i++) {
            if ($haystack[$i] -eq $firstNeedleByte) {
                $found = $true
                for ($j = 1; $j -lt $needleLength; $j++) {
                    if ($haystack[$i + $j] -ne $needle[$j]) {
                        $found = $false
                        break
                    }
                }
                if ($found) { return $i }
            }
        }
        return -1
    }

    $startIdx = IndexOfBytes $fileContent $searchStartMarker 2
    if ($startIdx -eq -1) {
        Write-Error "Start marker not found"
        exit 1
    }
    Write-Debug "Start marker found at index $startIdx"

    $endMarkerSearchOffset = $startIdx + $searchStartMarker.Length
    $endIdx = IndexOfBytes $fileContent $searchEndMarker $endMarkerSearchOffset
    if ($endIdx -eq -1) {
        Write-Error "End marker not found after index $endMarkerSearchOffset"
        exit 1
    }
    Write-Debug "End marker found at absolute index $endIdx"

    $endDataIdx = $endIdx + $searchEndMarker.Length
    $length = $endDataIdx - $startIdx

    Write-Debug "Decoding data from UTF-16LE..."
    $decodedString = [System.Text.Encoding]::Unicode.GetString($fileContent, $startIdx, $length)

    $scriptEnd = Get-Date
    $duration = [math]::Round(($scriptEnd - $scriptStart).TotalSeconds, 1)
    Write-Debug "=== Execution completed in $duration seconds ==="

    return $decodedString
}

function Reset-Dll-Sign {
    [CmdletBinding()]
    param (
        [string]$FilePath
    )

    $TargetStringText = "Check failed: sep_pos != std::wstring::npos."

    $Patch_x64 = "B8 01 00 00 00 C3"

    $Patch_ARM64 = "20 00 80 52 C0 03 5F D6"

    $Patch_x64 = [byte[]]($Patch_x64 -split ' ' | ForEach-Object { [Convert]::ToByte($_, 16) })
    $Patch_ARM64 = [byte[]]($Patch_ARM64 -split ' ' | ForEach-Object { [Convert]::ToByte($_, 16) })

    $csharpCode = @"
using System;
using System.Collections.Generic;

public class ScannerCore {
    public static int FindBytes(byte[] data, byte[] pattern) {
        for (int i = 0; i < data.Length - pattern.Length; i++) {
            bool match = true;
            for (int j = 0; j < pattern.Length; j++) {
                if (data[i + j] != pattern[j]) { match = false; break; }
            }
            if (match) return i;
        }
        return -1;
    }

    public static List<int> FindXref_ARM64(byte[] data, ulong stringRVA, ulong sectionRVA, uint sectionRawPtr, uint sectionSize) {
        List<int> results = new List<int>();
        for (uint i = 0; i < sectionSize; i += 4) {
            uint fileOffset = sectionRawPtr + i;
            if (fileOffset + 8 > data.Length) break;
            uint inst1 = BitConverter.ToUInt32(data, (int)fileOffset);
            
            // ADRP
            if ((inst1 & 0x9F000000) == 0x90000000) {
                int rd = (int)(inst1 & 0x1F);
                long immLo = (inst1 >> 29) & 3;
                long immHi = (inst1 >> 5) & 0x7FFFF;
                long imm = (immHi << 2) | immLo;
                if ((imm & 0x100000) != 0) { imm |= unchecked((long)0xFFFFFFFFFFE00000); }
                imm = imm << 12; 
                ulong pc = sectionRVA + i;
                ulong pcPage = pc & 0xFFFFFFFFFFFFF000; 
                ulong page = (ulong)((long)pcPage + imm);

                uint inst2 = BitConverter.ToUInt32(data, (int)fileOffset + 4);
                // ADD
                if ((inst2 & 0xFF800000) == 0x91000000) {
                    int rn = (int)((inst2 >> 5) & 0x1F);
                    if (rn == rd) {
                        long imm12 = (inst2 >> 10) & 0xFFF;
                        ulong target = page + (ulong)imm12;
                        if (target == stringRVA) { results.Add((int)fileOffset); }
                    }
                }
            }
        }
        return results;
    }

    public static int FindStart(byte[] data, int startOffset, bool isArm) {
        int step = isArm ? 4 : 1;
        if (isArm && (startOffset % 4 != 0)) { startOffset -= (startOffset % 4); }

        for (int i = startOffset; i > 0; i -= step) {
            if (isArm) {
                if (i < 4) break;
                uint currInst = BitConverter.ToUInt32(data, i);
                // ARM64 Prologue: STP X29, X30, [SP, -imm]! -> FD 7B .. A9
                if ((currInst & 0xFF00FFFF) == 0xA9007BFD) { return i; }
            } else {
                // x64: Look for at least 2 bytes of padding (CC or 90) followed by a valid function start
                if (i >= 2) {
                    if ((data[i-1] == 0xCC && data[i-2] == 0xCC) || (data[i-1] == 0x90 && data[i-2] == 0x90)) {
                        if (data[i] != 0xCC && data[i] != 0x90) {
                            // Check for common function start bytes:
                            // 0x48 (REX.W), 0x40 (REX), 0x55 (push rbp), 0x53-0x57 (push reg)
                            byte b = data[i];
                            if (b == 0x48 || b == 0x40 || b == 0x55 || (b >= 0x53 && b <= 0x57)) {
                                return i;
                            }
                        }
                    }
                }
            }
            if (startOffset - i > 20000) break; 
        }
        return 0;
    }
}
"@

    if (-not ([System.Management.Automation.PSTypeName]'ScannerCore').Type) {
        Add-Type -TypeDefinition $csharpCode
    }
    
    Write-Verbose "Loading file: $FilePath"
    if (-not (Test-Path $FilePath)) { 
        Write-Warning "File Spotify.dll not found"
        Exit-WithMessage
    }
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)

    try {
        $e_lfanew = [BitConverter]::ToInt32($bytes, 0x3C)
        $Machine = [BitConverter]::ToUInt16($bytes, $e_lfanew + 4)
        $IsArm64 = $false
        $ArchName = "Unknown"
        
        if ($Machine -eq 0x8664) { $ArchName = "x64"; $IsArm64 = $false }
        elseif ($Machine -eq 0xAA64) { $ArchName = "ARM64"; $IsArm64 = $true }
        else { 
            Write-Warning "Architecture not supported for patching Spotify.dll"
            Exit-WithMessage
        }

        Write-Verbose "Architecture: $ArchName"

        $NumberOfSections = [BitConverter]::ToUInt16($bytes, $e_lfanew + 0x06)
        $SizeOfOptionalHeader = [BitConverter]::ToUInt16($bytes, $e_lfanew + 0x14)
        $SectionTableStart = $e_lfanew + 0x18 + $SizeOfOptionalHeader
        
        $Sections = @(); $CodeSection = $null
        for ($i = 0; $i -lt $NumberOfSections; $i++) {
            $secEntry = $SectionTableStart + ($i * 40)
            $VA = [BitConverter]::ToUInt32($bytes, $secEntry + 12)
            $RawSize = [BitConverter]::ToUInt32($bytes, $secEntry + 16)
            $RawPtr = [BitConverter]::ToUInt32($bytes, $secEntry + 20)
            $Chars = [BitConverter]::ToUInt32($bytes, $secEntry + 36)
            $SecObj = [PSCustomObject]@{ VA = $VA; RawPtr = $RawPtr; RawSize = $RawSize }
            $Sections += $SecObj
            if (($Chars -band 0x20) -ne 0 -and $CodeSection -eq $null) { $CodeSection = $SecObj }
        }
    }
    catch { 
        Write-Warning "PE Error in Spotify.dll"
        Exit-WithMessage
    }

    function Get-RVA($FileOffset) {
        foreach ($sec in $Sections) {
            if ($FileOffset -ge $sec.RawPtr -and $FileOffset -lt ($sec.RawPtr + $sec.RawSize)) {
                return ($FileOffset - $sec.RawPtr) + $sec.VA
            }
        }
        return 0
    }

    Write-Verbose "Searching for function..."
    $StringBytes = [System.Text.Encoding]::ASCII.GetBytes($TargetStringText)
    $StringOffset = [ScannerCore]::FindBytes($bytes, $StringBytes)
    if ($StringOffset -eq -1) { 
        Write-Warning "String not found in Spotify.dll"
        Exit-WithMessage
    }
    $StringRVA = Get-RVA $StringOffset

    $PatchOffset = 0
    if (-not $IsArm64) {
        $RawStart = $CodeSection.RawPtr; $RawEnd = $RawStart + $CodeSection.RawSize
        for ($i = $RawStart; $i -lt $RawEnd; $i++) {
            if ($bytes[$i] -eq 0x48 -and $bytes[$i + 1] -eq 0x8D -and $bytes[$i + 2] -eq 0x15) {
                $Rel = [BitConverter]::ToInt32($bytes, $i + 3)
                $Target = (Get-RVA $i) + 7 + $Rel
                if ($Target -eq $StringRVA) {
                    $PatchOffset = [ScannerCore]::FindStart($bytes, $i, $false)
                    if ($PatchOffset -gt 0) { break }
                }
            }
        }
    }
    else {
        $Results = [ScannerCore]::FindXref_ARM64($bytes, [uint64]$StringRVA, [uint64]$CodeSection.VA, [uint32]$CodeSection.RawPtr, [uint32]$CodeSection.RawSize)
        if ($Results.Count -gt 0) {
            $PatchOffset = [ScannerCore]::FindStart($bytes, $Results[0], $true)
        }
    }

    if ($PatchOffset -eq 0) { 
        Write-Warning "Function not found in Spotify.dll"
        Exit-WithMessage
    }

    $BytesToWrite = if ($IsArm64) { $Patch_ARM64 } else { $Patch_x64 }

    $CurrentBytes = @(); for ($i = 0; $i -lt $BytesToWrite.Length; $i++) { $CurrentBytes += $bytes[$PatchOffset + $i] }
    $FoundHex = ($CurrentBytes | ForEach-Object { $_.ToString("X2") }) -join " "
    Write-Verbose "Found (Offset: 0x$($PatchOffset.ToString("X"))): $FoundHex"

    if ($CurrentBytes[0] -eq $BytesToWrite[0] -and $CurrentBytes[$BytesToWrite.Length - 1] -eq $BytesToWrite[$BytesToWrite.Length - 1]) {
        Write-Warning "File Spotify.dll already patched"
        return
    }

    Write-Verbose "Applying patch..."
    for ($i = 0; $i -lt $BytesToWrite.Length; $i++) { $bytes[$PatchOffset + $i] = $BytesToWrite[$i] }

    $writeAttempts = 5
    $writeSuccess = $false
    for ($w = 1; $w -le $writeAttempts; $w++) {
        try {
            [System.IO.File]::WriteAllBytes($FilePath, $bytes)
            Write-Verbose "Success"
            $writeSuccess = $true
            break
        }
        catch {
            if ($w -lt $writeAttempts) {
                Write-Host "  File locked, retrying ($w/$writeAttempts)..." -ForegroundColor Yellow
                $null = & taskkill /F /IM Spotify.exe /T 2>$null
                Start-Sleep -Seconds 3
            } else {
                Write-Warning "Write error in Spotify.dll $($_.Exception.Message)"
                Exit-WithMessage
            }
        }
    }
}

function Get-PEArchitectureOffsets {
    param(
        [byte[]]$bytes,
        [int]$fileHeaderOffset
    )
    $machineType = [System.BitConverter]::ToUInt16($bytes, $fileHeaderOffset)
    $result = @{ Architecture = $null; DataDirectoryOffset = 0 }
    switch ($machineType) {
        0x8664 { $result.Architecture = 'x64'; $result.DataDirectoryOffset = 112 }
        0xAA64 { $result.Architecture = 'ARM64'; $result.DataDirectoryOffset = 112 }
        0x014c { $result.Architecture = 'x86'; $result.DataDirectoryOffset = 96 }
        default { $result.Architecture = 'Unknown'; $result.DataDirectoryOffset = $null }
    }
    $result.MachineType = $machineType
    return $result
}

function Remove-Sign {
    [CmdletBinding()]
    param([string]$filePath)
    try {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $peHeaderOffset = [System.BitConverter]::ToUInt32($bytes, 0x3C)
        if ($bytes[$peHeaderOffset] -ne 0x50 -or $bytes[$peHeaderOffset + 1] -ne 0x45) {
            Write-Warning "File '$(Split-Path $filePath -Leaf)' is not a valid PE file."
            return $false
        }
        $fileHeaderOffset = $peHeaderOffset + 4
        $optionalHeaderOffset = $fileHeaderOffset + 20
        $archInfo = Get-PEArchitectureOffsets -bytes $bytes -fileHeaderOffset $fileHeaderOffset
        if ($archInfo.DataDirectoryOffset -eq $null) {
            Write-Warning "Unsupported architecture type ($($archInfo.MachineType.ToString('X'))) in file '$(Split-Path $filePath -Leaf)'."
            return $false
        }
        $dataDirectoryOffsetWithinOptionalHeader = $archInfo.DataDirectoryOffset
        $securityDirectoryIndex = 4
        $certificateTableEntryOffset = $optionalHeaderOffset + $dataDirectoryOffsetWithinOptionalHeader + ($securityDirectoryIndex * 8)
        if ($certificateTableEntryOffset + 8 -gt $bytes.Length) {
            Write-Warning "Could not find Data Directory in file '$(Split-Path $filePath -Leaf)'. Header is corrupted or has non-standard format."
            return $false
        }
        $rva = [System.BitConverter]::ToUInt32($bytes, $certificateTableEntryOffset)
        $size = [System.BitConverter]::ToUInt32($bytes, $certificateTableEntryOffset + 4)
        if ($rva -eq 0 -and $size -eq 0) {
            Write-Host "Signature in file '$(Split-Path $filePath -Leaf)' is already absent." -ForegroundColor Yellow
            return $true
        }
        for ($i = 0; $i -lt 8; $i++) {
            $bytes[$certificateTableEntryOffset + $i] = 0
        }
        [System.IO.File]::WriteAllBytes($filePath, $bytes)
        return $true
    }
    catch {
        Write-Error "Error processing file '$filePath': $_"
        return $false
    }
}

function Remove-Signature-FromFiles {
    [CmdletBinding()]
    param([string[]]$fileNames)
    foreach ($fileName in $fileNames) {
        $fullPath = Join-Path -Path $spInstallPath -ChildPath $fileName
        if (-not (Test-Path $fullPath)) {
            Write-Error "File not found: $fullPath"
            Exit-WithMessage
        }
        try {
            Write-Verbose "Processing file: $fileName"
            if (Remove-Sign -filePath $fullPath) {
                Write-Verbose "  -> Signature entry successfully zeroed."
            }
        }
        catch {
            Write-Error "Failed to process file '$fileName': $_"
            Exit-WithMessage
        }
    }
}


function Update-ZipEntry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.IO.Compression.ZipArchive]$archive,
        [Parameter(Mandatory)]
        [string]$entryName,
        [string]$newEntryName = $null,
        [string]$prepend = $null,
        [scriptblock]$contentTransform = $null
    )

    $entry = $archive.GetEntry($entryName)
    if ($entry) {
        Write-Verbose "Updating entry: $entryName"
        $streamReader = $null
        $content = ''
        try {
            $streamReader = New-Object System.IO.StreamReader($entry.Open(), [System.Text.Encoding]::UTF8)
            $content = $streamReader.ReadToEnd()
        }
        finally {
            if ($null -ne $streamReader) {
                $streamReader.Close()
            }
        }

        $entry.Delete()

        if ($prepend) { $content = "$prepend`n$content" }
        if ($contentTransform) { $content = & $contentTransform $content }

        $finalEntryName = if ($newEntryName) { $newEntryName } else { $entryName }
        Write-Verbose "Creating new entry: $finalEntryName"

        $newEntry = $archive.CreateEntry($finalEntryName)
        $streamWriter = $null
        try {
            $streamWriter = New-Object System.IO.StreamWriter($newEntry.Open(), [System.Text.Encoding]::UTF8)
            $streamWriter.Write($content)
            $streamWriter.Flush()
        }
        finally {
            if ($null -ne $streamWriter) {
                $streamWriter.Close()
            }
        }
        Write-Verbose "Entry $finalEntryName updated successfully."
    }
    else {
        Write-Warning "Entry '$entryName' not found in archive."
    }
}


Write-Host ($lang).ModSpoti`n
Show-Step "Loading patch manifest"

Clear-WorkDir -Directory $workDir 

$spaPatchPath = Join-Path (Join-Path $spInstallPath 'Apps') 'xpui.spa'
$xpuiJsPath = Join-Path (Join-Path (Join-Path $spInstallPath 'Apps') 'xpui') 'xpui.js'
$spaExists = Test-Path -Path $spaPatchPath
$jsExists = Test-Path -Path $xpuiJsPath

if ($spaExists -and $jsExists) {
    Write-Host ($lang).Error -ForegroundColor Red
    Write-Host ($lang).FileLocBroken
    Exit-WithMessage
}

if ($jsExists) {
    
    do {
        $ch = Read-Host -Prompt ($lang).Spicetify
        Write-Host
        if (!($ch -eq 'n' -or $ch -eq 'y')) { Show-InvalidInput }
    }
    while ($ch -notmatch '^y$|^n$')

    if ($ch -eq 'y') { 
        $Url = "https://telegra.ph/DTSpotifyBlock-FAQ-09-19#Can-I-use-DTSpotifyBlock-and-Spicetify-together?"
        Start-Process $Url
    }

    Exit-WithMessage
}  

if (!($jsExists) -and !($spaExists)) { 
    Write-Host "xpui.spa not found, reinstall Spotify"
    Exit-WithMessage
}

if ($spaExists) {
    
    Add-Type -Assembly 'System.IO.Compression.FileSystem'
    
    # Verify xpui.js exists inside the spa bundle

    $archive_spa = $null

    try {
        $archive_spa = [System.IO.Compression.ZipFile]::OpenRead($spaPatchPath)
        $xpuiJsEntry = $archive_spa.GetEntry('xpui.js')
        $xpuiSnapshotEntry = $archive_spa.GetEntry('xpui-snapshot.js')

        if (($null -eq $xpuiJsEntry) -and ($null -ne $xpuiSnapshotEntry)) {
        
            $snapshot_x64 = Join-Path $spInstallPath 'v8_context_snapshot.bin'
            $snapshot_arm64 = Join-Path $spInstallPath 'v8_context_snapshot.arm64.bin'

            $v8_snapshot = switch ($true) {
                { Test-Path $snapshot_x64 } { $snapshot_x64; break }
                { Test-Path $snapshot_arm64 } { $snapshot_arm64; break }
                default { $null }
            }

            if ($v8_snapshot) {
                $modules = Extract-WebpackModules -InputFile $v8_snapshot

                $archive_spa.Dispose()
                $archive_spa = [System.IO.Compression.ZipFile]::Open($spaPatchPath, [System.IO.Compression.ZipArchiveMode]::Update)

                Update-ZipEntry -archive $archive_spa -entryName 'xpui-snapshot.js' -prepend $modules -newEntryName 'xpui.js' -Verbose:$VerbosePreference
            
                Update-ZipEntry -archive $archive_spa -entryName 'xpui-snapshot.css' -newEntryName 'xpui.css' -Verbose:$VerbosePreference
            
                Update-ZipEntry -archive $archive_spa -entryName 'index.html' -contentTransform {
                    param($c)
                    $c = $c -replace 'xpui-snapshot.js', 'xpui.js'
                    $c = $c -replace 'xpui-snapshot.css', 'xpui.css'
                    return $c
                } -Verbose:$VerbosePreference
            }
            
        }
    }
    catch {
        Write-Warning "Error: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $archive_spa) {
            $archive_spa.Dispose()
        }
        if (-not $v8_snapshot -and $null -eq $xpuiJsEntry) {
            Write-Warning "v8_context_snapshot file not found, cannot create xpui.js"
            Exit-WithMessage
        }
    }

    $spaBackup = Join-Path (Join-Path $spInstallPath 'Apps') 'xpui.bak'
    $spaBackupExists = Test-Path -Path $spaBackup

    # Backup original xpui.spa before patching
    $zip = [System.IO.Compression.ZipFile]::Open($spaPatchPath, 'update')
    $entry = $zip.GetEntry('xpui.js')
    $reader = New-Object System.IO.StreamReader($entry.Open())
    $xpuiContent = $reader.ReadToEnd()
    $reader.Close()


    if ($installedVer -ge [version]'1.2.70.253') {
        
        $binaryBackup = $dll_bak 
        $binaryTarget = $spDllFile
    }
    else {
        $binaryBackup = $exe_bak
        $binaryTarget = $spExeFile
    }

    If ($xpuiContent -match 'patched_by_dtspotifyblock') {
        $zip.Dispose()    

        if ($spaBackupExists) {
            Remove-Item $spaPatchPath -Recurse -Force
            Rename-Item $spaBackup $spaPatchPath

            if (Test-Path -Path $binaryBackup) {
                Remove-Item $binaryTarget -Recurse -Force
                Rename-Item $binaryBackup $binaryTarget
            }
            if ($binaryBackup -eq $dll_bak) {

                if (Test-Path -Path $exe_bak) {
                    Remove-Item $spExeFile -Recurse -Force
                    Rename-Item $exe_bak $spExeFile
                }
                else {
                    $binary_exe_bak = [System.IO.Path]::GetFileName($exe_bak)
                    Write-Warning ("Backup copy {0} not found. Please reinstall Spotify and run DTSpotifyBlock again" -f $binary_exe_bak)
                    Pause
                    Exit
                }

                if (Test-Path -Path $chrome_elf_bak) {
                    Remove-Item $chrome_elf -Recurse -Force
                    Rename-Item $chrome_elf_bak $chrome_elf
                }
                else {
                    $binary_chrome_elf_bak = [System.IO.Path]::GetFileName($chrome_elf_bak)
                    Write-Warning ("Backup copy {0} not found. Please reinstall Spotify and run DTSpotifyBlock again" -f $binary_chrome_elf_bak)
                    Pause
                    Exit
                }

            }
        }
        else {
            Write-Host ($lang).NoRestore`n
            Pause
            Exit
        }

    }
    $zip.Dispose()
    Copy-Item $spaPatchPath $spaBackup

    if ($binaryBackup -eq $dll_bak) {
        Copy-Item $spExeFile $exe_bak
        Copy-Item $chrome_elf $chrome_elf_bak

    }

    # Remove all languages except En and Ru from xpui.spa
    if ($hasRuLang) {
        $null = [Reflection.Assembly]::LoadWithPartialName('System.IO.Compression')
        $stream = New-Object IO.FileStream($spaPatchPath, [IO.FileMode]::Open)
        $mode = [IO.Compression.ZipArchiveMode]::Update
        $zip_xpui = New-Object IO.Compression.ZipArchive($stream, $mode)

        ($zip_xpui.Entries | Where-Object { $_.FullName -match "i18n" -and $_.FullName -inotmatch "(ru|en.json|longest)" }) | foreach { $_.Delete() }

        $zip_xpui.Dispose()
        $stream.Close()
        $stream.Dispose()
    }

    # Block premium upsell UI and enable fullscreen mode
    if (!($premium)) {
        extract -counts 'one' -method 'zip' -name 'xpui.js' -helper 'OffadsonFullscreen'
        Add-Summary "Ad blocking enabled"
    }

    Show-Step "Patching Spotify JS/CSS"
    # Apply forced feature flag overrides
    extract -counts 'one' -method 'zip' -name 'xpui.js' -helper 'ForcedExp' -add $patchManifest.others.byDTSB.add

    # Inject section blocker for podcasts/ads on home screen
    if ($hidePodcasts -or $adsections_off -or $canvashome_off) {

        $section = Get -Url (Get-BaseUrl -e "/inject/sectionBlock.js")
        
        if ($section -ne $null) {

            $blockMode = switch ($true) {
                ($hidePodcasts -and $adsections_off -and $canvashome_off) { "'all'"; break }
                ($hidePodcasts -and $adsections_off) { "['podcast', 'section']"; break }
                ($hidePodcasts -and $canvashome_off) { "['podcast', 'canvas']"; break }
                ($adsections_off -and $canvashome_off) { "['section', 'canvas']"; break }
                $hidePodcasts { "'podcast'"; break }
                $adsections_off { "'section'"; break }
                $canvashome_off { "'canvas'"; break }
                default { $null } 
            }

            if (!($blockMode -eq "'canvas'" -and [version]$installedVer -le [version]"1.2.44.405")) {
                $section = $section -replace "sectionBlock\(data, ''\)", "sectionBlock(data, $blockMode)"
                injection -p $spaPatchPath -f "dtspotifyblock-inject" -n "sectionBlock.js" -c $section
                if ($hidePodcasts)    { Add-Summary "Podcasts hidden from home" }
                if ($adsections_off)  { Add-Summary "Ad sections hidden from home" }
                if ($canvashome_off)  { Add-Summary "Canvas home disabled" }
            }
        }

    }
	
    # Inject listening history tracker (Goofy)
    if ($urlform_goofy -and $idbox_goofy) {

        $goofy = Get -Url (Get-BaseUrl -e "/inject/goofyHistory.js")
        
        if ($goofy -ne $null) {
            injection -p $spaPatchPath -f "dtspotifyblock-inject" -n "goofyHistory.js" -c $goofy
            Add-Summary "Listening history tracker (Goofy)"
        }
    }

    # Apply custom lyrics color theme
    if ($lyrics_stat) {
        $rulesContent = Get -Url (Get-BaseUrl -e "/themes/lyrics-color/rules.css")
        $colorsContent = Get -Url (Get-BaseUrl -e "/themes/lyrics-color/colors.css")

        $colorsContent = $colorsContent -replace '{{past}}', "$($patchManifest.others.themelyrics.theme.$lyrics_stat.pasttext)"
        $colorsContent = $colorsContent -replace '{{current}}', "$($patchManifest.others.themelyrics.theme.$lyrics_stat.current)"
        $colorsContent = $colorsContent -replace '{{next}}', "$($patchManifest.others.themelyrics.theme.$lyrics_stat.next)"
        $colorsContent = $colorsContent -replace '{{hover}}', "$($patchManifest.others.themelyrics.theme.$lyrics_stat.hover)"
        $colorsContent = $colorsContent -replace '{{background}}', "$($patchManifest.others.themelyrics.theme.$lyrics_stat.background)"
        $colorsContent = $colorsContent -replace '{{musixmatch}}', "$($patchManifest.others.themelyrics.theme.$lyrics_stat.maxmatch)"

        injection -p $spaPatchPath -f "dtspotifyblock-inject/lyrics-color" -n @("rules.css", "colors.css") -c @($rulesContent, $colorsContent) -i "rules.css"

    }
    extract -counts 'one' -method 'zip' -name 'xpui.js' -helper 'VariousofXpui-js'
    
    if ([version]$installedVer -ge [version]"1.1.85.884" -and [version]$installedVer -le [version]"1.2.57.463") {
        
        if ([version]$installedVer -ge [version]"1.2.45.454") { $typefile = "xpui.js" }

        else { $typefile = "xpui-routes-search.js" }

        extract -counts 'one' -method 'zip' -name $typefile -helper "Fixjs"
    }
    

    if ($devtools -and [version]$installedVer -ge [version]"1.2.35.663") {
        extract -counts 'one' -method 'zip' -name 'xpui-routes-desktop-settings.js' -helper 'Dev' 
    }

    # Remove collaborator icon from playlist view
    if (!($hide_col_icon_off) -and !($exp_spotify)) {
        extract -counts 'one' -method 'zip' -name 'xpui-routes-playlist.js' -helper 'Collaborators'
    }

    # Inject DTSpotifyBlock info into about dialog
    extract -counts 'one' -method 'zip' -name 'xpui-desktop-modals.js' -helper 'Discriptions'

    # Disable Sentry error reporting 
    if ( [version]$installedVer -le [version]"1.2.56.502" ) {  
        $fileName = 'vendor~xpui.js'

    }
    else { $fileName = 'xpui.js' }

    extract -counts 'one' -method 'zip' -name $fileName -helper 'DisableSentry'

    # Minify all JS files
    extract -counts 'more' -name '*.js' -helper 'MinJs'

    # Patch xpui.css with premium UI hiding rules
    if (!($premium)) {
        # Hide download block
        if ([version]$installedVer -ge [version]"1.2.30.1135") {
            $cssAdditions += $patchManifest.others.downloadquality.add
        }
        # Hide download icon on different pages
        $cssAdditions += $patchManifest.others.downloadicon.add
        # Hide submenu item "download"
        $cssAdditions += $patchManifest.others.submenudownload.add
        # Hide very high quality streaming
        if ([version]$installedVer -le [version]"1.2.29.605") {
            $cssAdditions += $patchManifest.others.veryhighstream.add
        }
    }
    # block subfeeds
    if ($blockMode -match "all" -or $blockMode -match "podcast") {
        $cssAdditions += $patchManifest.others.block_subfeeds.add
    }
    # scrollbar indent fixes
    $cssAdditions += $patchManifest.others.'fix-scrollbar'.add

    if ($null -ne $cssAdditions ) { extract -counts 'one' -method 'zip' -name 'xpui.css' -add $cssAdditions }
    
    # Patch CSS for old Spotify UI compatibility
    $contents = "fix-old-theme"
    extract -counts 'one' -method 'zip' -name 'xpui.css' -helper "FixCss"

    # Strip RTL rules and minify CSS files
    extract -counts 'more' -name '*.css' -helper 'Cssmin'
    
    # Minify license page

    extract -counts 'one' -method 'zip' -name 'licenses.html' -helper 'HtmlLicMin'
    # Minify blank page
    extract -counts 'one' -method 'zip' -name 'blank.html' -helper 'HtmlBlank'
    
    if ($hasRuLang) {
        # Additional translation of the ru.json file
        extract -counts 'more' -name '*ru.json' -helper 'RuTranslate'
    }
    # Minify all JS fileson
    extract -counts 'more' -name '*.json' -helper 'MinJson'
}

# Delete all files except "en" and "ru"
if ($hasRuLang) {
    $patch_lang = "$spInstallPath\locales"
    Remove-Item $patch_lang -Exclude *en*, *ru* -Recurse
}

# Create desktop shortcut for Spotify
$ErrorActionPreference = 'SilentlyContinue' 

if (!($no_shortcut)) {

    $desktopPath = Get-DesktopPath

    If (!(Test-Path $desktopPath\Spotify.lnk)) {
        $source = $spExeFile
        $target = "$desktopPath\Spotify.lnk"
        $WorkingDir = $spInstallPath
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($target)
        $Shortcut.WorkingDirectory = $WorkingDir
        $Shortcut.TargetPath = $source
        $Shortcut.Save()      
    }
}

# Create Start Menu shortcut
If (!(Test-Path $start_menu)) {
    $source = $spExeFile
    $target = $start_menu
    $WorkingDir = $spInstallPath
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($target)
    $Shortcut.WorkingDirectory = $WorkingDir
    $Shortcut.TargetPath = $source
    $Shortcut.Save()      
}

$ANSI = [Text.Encoding]::GetEncoding(1251)
$old = [IO.File]::ReadAllText($binaryTarget, $ANSI)

$regex1 = $old -notmatch $patchManifest.others.binary.block_update.add
$regex2 = $old -notmatch $patchManifest.others.binary.block_slots.add
$regex3 = $old -notmatch $patchManifest.others.binary.block_slots_2.add
$regex4 = $old -notmatch $patchManifest.others.binary.block_slots_3.add
$regex5 = $old -notmatch $(
    if ([version]$installedVer -gt [version]'1.2.73.474') { $patchManifest.others.binary.block_gabo2.add }
    else { $patchManifest.others.binary.block_gabo.add }
)

if ($regex1 -and $regex2 -and $regex3 -and $regex4 -and $regex5) {

    if (Test-Path -LiteralPath $binaryBackup) { 
        Remove-Item $binaryBackup -Recurse -Force
        Start-Sleep -Milliseconds 150
    }
    copy-Item $binaryTarget $binaryBackup
}

if (-not (Test-Path -LiteralPath $binaryBackup)) {
    $name_binary = [System.IO.Path]::GetFileName($binaryBackup)
    Write-Warning ("Backup copy {0} not found. Please reinstall Spotify and run DTSpotifyBlock again" -f $name_binary)
    Pause
    Exit
}

Show-Step "Applying binary patches"
# Bypass PE signature check
if ($binaryBackup -eq $dll_bak) {
    Reset-Dll-Sign -FilePath $spDllFile

    $files = @("Spotify.dll", "Spotify.exe", "chrome_elf.dll")
    Remove-Signature-FromFiles $files
}

# Apply binary-level patches to Spotify executable
extract -counts 'exe' -helper 'Binary'
Add-Summary "Binary patch applied"

# Patch login screen for older Spotify builds
if ([version]$installedVer -ge [version]"1.1.87.612" -and [version]$installedVer -le [version]"1.2.5.1006") {
    $login_spa = Join-Path (Join-Path $spInstallPath 'Apps') 'login.spa'
    Get -Url (Get-BaseUrl -e "/assets/login.spa") -OutputPath $login_spa
}

Show-Step "Finalizing"
# Disable Spotify auto-launch on Windows startup
if ($DisableStartup) {
    $prefsPath = Join-Path $spInstallPath 'prefs'
    $keyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $keyName = "Spotify"

    # delete key in registry
    if (Get-ItemProperty -Path $keyPath -Name $keyName -ErrorAction SilentlyContinue) {
        Remove-ItemProperty -Path $keyPath -Name $keyName -Force
    } 

    # create new prefs
    if (-not (Test-Path $prefsPath)) {
        $content = @"
app.autostart-configured=true
app.autostart-mode="off"
"@
        [System.IO.File]::WriteAllLines($prefsPath, $content, [System.Text.UTF8Encoding]::new($false))
    }
    
    # update prefs
    else {
        $content = [System.IO.File]::ReadAllText($prefsPath)
        if (-not $content.EndsWith("`n")) {
            $content += "`n"
        }
        $content += 'app.autostart-mode="off"'
        [System.IO.File]::WriteAllText($prefsPath, $content, [System.Text.UTF8Encoding]::new($false))
    }

    Add-Summary "Startup disabled"
}

if ($block_update_on)  { Add-Summary "Auto-updates blocked" }
if ($new_theme)        { Add-Summary "New UI theme applied" }
if ($devtools)         { Add-Summary "DevTools enabled" }
if ($rightsidebarcolor){ Add-Summary "Right sidebar coloring on" }
if ($premium)          { Add-Summary "Premium mode (no ad patches)" }
if ($lyrics_stat)      { Add-Summary "Lyrics theme: $lyrics_stat" }

# Launch Spotify after patching if requested
if ($start_spoti) { Start-Process -WorkingDirectory $spInstallPath -FilePath $spExeFile }

# Show colored summary box
Show-Summary

Write-Host ($lang).InstallComplete`n -ForegroundColor Green

# Save log if requested
Save-Log
