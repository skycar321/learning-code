$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$RemoteDir = Join-Path $ScriptDir "remote-repo.git"
$ColleagueDir = Join-Path $ScriptDir "colleague-workspace"
$SrcDir = Join-Path $ScriptDir "src_samples"

if ((Test-Path $RemoteDir) -or (Test-Path $ColleagueDir)) {
  Write-Host "❌ 이미 실습 환경이 존재합니다. 다음 명령어로 초기화해주세요: powershell -ExecutionPolicy Bypass -File .\00_reset.ps1"
  exit 1
}

Write-Host ">>> [01_setup] 가상 원격 저장소(Remote Repo)를 생성합니다..."
git init --bare $RemoteDir

Write-Host ">>> [01_setup] 동료의 작업 공간을 초기화합니다..."
New-Item -ItemType Directory -Force $ColleagueDir | Out-Null
Set-Location $ColleagueDir
git init
git remote add origin $RemoteDir

# 초기 코드 생성 (v1.0)
Copy-Item (Join-Path $SrcDir "CoreService_v1.0.java") "CoreService.java"

git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main

git checkout -b dev
git push -u origin dev

Write-Host ">>> [01_setup] 완료되었습니다."
Write-Host "✅ 다음 단계 (PowerShell): powershell -ExecutionPolicy Bypass -File .\02_colleague_update.ps1"
Write-Host "✅ 다음 단계 (Git Bash): bash 02_colleague_update.sh"
