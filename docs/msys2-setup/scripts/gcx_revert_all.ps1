# GCX All-in-One revert script (Windows + MSYS2)
# - Reverts Windows env sync
# - Reverts MSYS2 default zsh settings
# - Restores MSYS2 config files from latest backup

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

$logDir = Join-Path $root '.gcx\\state'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$logPath = Join-Path $logDir ("gcx_revert_all_$ts.log")

function Run-Logged {
    param([string]$name, [string]$cmd)
    Add-Content -Path $logPath -Value "=== $name ==="
    Add-Content -Path $logPath -Value $cmd
    Add-Content -Path $logPath -Value ""
    $output = & powershell.exe -NoProfile -Command $cmd 2>&1
    $output | Add-Content -Path $logPath
    Add-Content -Path $logPath -Value ""
}

# 1) Revert Windows env sync
$revertEnv = Join-Path $root 'scripts\\revert-msys2-win-env.ps1'
if (Test-Path $revertEnv) {
    Run-Logged 'revert-msys2-win-env' "& `"$revertEnv`""
}

# 2) Revert Windows default zsh settings
$revertDefault = Join-Path $root 'scripts\\revert-msys2-zsh-default.ps1'
if (Test-Path $revertDefault) {
    Run-Logged 'revert-msys2-zsh-default' "& `"$revertDefault`""
}

# 3) Revert MSYS2 config files
$bash = 'C:\\msys64\\usr\\bin\\bash.exe'
$revertOpt = Join-Path $root 'docs\\msys2-setup\\scripts\\gcx_msys2_optimize_revert.sh'
if (Test-Path $bash -and Test-Path $revertOpt) {
    $cmd = "`"$bash`" -lc `"'$revertOpt'`""
    Run-Logged 'gcx_msys2_optimize_revert' $cmd
}

Write-Host "Done. Log: $logPath"
