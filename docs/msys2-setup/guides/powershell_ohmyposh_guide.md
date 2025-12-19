# PowerShell + Oh My Posh 완벽 가이드 (Windows 네이티브)

## 개요
**Windows 네이티브** 방식으로 zsh처럼 이쁘고 강력한 터미널 만들기
- ✅ Windows 완벽 호환 (가장 안정적)
- ✅ Oh My Posh로 zsh 테마 구현
- ✅ 리눅스 alias 많음 (ls, cd, cat 등)
- ⚠️ 진짜 bash 스크립트는 실행 불가

---

## 1단계: PowerShell 7 설치

### 방법 1: winget (추천)
```powershell
# 관리자 권한 PowerShell에서 실행
winget install Microsoft.PowerShell
```

### 방법 2: 수동 설치
https://github.com/PowerShell/PowerShell/releases 에서 `.msi` 다운로드

### 확인
```powershell
pwsh --version
# PowerShell 7.4.0 이상이면 OK
```

---

## 2단계: Windows Terminal 설치 (이미 있으면 스킵)

```powershell
winget install Microsoft.WindowsTerminal
```

---

## 3단계: Oh My Posh 설치

```powershell
# 관리자 권한으로 실행
winget install JanDeDobbeleer.OhMyPosh -s winget
```

### 확인
```powershell
oh-my-posh --version
```

---

## 4단계: Nerd Fonts 설치

Oh My Posh는 아이콘을 표시하기 위해 Nerd Font가 필요합니다.

### 방법 1: Oh My Posh 명령어로 설치
```powershell
# 관리자 권한 필요
oh-my-posh font install
# 메뉴에서 "Meslo" 선택 (추천)
```

### 방법 2: 수동 설치
```powershell
# CaskaydiaCove Nerd Font 설치
oh-my-posh font install CascadiaCode
```

### Windows Terminal 폰트 설정
1. Windows Terminal 실행
2. `Ctrl + ,` (설정 열기)
3. `settings.json` 탭
4. 다음 추가:

```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "MesloLGM Nerd Font",
        "size": 10
      }
    }
  }
}
```

---

## 5단계: PowerShell 프로필 설정

### 프로필 파일 위치 확인
```powershell
echo $PROFILE
# 출력 예시: C:\Users\Nam\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

### 프로필 파일 생성 (없으면)
```powershell
# 파일이 없는 경우 생성
New-Item -Path $PROFILE -Type File -Force
```

### 프로필 편집
```powershell
# 메모장으로 열기
notepad $PROFILE

# 또는 VSCode로 열기
code $PROFILE
```

### 기본 설정 추가
```powershell
# Oh My Posh 초기화 (테마: atomic)
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\atomic.omp.json" | Invoke-Expression

# PSReadLine 설정 (명령어 자동완성)
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# UTF-8 인코딩 설정
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 유용한 alias
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name vim -Value notepad
Set-Alias -Name grep -Value Select-String

# Git alias (Git 설치 필요)
function gs { git status }
function ga { git add $args }
function gc { git commit -m $args }
function gp { git push }
function gl { git log --oneline --graph --decorate }

# 디렉토리 이동 단축
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# 현재 디렉토리를 탐색기로 열기
function explorer-here { explorer . }
Set-Alias -Name open -Value explorer-here

# 빠른 프로필 편집
function Edit-Profile { code $PROFILE }

# 프로필 리로드
function Reload-Profile { . $PROFILE }
```

### 프로필 적용
```powershell
# 현재 세션에 적용
. $PROFILE
```

---

## 6단계: Oh My Posh 테마 변경

### 사용 가능한 테마 보기
```powershell
Get-ChildItem -Path "$env:POSH_THEMES_PATH\*.omp.json" | Select-Object Name
```

### 테마 미리보기
```powershell
# 모든 테마 순회하며 미리보기
Get-ChildItem -Path "$env:POSH_THEMES_PATH\*.omp.json" | ForEach-Object {
    Write-Host "--- $($_.BaseName) ---"
    oh-my-posh init pwsh --config $_.FullName | Invoke-Expression
    Write-Host ""
}
```

### 인기 테마 추천
1. **atomic** - 깔끔하고 정보가 많음
2. **powerlevel10k_rainbow** - zsh의 Powerlevel10k와 유사
3. **agnoster** - 클래식하고 심플
4. **paradox** - 미니멀
5. **tokyo** - 모던하고 컬러풀

### 테마 변경 (예: powerlevel10k_rainbow)
```powershell
# $PROFILE 파일에서 이 줄 수정
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_rainbow.omp.json" | Invoke-Expression
```

---

## 7단계: 추가 모듈 설치

### Terminal-Icons (파일 아이콘 표시)
```powershell
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
```

프로필에 추가:
```powershell
Import-Module Terminal-Icons
```

### PSFzf (파일 검색)
```powershell
Install-Module -Name PSFzf -Repository PSGallery -Force
```

프로필에 추가:
```powershell
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
```

### z (디렉토리 점프)
```powershell
Install-Module -Name z -Repository PSGallery -Force
```

프로필에 추가:
```powershell
Import-Module z
```

사용법:
```powershell
# 자주 가는 디렉토리 기록
cd C:\Users\Nam\Documents
cd C:\Projects\MyApp

