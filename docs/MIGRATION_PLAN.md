# Skills & Commands 마이그레이션 계획

**버전**: 1.1
**작성일**: 2025-11-30
**목적**: Gemini-Claude 협업 시스템을 Codex를 포함한 멀티 AI 협업 시스템으로 확장

---

## Phase별 AI 역할 분담

### Phase 1 (gc-): Gemini-Claude 협업
- **Gemini 우선 담당**: 화면 설계, UI 디자인, 사용자 경험(UX)
- **Claude 담당**: 구현 및 검증

### Phase 2 (cx-): Codex-Claude 협업
- **Codex 우선 담당**: 코드 품질 검증, 리팩토링, 대규모 마이그레이션
- **Claude 담당**: 구현

### Phase 3 (gcx-): Gemini-Claude-Codex 3-AI 협업
- **Gemini 우선 담당**: 화면 설계, UI 디자인
- **Claude 담당**: 구현
- **Codex 우선 담당**: 코드 품질 검증, 리팩토링

---

## Phase 1: 이름 변경 계획 (5개 항목)

기존 Gemini 중심 네이밍을 Gemini-Claude 협업 명시로 변경

### 1.1 implementation-executor → gc-executor

**변경 대상**:
- Skill 폴더: `~/.claude/skills/implementation-executor/` → `~/.claude/skills/gc-executor/`
- SKILL.md: `~/.claude/skills/implementation-executor/SKILL.md`
  - `name: implementation-executor` → `name: gc-executor`
  - `description:` Gemini(화면 설계/UI 우선) + Claude(구현 및 검증) 명시
- PHASES.md: 내용은 그대로 유지
- Command: `~/.claude/commands/nam/implementation-executor.md` → `~/.claude/commands/nam/gc-executor.md`
  - `name: nam:implementation-executor` → `name: nam:gc-executor`
  - `description:` Gemini가 UI/화면 설계 우선 담당 명시

**완료 상태**: [ ]

---

### 1.2 implementation-executor-lite → gc-executor-lite

**변경 대상**:
- Skill 폴더: `~/.claude/skills/implementation-executor-lite/` → `~/.claude/skills/gc-executor-lite/`
- SKILL.md: `~/.claude/skills/implementation-executor-lite/SKILL.md`
  - `name: implementation-executor-lite` → `name: gc-executor-lite`
  - `description:` Gemini(화면 설계/UI 우선) + Claude(구현 및 검증) 명시
- PHASES.md: 내용은 그대로 유지
- Command: `~/.claude/commands/nam/implementation-executor-lite.md` → `~/.claude/commands/nam/gc-executor-lite.md`
  - `name: nam:implementation-executor-lite` → `name: nam:gc-executor-lite`
  - `description:` Gemini가 UI/화면 설계 우선 담당 명시

**완료 상태**: [ ]

---

### 1.3 project-planner → gc-planner

**변경 대상**:
- Skill 폴더: `~/.claude/skills/project-planner/` → `~/.claude/skills/gc-planner/`
- SKILL.md: `~/.claude/skills/project-planner/SKILL.md`
  - `name: project-planner` → `name: gc-planner`
  - `description:` Gemini(전략 분석 우선) + Claude(검증 및 보완) 명시
- PHASES.md: 내용은 그대로 유지
- Command: `~/.claude/commands/nam/project-planner.md` → `~/.claude/commands/nam/gc-planner.md`
  - `name: nam:project-planner` → `name: nam:gc-planner`
  - `description:` Gemini-Claude 협업 명시

**완료 상태**: [ ]

---

### 1.4 project-planner-lite → gc-planner-lite

**변경 대상**:
- Skill 폴더: `~/.claude/skills/project-planner-lite/` → `~/.claude/skills/gc-planner-lite/`
- SKILL.md: `~/.claude/skills/project-planner-lite/SKILL.md`
  - `name: project-planner-lite` → `name: gc-planner-lite`
  - `description:` Gemini(전략 분석 우선) + Claude(검증 및 보완) 명시
