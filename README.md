<h1 align="center">
  <img src=".github/Pic/logo.png" alt="DTSpotifyBlock" width="450"/>
</h1>

<p align="center">
  <b>DTSpotifyBlock</b> — A free, open-source Spotify patcher for Windows.<br>
  Removes ads, blocks updates, and unlocks extra features — no Premium needed.
</p>

<p align="center">
  <a href="https://github.com/DT-Deville/DTSpotifyBlock/releases"><img src="https://img.shields.io/github/v/release/DT-Deville/DTSpotifyBlock?color=1DB954&label=Latest%20Release&style=flat-square" alt="Latest Release"/></a>
  <img src="https://img.shields.io/badge/Platform-Windows-0078d4?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/github/stars/DT-Deville/DTSpotifyBlock?style=flat-square&color=1DB954"/>
</p>

---

## What is DTSpotifyBlock?

DTSpotifyBlock is a PowerShell-based patcher for the **Spotify desktop app on Windows**. It patches Spotify directly on your machine — no third-party servers, no account login, no subscription needed.

Once patched, Spotify runs completely ad-free. You keep all your playlists, liked songs, and account data — everything is stored in the cloud and untouched by the patcher.

> ⚠️ This tool is for **educational and personal use only**. Use at your own risk.

---

## Features

- 🚫 **Removes all audio and banner ads**
- 🔒 **Blocks Spotify auto-updates** (so patches stay applied)
- 🎵 **Supports new and classic Spotify UI themes**
- 🏠 **Hides podcasts and promoted content** from the home feed
- 💾 **Backup & restore** — safely revert to original Spotify at any time
- 🔇 **Disable Spotify on startup** — stops it from launching with Windows
- 🧹 **Cache cleaner** — frees up disk space with one flag
- 📋 **Install logging** — saves a full log to your Desktop for debugging
- ✅ **Patch status checker** — check if Spotify is currently patched
- ⚡ **Silent mode** — fully automated, zero prompts, great for batch use

---

## Requirements

- Windows 10 / 11 / 12
- PowerShell 5.1 or higher
- Spotify **desktop app** (NOT the Microsoft Store version)

---

## Quick Install

Open **PowerShell as Administrator** and run one of the following:

### New Theme (recommended)
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -new_theme"
```

### Old / Classic Theme
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -v 1.2.13.661.ga588f749-4064 -confirm_spoti_recomended_over -block_update_on"
```

### Silent / Fully Automated
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -new_theme -silent"
```

Or just double-click one of the included **`.bat` files** for a no-setup install.

---

## All Flags

| Flag | Description |
|------|-------------|
| `-new_theme` | Use the modern Spotify UI |
| `-silent` | Fully automated — answers all prompts automatically |
| `-check` | Check if Spotify is currently patched (no changes made) |
| `-clean_cache` | Clear Spotify cache files and free up disk space |
| `-backup_restore` | Restore original Spotify files from backup |
| `-log` | Save a full install log to your Desktop |
| `-podcasts_off` | Hide podcasts and episodes from the home feed |
| `-adsections_off` | Hide promoted ad-like sections from home |
| `-block_update_on` | Prevent Spotify from auto-updating |
| `-DisableStartup` | Stop Spotify from launching on Windows boot |
| `-premium` | Skip ad patches (use this if you have Spotify Premium) |
| `-devtools` | Enable DevTools inside Spotify |
| `-lyrics_stat` | Apply a custom lyrics color theme |
| `-cache_limit` | Set a Spotify cache size limit (in MB) |
| `-uninstall` | Remove DTSpotifyBlock patches only |
| `-uninstall_clean` | Remove patches AND wipe all Spotify cache and preferences |

---

## Uninstall

```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -uninstall"
```

For a full clean wipe (removes patch + cache + preferences):
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -uninstall_clean"
```

---

## How It Works

1. Downloads the correct Spotify version (or uses the one already installed)
2. Creates a backup of the original Spotify files
3. Patches `xpui.spa` (Spotify's UI bundle) to remove ads and apply feature overrides
4. Applies binary-level patches to `Spotify.exe` and `chrome_elf.dll`
5. Optionally blocks auto-updates and disables startup

All patching happens **locally on your machine**. Nothing is sent to any external server except downloading Spotify and the patch manifest from this GitHub repo.

---

## FAQ

**Will this get my account banned?**
There are no known cases of bans from using this type of patcher. However, it does violate Spotify's Terms of Service, so use at your own risk.

**Do I need to re-patch after Spotify updates?**
If you used `-block_update_on`, Spotify won't update automatically. If it does update, just run the installer again.

**My antivirus flagged the script — is it safe?**
PowerShell patching scripts often trigger false positives. You can review the full source code in `install.ps1` before running.

**Does this work on Mac or Linux?**
No. DTSpotifyBlock is Windows-only.

---

---

<p align="center">
  <sub>Made with ☕ by DT-Deville &nbsp;·&nbsp; Licensed under MIT</sub>
</p>
