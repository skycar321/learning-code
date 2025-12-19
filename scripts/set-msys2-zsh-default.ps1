# Set MSYS2 UCRT64 Zsh as default (User scope) and update Claude settings.
# - Backs up current user env vars and .claude/settings.json
# - Updates user PATH to include MSYS2 bins if missing
# - Writes backup metadata to .gcx/state/msys2_shell_backup.json

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

$settingsPath = Join-Path $root '.claude\settings.json'
$backupDir = Join-Path $root '.gcx\state'
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

# Detect zsh
$zshCmd = Get-Command zsh -ErrorAction SilentlyContinue
$zshPath = if ($zshCmd) { $zshCmd.Source } else { 'C:\msys64\usr\bin\zsh.exe' }
if (-not (Test-Path $zshPath)) {
    Write-Error "zsh.exe not found. Expected at: $zshPath"
    exit 1
}

$bashPath = 'C:\msys64\usr\bin\bash.exe'
if (-not (Test-Path $bashPath)) {
    # Best-effort fallback
    $bashPath = $null
}

# Backup settings.json
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$settingsBackup = Join-Path $backupDir ("settings.json.bak-$timestamp")
Copy-Item -Path $settingsPath -Destination $settingsBackup -Force

# Backup env
$envBackup = @{
    timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    settingsBackup = $settingsBackup
    env = @{
        SHELL = [Environment]::GetEnvironmentVariable('SHELL', 'User')
        MSYSTEM = [Environment]::GetEnvironmentVariable('MSYSTEM', 'User')
        CHERE_INVOKING = [Environment]::GetEnvironmentVariable('CHERE_INVOKING', 'User')
        PATH = [Environment]::GetEnvironmentVariable('Path', 'User')
    }
}
$backupPath = Join-Path $backupDir 'msys2_shell_backup.json'
$envBackup | ConvertTo-Json -Depth 6 | Set-Content -Path $backupPath -Encoding UTF8

# Update .claude/settings.json (use Python to avoid PowerShell JSON parsing issues)
$pyPath = Join-Path $backupDir "update_settings_json.py"
@'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
zsh = sys.argv[2]
bash = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] not in ("", "null", "None") else None
data = json.loads(path.read_text(encoding="utf-8"))
data.setdefault("terminal", {}).setdefault("shell", {}).setdefault("path", {})
data["terminal"]["shell"]["default"] = "zsh"
data["terminal"]["shell"]["fallback"] = "bash"
data["terminal"]["shell"]["path"]["zsh"] = zsh
if bash:
    data["terminal"]["shell"]["path"]["bash"] = bash
path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
'@ | Set-Content -Path $pyPath -Encoding UTF8

$bashArg = if ($bashPath) { $bashPath } else { "null" }
python $pyPath $settingsPath $zshPath $bashArg
Remove-Item -Path $pyPath -Force

# Update user env vars
[Environment]::SetEnvironmentVariable('SHELL', $zshPath, 'User')
[Environment]::SetEnvironmentVariable('MSYSTEM', 'UCRT64', 'User')
[Environment]::SetEnvironmentVariable('CHERE_INVOKING', '1', 'User')

# Update user PATH
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not $userPath) { $userPath = '' }
$pathParts = $userPath -split ';' | Where-Object { $_ -ne '' }
$additions = @('C:\msys64\usr\bin', 'C:\msys64\ucrt64\bin')
foreach ($p in $additions) {
    if ($pathParts -notcontains $p) {
        $pathParts += $p
    }
}
$newPath = ($pathParts -join ';')
[Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

Write-Host 'Done.'
Write-Host "Backup saved: $backupPath"
Write-Host 'Restart Claude Code / terminals to apply changes.'