- PHASES.md: 내용은 그대로 유지
- Command: `~/.claude/commands/nam/project-planner-lite.md` → `~/.claude/commands/nam/gc-planner-lite.md`
  - `name: nam:project-planner-lite` → `name: nam:gc-planner-lite`
  - `description:` Gemini-Claude 협업 명시

**완료 상태**: [ ]

---

### 1.5 gemini-task → gc-task

**변경 대상**:
- Command: `~/.claude/commands/nam/gemini-task.md` → `~/.claude/commands/nam/gc-task.md`
  - `name: nam:gemini-task` → `name: nam:gc-task`
  - `description:` 범용 Gemini-Claude Loop 명시
- README: `~/.claude/commands/nam/gemini-task-README.md` → `~/.claude/commands/nam/gc-task-README.md`

**완료 상태**: [ ]

---

## Phase 2: Codex 협업 신규 생성 (5개 항목)

Claude + Codex 협업 구조, 코드 품질 검증 특화

### 2.1 cx-executor (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/cx-executor/`
- SKILL.md:
  - `name: cx-executor`
  - `description:` Codex(코드 품질 검증/리팩토링/마이그레이션 우선) + Claude(구현) 협업
- PHASES.md: `gc-executor/PHASES.md` 기반으로 생성
  - Gemini 호출 → Codex 호출로 변경
  - Codex CLI 패턴:
    ```bash
    codex exec -m [모델] "프롬프트..."
    # 또는 full-auto 모드:
    codex full-auto -m [모델] "프롬프트..."
    ```
  - 코드 품질 검증에 특화된 프롬프트로 수정
- Command: `~/.claude/commands/nam/cx-executor.md`

**완료 상태**: [ ]

---

### 2.2 cx-executor-lite (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/cx-executor-lite/`
- SKILL.md:
  - `name: cx-executor-lite`
  - `description:` Codex(코드 품질 검증 우선) + Claude(구현) 경량 협업
- PHASES.md: `gc-executor-lite/PHASES.md` 기반
  - Gemini → Codex로 변경
- Command: `~/.claude/commands/nam/cx-executor-lite.md`

**완료 상태**: [ ]

---

### 2.3 cx-planner (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/cx-planner/`
- SKILL.md:
  - `name: cx-planner`
  - `description:` Codex(리팩토링 전략, 대규모 마이그레이션 계획 특화) + Claude(검증) 협업
- PHASES.md: `gc-planner/PHASES.md` 기반
  - Gemini → Codex로 변경
  - 리팩토링/마이그레이션 중심 프롬프트
- Command: `~/.claude/commands/nam/cx-planner.md`

**완료 상태**: [ ]

---

### 2.4 cx-planner-lite (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/cx-planner-lite/`
- SKILL.md:
  - `name: cx-planner-lite`
  - `description:` Codex(리팩토링 전략 우선) + Claude(검증) 경량 협업
- PHASES.md: `gc-planner-lite/PHASES.md` 기반
  - Gemini → Codex로 변경
- Command: `~/.claude/commands/nam/cx-planner-lite.md`

**완료 상태**: [ ]

---

### 2.5 cx-task (신규)

**생성 대상**:
- Command: `~/.claude/commands/nam/cx-task.md`
  - `name: nam:cx-task`
  - `description:` 범용 Codex-Claude Loop - 코드 품질 검증, 리팩토링, 마이그레이션 중심
- README: `~/.claude/commands/nam/cx-task-README.md`
- `gc-task.md` 기반으로 생성, Gemini → Codex로 변경

**완료 상태**: [ ]

---

## Phase 3: 3-AI 협업 신규 생성 (5개 항목)

Gemini(전략) + Claude(구현) + Codex(검증) 협업 구조, 최고 품질 달성

### 3.1 gcx-executor (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/gcx-executor/`
- SKILL.md:
  - `name: gcx-executor`
  - `description:` Gemini(화면설계 우선) + Claude(구현) + Codex(코드품질 우선) 3-AI 협업
