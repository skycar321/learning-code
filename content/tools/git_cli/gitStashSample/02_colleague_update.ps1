$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RemoteDir = Join-Path $ScriptDir "remote-repo.git"
$ColleagueDir = Join-Path $ScriptDir "colleague-workspace"
$SrcDir = Join-Path $ScriptDir "src_samples"

if (!(Test-Path $RemoteDir)) {
  Write-Host "❌ Missing setup. Run: powershell -ExecutionPolicy Bypass -File .\01_setup.ps1"
  exit 1
}

Write-Host ">>> [02_colleague_update] Updating dev branch (Complex v1.1 Update)..."
Set-Location $ColleagueDir
git checkout dev

# 동료의 CoreService v1.1 복사
Copy-Item (Join-Path $SrcDir "CoreService_v1.1_Remote.java") "CoreService.java"

git add CoreService.java
git commit -m "feat: improve commonUtil performance (v1.1) and add archiving"
git push origin dev

Write-Host ">>> [02_colleague_update] Done."
Write-Host "✅ Next (PowerShell): powershell -ExecutionPolicy Bypass -File .\03_user_mixed_work.ps1"
Write-Host "✅ Next (Git Bash): bash 03_user_mixed_work.sh"
