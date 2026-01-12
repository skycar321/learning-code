$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RemoteDir = Join-Path $ScriptDir "remote-repo.git"
$LocalDir = Join-Path $ScriptDir "my-workspace"
$SrcDir = Join-Path $ScriptDir "src_samples"

if (!(Test-Path $RemoteDir)) {
    Write-Host "❌ Missing setup. Run previous steps."
    exit 1
}

if (Test-Path $LocalDir) {
    Write-Host "❌ Local workspace already exists. Run: powershell -ExecutionPolicy Bypass -File .\00_reset.ps1"
    exit 1
}

Write-Host ">>> [03_user_mixed_work] Setting up user workspace..."
Set-Location $ScriptDir
git clone $RemoteDir $LocalDir
Set-Location $LocalDir

git reset --hard HEAD~1

# 사용자의 CoreService (v1.0 기반 + SR1/SR2 혼합) 복사
Copy-Item (Join-Path $SrcDir "CoreService_Local_Mixed.java") "CoreService.java"

@'
# SR2 Configuration
report.type=pdf
report.margin=10px
'@ | Set-Content -Encoding UTF8 "sr2_config.properties"

Write-Host ">>> [03_user_mixed_work] Done."
Write-Host "⚠️  [Scenario] 3-Way Conflict Prepared (Top, Middle, Bottom)."
Write-Host "✅ Next (PowerShell): cd .\my-workspace"