- PHASES.md:
  - Step 1: Gemini 화면 설계 및 요구사항 분석
  - Step 2: Claude 구현
  - Step 3: Codex 코드 품질 검증 및 리팩토링 제안
  - Step 4: Claude 최종 수정 및 완료
- Command: `~/.claude/commands/nam/gcx-executor.md`

**완료 상태**: [x] (2025-12-01 10:30:22 KST 완료)

---

### 3.2 gcx-executor-lite (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/gcx-executor-lite/`
- SKILL.md:
  - `name: gcx-executor-lite`
  - `description:` Gemini(화면설계 우선) + Claude(구현) + Codex(코드품질 우선) 3-AI 경량 협업
- PHASES.md: 3단계 간소화 버전
- Command: `~/.claude/commands/nam/gcx-executor-lite.md`

**완료 상태**: [x] (2025-12-01 10:30:22 KST 완료)

---

### 3.3 gcx-planner (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/gcx-planner/`
- SKILL.md:
  - `name: gcx-planner`
  - `description:` Gemini(요구사항 분석) + Claude(계획 수립) + Codex(기술 검증) 3-AI 협업
- PHASES.md:
  - Step 1: Gemini PRD 초안
  - Step 2: Claude 검증 및 보완
  - Step 3: Codex 기술 타당성 검증
  - Step 4: 최종 문서화
- Command: `~/.claude/commands/nam/gcx-planner.md`

**완료 상태**: [x] (2025-12-01 10:30:22 KST 완료)

---

### 3.4 gcx-planner-lite (신규)

**생성 대상**:
- Skill 폴더: `~/.claude/skills/gcx-planner-lite/`
- SKILL.md:
  - `name: gcx-planner-lite`
  - `description:` Gemini(요구사항) + Claude(계획) + Codex(검증) 3-AI 경량 협업
- PHASES.md: 2단계 간소화 버전
- Command: `~/.claude/commands/nam/gcx-planner-lite.md`

**완료 상태**: [x] (2025-12-01 10:30:22 KST 완료)

---

### 3.5 gcx-task (신규)

**생성 대상**:
- Command: `~/.claude/commands/nam/gcx-task.md`
  - `name: nam:gcx-task`
  - `description:` 범용 3-AI Loop - 최고 품질 달성
- README: `~/.claude/commands/nam/gcx-task-README.md`
- Gemini 분석 → Claude 구현 → Codex 검증 루프

**완료 상태**: [x] (2025-12-01 10:30:22 KST 완료)

---

## 공통 생성 가이드

### Codex CLI 호출 패턴

```bash
# 기본 실행
codex exec -m [모델] "프롬프트 내용..."

# Full-Auto 모드 (자동 실행)
codex full-auto -m [모델] "프롬프트 내용..."

# JSON 출력 모드
codex exec -m [모델] --json "프롬프트..."

# Resume 모드 (이전 작업 이어서)
codex resume [작업ID]
```

**사용 가능 모델**:- `gpt-5.1-codex-max` (최고 품질, 권장) - 깊은 추론과 빠른 속도, Codex 최적화 플래그십- `gpt-5.1-codex` (균형) - Codex 최적화, 대부분의 프로젝트에 적합- `gpt-5.1-codex-mini` (빠른 처리) - 저렴하고 빠름, 단순한 검증용- `gpt-5.1` (범용) - 일반 추론 작업, 코드 외 작업 포함 시

---

### 3-AI 협업 워크플로우 템플릿

```markdown
## Step 1: Gemini - 화면 설계 및 전략 분석
**Gemini 우선 담당 영역**: 화면 설계, UI 디자인, 사용자 경험(UX)

bash 명령:
```bash
gemini -m gemini-2.5-pro "
[프롬프트 내용]
화면 설계, UI 컴포넌트 구조, 사용자 플로우를 우선적으로 설계해주세요.
"
```

Claude 검증:
- Gemini 화면 설계 검토
- UI/UX 개선 사항 제안
- 사용자 승인 받기

---

## Step 2: Claude - 구현
- Step 1의 화면 설계를 기반으로 코드 구현
- 컴포넌트 작성, 라우팅 설정, 상태 관리 등

---

## Step 3: Codex - 코드 품질 검증 및 리팩토링
**Codex 우선 담당 영역**: 코드 품질 검증, 리팩토링, 대규모 마이그레이션

bash 명령:
```bash
codex exec -m gpt-5.1-codex-max "
[프롬프트 내용]
코드 품질 검증, 리팩토링 제안, 보안 이슈 점검을 우선적으로 수행해주세요.
"
```

Claude 검증:
- Codex 검증 결과 검토
- 개선 사항 적용
- 사용자 승인 받기

---

## Step 4: Claude - 최종 수정 및 완료
- Codex 제안사항 반영
- 최종 테스트 및 문서화
- MODIFY_HISTORY.md에 AI Collaborator 기록
```

