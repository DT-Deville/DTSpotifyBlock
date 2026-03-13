# DTSpotifyBlock — Install Commands

## New Theme (recommended)
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -new_theme"
```

## Silent / Fully Automated
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -new_theme -silent"
```

## Check Patch Status (no changes)
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -check"
```

## Clear Spotify Cache
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -clean_cache"
```

## Restore from Backup
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -backup_restore"
```

## Save Install Log to Desktop
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -new_theme -log"
```

## Uninstall + Full Clean Wipe
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -uninstall_clean"
```

## Old / Classic Theme
```powershell
iex "& { $(iwr -useb 'https://raw.githubusercontent.com/DT-Deville/DTSpotifyBlock/refs/heads/main/install.ps1') } -v 1.2.13.661.ga588f749-4064 -confirm_spoti_recomended_over -block_update_on"
```

## All Flags
| Flag | What it does |
|------|-------------|
| `-new_theme` | Modern Spotify UI |
| `-silent` | Fully automated, zero prompts |
| `-check` | Check patch status without making changes |
| `-clean_cache` | Clear Spotify cache files |
| `-backup_restore` | Restore original files from backup |
| `-log` | Save install log to Desktop |
| `-uninstall_clean` | Remove patch + wipe all Spotify data |
| `-podcasts_off` | Hide podcasts from home |
| `-block_update_on` | Block Spotify auto-updates |
| `-premium` | Skip ad-blocking (Premium users) |
| `-DisableStartup` | Disable Spotify on boot |
| `-uninstall` | Remove DTSpotifyBlock only |