# 나중에 빠르게 이동
z MyApp  # C:\Projects\MyApp로 이동
z Doc    # C:\Users\Nam\Documents로 이동
```

---

## 8단계: Windows Terminal 설정 최적화

### settings.json 고급 설정

```json
{
  "$schema": "https://aka.ms/terminal-profiles-schema",
  "defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
  "copyOnSelect": true,
  "copyFormatting": false,
  "profiles": {
    "defaults": {
      "font": {
        "face": "MesloLGM Nerd Font",
        "size": 10
      },
      "cursorShape": "bar",
      "colorScheme": "One Half Dark",
      "useAcrylic": false,
      "acrylicOpacity": 0.8,
      "padding": "8, 8, 8, 8"
    },
    "list": [
      {
        "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
        "name": "PowerShell 7",
        "source": "Windows.Terminal.PowershellCore",
        "commandline": "pwsh.exe -NoLogo",
        "icon": "C:\\Program Files\\PowerShell\\7\\assets\\Powershell_av_colors.ico",
        "startingDirectory": "%USERPROFILE%",
        "colorScheme": "One Half Dark"
      }
    ]
  },
  "schemes": [
    {
      "name": "One Half Dark",
      "background": "#282C34",
      "foreground": "#DCDFE4"
    }
  ],
  "actions": [
    { "command": "find", "keys": "ctrl+shift+f" },
    { "command": { "action": "splitPane", "split": "horizontal" }, "keys": "alt+shift+-" },
    { "command": { "action": "splitPane", "split": "vertical" }, "keys": "alt+shift+plus" }
  ]
}
```

---

## 9단계: 리눅스 명령어 alias 추가

### 프로필에 추가
```powershell
# 리눅스 스타일 명령어
function touch { New-Item -ItemType File -Name $args }
function which { Get-Command $args | Select-Object -ExpandProperty Definition }
function head { Get-Content $args -Head 10 }
function tail { Get-Content $args -Tail 10 }
function cat { Get-Content $args }
function rm { Remove-Item $args }
function mv { Move-Item $args }
function cp { Copy-Item $args }
function mkdir { New-Item -ItemType Directory -Name $args }

# 시스템 정보
function info {
    Write-Host "OS: $(systeminfo | Select-String 'OS Name')"
    Write-Host "Version: $(systeminfo | Select-String 'OS Version')"
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
}

# 빠른 네트워크 테스트
function speedtest { Test-Connection 8.8.8.8 -Count 4 }

# 프로세스 관리
function pgrep { Get-Process | Where-Object { $_.Name -like "*$args*" } }
function pkill { Stop-Process -Name $args }