---

### AI Collaborator 기록 형식

**Gemini-Claude (gc-) 협업**:
```markdown
**AI Collaborator**:
- Suggested by: Gemini
- Model used: gemini-2.5-flash / gemini-2.5-pro / gemini-3-pro-preview
- Validation status: PASS / APPROVED / 이슈 발견 후 수정
- Review notes: "[Claude의 주요 피드백 내용]"
```

**Codex-Claude (cx-) 협업**:
```markdown
**AI Collaborator**:
- Suggested by: Codex
- Model used: gpt-5.1-codex-max / gpt-5.1-codex-mini
- Validation status: PASS / APPROVED / 이슈 발견 후 수정
- Review notes: "[Claude의 주요 피드백 내용]"
```

**3-AI (gcx-) 협업**:
```markdown
**AI Collaborator**:
- Step 1 - Gemini:
  - Model used: gemini-2.5-pro
  - Validation status: PASS
  - Review notes: "화면 설계 검증 완료"
- Step 2 - Claude: 구현 완료
- Step 3 - Codex:
  - Model used: gpt-5.1-codex-max
  - Validation status: PASS
  - Review notes: "코드 품질 검증 완료, 리팩토링 제안 반영"
```

---

## 실행 가이드

### Phase 1 실행 명령어

```bash
# 1. 폴더 이름 변경
cd ~/.claude/skills
mv implementation-executor gc-executor
mv implementation-executor-lite gc-executor-lite
mv project-planner gc-planner
mv project-planner-lite gc-planner-lite

# 2. Command 파일 이름 변경
cd ~/.claude/commands/nam
mv implementation-executor.md gc-executor.md
mv implementation-executor-lite.md gc-executor-lite.md
mv project-planner.md gc-planner.md
mv project-planner-lite.md gc-planner-lite.md
mv gemini-task.md gc-task.md
mv gemini-task-README.md gc-task-README.md

# 3. SKILL.md 및 Command.md 내용 수정
# (각 파일의 name, description 수정 필요)
```

### Phase 2 실행 명령어

```bash
# 1. 기존 gc- 폴더 복사
cd ~/.claude/skills
cp -r gc-executor cx-executor
cp -r gc-executor-lite cx-executor-lite
cp -r gc-planner cx-planner
cp -r gc-planner-lite cx-planner-lite

# 2. Command 파일 복사
cd ~/.claude/commands/nam
cp gc-executor.md cx-executor.md
cp gc-executor-lite.md cx-executor-lite.md
cp gc-planner.md cx-planner.md
cp gc-planner-lite.md cx-planner-lite.md
cp gc-task.md cx-task.md
cp gc-task-README.md cx-task-README.md

# 3. PHASES.md에서 gemini 호출 → codex 호출로 변경
# (각 파일 수동 편집 필요)
```

### Phase 3 실행 명령어

```bash
# 1. 새 폴더 생성
cd ~/.claude/skills
mkdir gcx-executor gcx-executor-lite gcx-planner gcx-planner-lite

# 2. Command 파일 생성
cd ~/.claude/commands/nam
touch gcx-executor.md gcx-executor-lite.md
touch gcx-planner.md gcx-planner-lite.md
touch gcx-task.md gcx-task-README.md

# 3. 3-AI 워크플로우에 맞게 PHASES.md 작성
# (Gemini → Claude → Codex → Claude 순서)
```

