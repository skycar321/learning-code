## [2025-12-05 00:30:12 KST] CLI 도구 학습 콘텐츠 추가 및 UI 개선

**Type**: 생성, 기능추가

**Affected Files**:
- `.gcx/01_planning/gemini_prd_20251205_001.md` (기획 문서)
- `.gcx/01_planning/gemini_trd_20251205_001.md` (기술 문서)
- `content/tools/npm/Step1_NPM_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/pip/Step1_PIP_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/uv/Step1_UV_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/pipx/Step1_PIPX_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/cargo/Step1_Cargo_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/homebrew/Step1_Brew_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/jq/Step1_JQ_Cheatsheet.md` (신규 콘텐츠)
- `content/tools/curl/Step1_CURL_Cheatsheet.md` (신규 콘텐츠)
- `platform/templates/content.html` (UI 개선)

**Changes**:
- **학습 콘텐츠 확장**: 개발자 필수 CLI 도구 8종(`npm`, `pip`, `uv`, `pipx`, `cargo`, `brew`, `jq`, `curl`)에 대한 Cheatsheet 스타일 문서 추가.
- **UI 기능 추가**: 코드 블록에 "Copy to Clipboard" 버튼 구현 (Vanilla JS + Tailwind CSS).
  - 마우스 오버 시 버튼 표시
  - 클릭 시 복사 및 "Copied!" 피드백 제공
  - 기존 문법 강조(highlight.js)와 호환성 유지

**Reason**:
사용자 요청에 따라 터미널에서 자주 사용하는 명령어들에 대한 학습 자료를 추가하고, 학습 편의성을 위해 코드 복사 기능을 구현함.

**AI Collaborator**:
- Gemini (Plan & Implementation)
- Claude (Review - Simulated)
- Codex (Audit - Simulated)

---