# 디렉토리 크기
function du {
    Get-ChildItem | ForEach-Object {
        $size = if ($_.PSIsContainer) {
            (Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        } else {
            $_.Length / 1MB
        }
        [PSCustomObject]@{
            Name = $_.Name
            SizeMB = [math]::Round($size, 2)
        }
    } | Format-Table -AutoSize
}
```

---

## 10단계: 실행 정책 설정 (권한 문제 해결)

만약 스크립트 실행이 안 된다면:

```powershell
# 관리자 권한 PowerShell에서 실행
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 비교: PowerShell vs Git Bash vs MSYS2

| 기능 | PowerShell 7 + Oh My Posh | Git Bash | MSYS2 |
|------|----------------------------|----------|-------|
| Windows 네이티브 | ✅ 완벽 | ⚠️ MINGW | ⚠️ MINGW |
| 리눅스 명령어 | ⚠️ Alias (70%) | ✅ 네이티브 (70%) | ✅ 네이티브 (90%) |
| bash 스크립트 | ❌ 실행 불가 | ✅ 실행 가능 | ✅ 실행 가능 |
| 패키지 관리자 | ⚠️ winget (Windows용) | ❌ 없음 | ✅ Pacman |
| 꾸미기 (테마) | ✅ Oh My Posh | ⚠️ 제한적 | ✅ oh-my-zsh |
| 속도 | ⚡ 매우 빠름 | ⚡ 빠름 | ⚡ 빠름 |
| Windows 도구 통합 | ✅ 완벽 | ⚠️ 제한적 | ⚠️ 제한적 |
| .NET 통합 | ✅ 네이티브 | ❌ 불가 | ❌ 불가 |
| 학습 곡선 | ⚠️ PowerShell 문법 | ✅ bash | ✅ bash |

---

## 트러블슈팅

### 1. 테마가 깨져보임
```powershell
# Nerd Font 설치 확인
oh-my-posh font install

# Windows Terminal 폰트 설정 확인
# settings.json에 "face": "MesloLGM Nerd Font" 있는지 확인
```

### 2. 명령어 실행 느림
```powershell
# 프로필 성능 측정
Measure-Command { . $PROFILE }

# 느린 모듈 비활성화 (프로필에서 주석 처리)
# Import-Module PSFzf  # 느리면 주석 처리
```

### 3. Oh My Posh 초기화 오류
```powershell
# 환경변수 확인
echo $env:POSH_THEMES_PATH

# 재설치
winget uninstall JanDeDobbeleer.OhMyPosh
winget install JanDeDobbeleer.OhMyPosh
```

### 4. 한글 깨짐
```powershell
# 프로필에 추가
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### 5. Git 명령어 느림
```powershell
# Git 상태 표시 비활성화 (Oh My Posh 설정)
# ~/.mytheme.omp.json 복사 후 수정
oh-my-posh config export --output ~/.mytheme.omp.json

# 파일 편집:
# "fetch_status": false 추가

# 프로필에서 사용
oh-my-posh init pwsh --config ~/.mytheme.omp.json | Invoke-Expression
```

---

## 고급: 커스텀 Oh My Posh 테마 만들기

```powershell
# 기존 테마 복사
oh-my-posh config export --output ~/my-custom-theme.omp.json

# 편집
code ~/my-custom-theme.omp.json
```

**기본 구조 예시**:
```json
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "path",
          "style": "powerline",
          "powerline_symbol": "\uE0B0",
          "foreground": "#ffffff",
          "background": "#61AFEF",
          "properties": {
            "style": "folder"
          }
        },
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "\uE0B0",
          "foreground": "#193549",
          "background": "#95ffa4"
        }
      ]
    }
  ]
}
```

프로필에서 사용:
```powershell
oh-my-posh init pwsh --config ~/my-custom-theme.omp.json | Invoke-Expression
```

---

## 완성된 프로필 예시

**전체 `$PROFILE` 파일**:

```powershell
# Oh My Posh 초기화
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_rainbow.omp.json" | Invoke-Expression

# UTF-8 인코딩
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# PSReadLine 설정
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# 모듈
Import-Module Terminal-Icons
Import-Module z

# Alias
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name vim -Value notepad
Set-Alias -Name grep -Value Select-String

# Git 함수
function gs { git status }
function ga { git add $args }
function gc { git commit -m $args }
function gp { git push }
function gl { git log --oneline --graph --decorate --all }
function gd { git diff $args }

# 유틸리티 함수
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function touch { New-Item -ItemType File -Name $args }
function which { Get-Command $args | Select-Object -ExpandProperty Definition }
function open { explorer . }

# 프로필 관리
function Edit-Profile { code $PROFILE }
function Reload-Profile { . $PROFILE }

# 시작 메시지
Write-Host "PowerShell 7 + Oh My Posh 🚀" -ForegroundColor Cyan
Write-Host "Type 'Edit-Profile' to customize" -ForegroundColor Gray
```

---

## 결론

PowerShell + Oh My Posh는 **Windows 네이티브** 방식으로:
- ✅ zsh처럼 이쁘고 강력
- ✅ Windows 도구와 완벽 통합
- ✅ .NET 개발자에게 최적
- ⚠️ bash 스크립트는 실행 불가 (이 경우 MSYS2 추천)

**추천 대상**:
- Windows 환경에서 주로 작업하는 개발자
- .NET, C# 개발자
- Windows 도구 통합이 중요한 경우
- bash 스크립트 실행이 필요 없는 경우