---

## 검증 체크리스트

### Phase 1 검증
- [ ] 모든 폴더 이름 변경 완료
- [ ] 모든 Command 파일 이름 변경 완료
- [ ] SKILL.md의 name 필드 업데이트 완료
- [ ] Command.md의 name 필드 업데이트 완료
- [ ] description에 AI 역할 분담 명시 완료
- [ ] `/nam:gc-planner-lite` 실행 테스트 성공

### Phase 2 검증
- [ ] cx- 폴더 5개 생성 완료
- [ ] cx- Command 파일 5개 생성 완료
- [ ] PHASES.md에서 gemini → codex 변경 완료
- [ ] Codex CLI 호출 패턴 적용 완료
- [ ] `/nam:cx-planner-lite` 실행 테스트 성공

### Phase 3 검증
- [ ] gcx- 폴더 5개 생성 완료
- [ ] gcx- Command 파일 5개 생성 완료
- [ ] 3-AI 워크플로우 PHASES.md 작성 완료
- [ ] AI Collaborator 3단계 기록 형식 적용 완료
- [ ] `/nam:gcx-planner-lite` 실행 테스트 성공

---

## Gemini vs Codex 선택 가이드

| **사용자 요청사항** | **추천 AI** | **이유** |
|---------------------|-------------|----------|
| **화면 설계, UI 디자인** | **Gemini (우선)** | UI/UX 설계, 컴포넌트 구조 설계에 특화 |
| **코드 품질 검증** | **Codex (우선)** | 정적 분석, 코드 리뷰, 품질 검증에 특화 |
| **리팩토링** | **Codex (우선)** | 코드 구조 개선, 최적화 제안에 특화 |
| **대규모 마이그레이션** | **Codex (우선)** | 레거시 코드 분석, 마이그레이션 전략 수립에 특화 |
| 신규 프로젝트 기획 | Gemini | 요구사항 분석, 전략 수립에 강점 |
| API 설계 | Gemini | 시스템 아키텍처, API 설계에 강점 |
| 데이터베이스 설계 | Gemini | 스키마 설계, 관계 정의에 강점 |
| 알고리즘 최적화 | Codex | 성능 분석, 알고리즘 개선에 강점 |
| 보안 감사 | Codex | 취약점 분석, 보안 이슈 검출에 특화 |
| 테스트 코드 작성 | Codex | 테스트 커버리지, 엣지 케이스 발견에 강점 |
| 문서 자동 생성 | Gemini | 기술 문서, 주석 작성에 강점 |
| 코드 스타일 통일 | Codex | Linting, Formatting 규칙 적용에 강점 |
| 최고 품질 필요 시 | **gcx- (3-AI)** | Gemini 설계 + Claude 구현 + Codex 검증 |

**선택 기준**:
1. **화면/UI 중심** → `gc-` 시리즈 (Gemini-Claude)
2. **코드 품질/리팩토링 중심** → `cx-` 시리즈 (Codex-Claude)
3. **최고 품질 필요** → `gcx-` 시리즈 (3-AI 협업)
4. **빠른 프로토타입** → `-lite` 버전
5. **프로덕션 레디** → 풀 버전

---

## 참고 자료

### 기존 파일 위치
- Skills: `~/.claude/skills/`
- Commands: `~/.claude/commands/nam/`
- MODIFY_HISTORY: `C:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/MODIFY_HISTORY.md`

### 관련 문서
- Korean-Explanatory Output Style: `~/.claude/output-styles/Korean-Explanatory.md`
- Claude Code 문서: https://docs.claude.com/

### AI CLI 도구
- Gemini CLI: `gemini -m [모델] "프롬프트..."`
- Codex CLI: `codex exec -m [모델] "프롬프트..."`

---

**마이그레이션 진행 상황**: 10 / 15 완료 (66.7%)

- Phase 1 (gc- 시리즈): 0 / 5 완료
- Phase 2 (cx- 시리즈): 5 / 5 완료 ✓
- Phase 3 (gcx- 시리즈): 5 / 5 완료 ✓
