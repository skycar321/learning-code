Git Stash & 부분 커밋 실습 키트 (Step-by-Step)
====================================================

[특징]
- 100% 로컬 동작: 인터넷 연결이 필요 없습니다.
- 안전한 실습: 언제든지 '00_reset'으로 처음 상태로 되돌릴 수 있습니다.
- 소스 코드 분리: 'src_samples' 폴더에서 버전별 전체 코드를 미리 볼 수 있습니다.

[이것은 무엇인가요?]
이 폴더는 Git의 고급 기능들을 안전하게 연습해볼 수 있는 독립된 실습실입니다.
1. 한 파일에 여러 기능(SR1 + SR2)이 섞였을 때 처리 방법
2. 원격 저장소 업데이트로 인한 충돌 해결 방법 (상/중/하단 3단 콤보 충돌)
3. `git stash`와 `git add -p`를 이용한 정밀한 커밋 분리

[파일 구성]
- 00_reset.{sh,ps1}            : 초기화 (실습 데이터 완전 삭제)
- 01_setup.{sh,ps1}            : 기초 환경(원격 저장소 등) 생성
- 02_colleague_update.{sh,ps1} : 동료가 먼저 코드를 수정한 상황 시뮬레이션
- 03_user_mixed_work.{sh,ps1}  : 내 로컬에 작업을 뒤섞어 놓는 스크립트
- FINAL_GUIDE.md               : 실제 실습 가이드 문서 (my-workspace 안에서 진행)
- src_samples/                 : 단계별 소스 코드 원본 (참고용)
  ├─ CoreService_v1.0.java
  ├─ CoreService_v1.1_Remote.java
  ├─ CoreService_Local_Mixed.java
  └─ CoreService_Resolved.java (정답지)

[실행 전 필수 확인]
Git이 설치되어 있어야 하며, 사용자 설정이 되어 있어야 합니다.
  git config --global user.name "Your Name"
  git config --global user.email "you@example.com"

[실행 방법]
1. 터미널(Git Bash 또는 PowerShell)을 열고 이 폴더로 이동합니다.
2. 스크립트를 순서대로 실행하세요 (00 -> 01 -> 02 -> 03).
   (각 스크립트가 실행 후 다음 명령어를 친절하게 알려줍니다)

   Git Bash 예시:
     bash 00_reset.sh
     bash 01_setup.sh
     bash 02_colleague_update.sh
     bash 03_user_mixed_work.sh

   PowerShell 예시:
     powershell -ExecutionPolicy Bypass -File .\00_reset.ps1
     powershell -ExecutionPolicy Bypass -File .\01_setup.ps1
     ...

3. 준비가 끝나면 작업 공간으로 이동해서 실습을 시작합니다:
   cd my-workspace
   (이제 FINAL_GUIDE.md 파일을 열고 따라하세요)
