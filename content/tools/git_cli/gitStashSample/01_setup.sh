#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REMOTE_DIR="$SCRIPT_DIR/remote-repo.git"
COLLEAGUE_DIR="$SCRIPT_DIR/colleague-workspace"
SRC_DIR="$SCRIPT_DIR/src_samples"

if [ -d "$REMOTE_DIR" ] || [ -d "$COLLEAGUE_DIR" ]; then
  echo "❌ 이미 실습 환경이 존재합니다. 다음 명령어로 초기화해주세요: bash 00_reset.sh"
  exit 1
fi

echo ">>> [01_setup] 가상 원격 저장소(Remote Repo)를 생성합니다..."
git init --bare "$REMOTE_DIR"

echo ">>> [01_setup] 동료의 작업 공간을 초기화합니다..."
mkdir -p "$COLLEAGUE_DIR"
cd "$COLLEAGUE_DIR"
git init
git remote add origin "$REMOTE_DIR"

# 초기 코드 생성 (v1.0)
cp "$SRC_DIR/CoreService_v1.0.java" CoreService.java

git add .
git commit -m "Initial commit"
git branch -M main
git push -u origin main

git checkout -b dev
git push -u origin dev

echo ">>> [01_setup] 완료되었습니다."
echo "✅ 다음 단계 (Git Bash): bash 02_colleague_update.sh"
echo "✅ 다음 단계 (PowerShell): powershell -ExecutionPolicy Bypass -File .\02_colleague_update.ps1"
