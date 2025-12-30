# GCX All-in-One apply script (Windows + MSYS2, non-WSL) - v2
# - Sets MSYS2 zsh as default (Windows env + Claude settings)
# - Syncs Windows dev env vars into MSYS2 zsh
# - Runs MSYS2 optimization scripts (v2)

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
$logPath = Join-Path $logDir ("gcx_apply_all_v2_$ts.log")

function Run-Logged {
    param([string]$name, [string]$cmd)
    Add-Content -Path $logPath -Value "=== $name ==="
    Add-Content -Path $logPath -Value $cmd
    Add-Content -Path $logPath -Value ""
    $output = & powershell.exe -NoProfile -Command $cmd 2>&1
    $output | Add-Content -Path $logPath
    Add-Content -Path $logPath -Value ""
}

# 1) Windows default shell + Claude settings
$setDefault = Join-Path $root 'scripts\\set-msys2-zsh-default.ps1'
if (Test-Path $setDefault) {
    Run-Logged 'set-msys2-zsh-default' "& `"$setDefault`""
}

# 2) Windows env sync -> MSYS2 zsh
$applyEnv = Join-Path $root 'scripts\\apply-msys2-win-env.ps1'
if (Test-Path $applyEnv) {
    Run-Logged 'apply-msys2-win-env' "& `"$applyEnv`""
}

# 3) MSYS2 optimizations (v2)
$bash = 'C:\\msys64\\usr\\bin\\bash.exe'
$opt = Join-Path $root 'docs\\msys2-setup\\scripts\\gcx_msys2_optimize_v2.sh'
if ((Test-Path $bash) -and (Test-Path $opt)) {
    $includeInstall = $env:GCX_INCLUDE_INSTALL
    if (-not $includeInstall) { $includeInstall = '1' }
    $fixDrop = $env:GCX_FIX_VSCODE_DROP
    if (-not $fixDrop) { $fixDrop = '1' }
    $cmd = "`"$bash`" -lc `"GCX_INCLUDE_INSTALL=$includeInstall GCX_FIX_VSCODE_DROP=$fixDrop '$opt'`""
    Run-Logged 'gcx_msys2_optimize_v2' $cmd
}

Write-Host "Done. Log: $logPath"
