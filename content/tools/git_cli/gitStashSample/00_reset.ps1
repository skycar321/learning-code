$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $ScriptDir

$RemoteDir = Join-Path $ScriptDir "remote-repo.git"
$LocalDir = Join-Path $ScriptDir "my-workspace"
$ColleagueDir = Join-Path $ScriptDir "colleague-workspace"

Write-Host ">>> [00_reset] 이전 실습 데이터를 삭제하고 있습니다..."
@($RemoteDir, $LocalDir, $ColleagueDir) | ForEach-Object {
    if (Test-Path $_) { Remove-Item -Recurse -Force $_ }
}

Write-Host ">>> ✅ 초기화가 완료되었습니다."
Write-Host "다음 단계 (PowerShell): powershell -ExecutionPolicy Bypass -File .\01_setup.ps1"
Write-Host "다음 단계 (Git Bash): bash 01_setup.sh"