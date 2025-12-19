# Revert MSYS2 UCRT64 Zsh default changes (User scope) and restore Claude settings.
# - Restores env vars from .gcx/state/msys2_shell_backup.json
# - Restores .claude/settings.json from backup

$ErrorActionPreference = 'Stop'

# Find project root (folder containing .claude/settings.json)
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
while ($root -and -not (Test-Path (Join-Path $root '.claude\settings.json'))) {
    $root = Split-Path -Parent $root
}
if (-not $root) {
    Write-Error 'Could not find .claude/settings.json. Run this script from inside the repo.'
    exit 1
}

$backupPath = Join-Path $root '.gcx\state\msys2_shell_backup.json'
if (-not (Test-Path $backupPath)) {
    Write-Error "Backup not found: $backupPath"
    exit 1
}

$backup = Get-Content -Path $backupPath -Raw | ConvertFrom-Json

# Restore env vars
function Restore-Env($name, $value) {
    if ($null -eq $value -or $value -eq '') {
        [Environment]::SetEnvironmentVariable($name, $null, 'User')
    } else {
        [Environment]::SetEnvironmentVariable($name, $value, 'User')
    }
}

Restore-Env 'SHELL' $backup.env.SHELL
Restore-Env 'MSYSTEM' $backup.env.MSYSTEM
Restore-Env 'CHERE_INVOKING' $backup.env.CHERE_INVOKING
Restore-Env 'Path' $backup.env.PATH

# Restore settings.json
$settingsBackup = $backup.settingsBackup
if ($settingsBackup -and (Test-Path $settingsBackup)) {
    Copy-Item -Path $settingsBackup -Destination (Join-Path $root '.claude\settings.json') -Force
    Write-Host "Restored settings.json from: $settingsBackup"
} else {
    Write-Warning 'settings.json backup file not found. Env vars restored only.'
}

Write-Host 'Done.'
Write-Host 'Restart Claude Code / terminals to apply changes.'
