# Revert Windows developer env variable sync to MSYS2 zsh.

$ErrorActionPreference = 'Stop'

function Find-RepoRoot {
    param([string]$start)
    $root = $start
    while ($root -and -not (Test-Path (Join-Path $root '.claude\\settings.json'))) {
        $root = Split-Path -Parent $root
    }
    return $root
}

$root = Find-RepoRoot -start $PSScriptRoot
if (-not $root) {
    Write-Error 'Could not find .claude/settings.json. Run this script from inside the repo.'
    exit 1
}

$backupPath = Join-Path $root '.gcx\\state\\msys2_win_env_backup.json'
if (-not (Test-Path $backupPath)) {
    Write-Error "Backup not found: $backupPath"
    exit 1
}

$backup = Get-Content -Path $backupPath -Raw | ConvertFrom-Json

$envFile = $backup.envFile
$envFileBackup = $backup.envFileBackup
$zshrcPath = $backup.zshrcPath
$zshrcBackup = $backup.zshrcBackup

# Restore env file
if ($envFileBackup -and (Test-Path $envFileBackup)) {
    Copy-Item -Path $envFileBackup -Destination $envFile -Force
    Write-Host "Restored env file from: $envFileBackup"
} elseif ($envFile -and (Test-Path $envFile)) {
    Remove-Item -Path $envFile -Force
    Write-Host "Removed env file: $envFile"
}

# Restore zshrc
if ($zshrcBackup -and (Test-Path $zshrcBackup)) {
    Copy-Item -Path $zshrcBackup -Destination $zshrcPath -Force
    Write-Host "Restored zshrc from: $zshrcBackup"
} elseif ($zshrcPath -and (Test-Path $zshrcPath)) {
    $content = Get-Content -Path $zshrcPath -Raw
    $blockStart = '# >>> GCX Windows Env (auto-generated)'
    $blockEnd = '# <<< GCX Windows Env'
    $pattern = [regex]::Escape($blockStart) + '.*?' + [regex]::Escape($blockEnd)
    $newContent = [regex]::Replace($content, $pattern, '', 'Singleline')
    if ($newContent -ne $content) {
        Set-Content -Path $zshrcPath -Value $newContent -Encoding UTF8
        Write-Host "Removed GCX Windows Env block from: $zshrcPath"
    }
}

Write-Host 'Done. Restart MSYS2 zsh sessions to apply.'
