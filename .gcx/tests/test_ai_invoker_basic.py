"""
AI Invoker Basic Test
======================

AI Invoker 모듈 기본 테스트 (실제 AI 호출 없음)
"""

import sys
from pathlib import Path

# .gcx/lib 모듈 임포트 경로 추가
lib_path = Path(__file__).parent.parent / "lib"
sys.path.insert(0, str(lib_path))

from ai_invokers import CodexInvoker, ClaudeInvoker, GeminiInvoker


def test_invoker_initialization():
    """Invoker 초기화 테스트"""
    print("=" * 50)
    print("AI Invoker Initialization Test")
    print("=" * 50)

    # Codex
    codex = CodexInvoker()
    assert codex.default_model == "gpt-5.1-codex"
    assert codex.default_reasoning == "high"  # NOT xhigh!
    print("[OK] CodexInvoker initialized")
    print(f"  - Default model: {codex.default_model}")
    print(f"  - Default reasoning: {codex.default_reasoning}")

    # Claude
    claude = ClaudeInvoker()
    assert claude.default_model == "sonnet"
    print("[OK] ClaudeInvoker initialized")
    print(f"  - Default model: {claude.default_model}")

    # Gemini
    gemini = GeminiInvoker()
    assert gemini.default_model == "gemini-2.0-flash-exp"
    print("[OK] GeminiInvoker initialized")
    print(f"  - Default model: {gemini.default_model}")


def test_prompt_formatting():
    """프롬프트 포맷팅 테스트"""
    print("\n" + "=" * 50)
    print("Prompt Formatting Test")
    print("=" * 50)

    codex = CodexInvoker()

    # TDD 모드
    tdd_prompt = codex._format_prompt("Create user model", "tdd", "high")
    assert "TDD" in tdd_prompt or "테스트 먼저" in tdd_prompt
    assert "Jest/Vitest" in tdd_prompt
    print("[OK] TDD prompt formatting")

    # Security 모드
    security_prompt = codex._format_prompt("Audit authentication", "security", "high")
    assert "OWASP" in security_prompt or "보안 감사" in security_prompt
    print("[OK] Security prompt formatting")

    # Audit 모드
    audit_prompt = codex._format_prompt("Review code", "audit", "high")
    assert "순환 복잡도" in audit_prompt or "Over-engineering" in audit_prompt
    print("[OK] Audit prompt formatting")


def test_code_block_extraction():
    """코드 블록 추출 테스트"""
    print("\n" + "=" * 50)
    print("Code Block Extraction Test")
    print("=" * 50)

    codex = CodexInvoker()

    sample_output = """
Here is the TypeScript code:

```typescript
function add(a: number, b: number): number {
    return a + b;
}
```

And here is Python:

```python
def add(a, b):
    return a + b
```
"""

    blocks = codex._extract_code_blocks(sample_output)
    assert len(blocks) == 2
    print(f"[OK] Extracted {len(blocks)} code blocks")

    # 특정 언어 필터링
    ts_blocks = codex._extract_code_blocks(sample_output, "typescript")
    assert len(ts_blocks) == 1
    assert "function add" in ts_blocks[0]
    print("[OK] Language-specific extraction (TypeScript)")


def test_security_findings_extraction():
    """보안 발견사항 추출 테스트"""
    print("\n" + "=" * 50)
    print("Security Findings Extraction Test")
    print("=" * 50)

    codex = CodexInvoker()

    sample_output = """
Critical: SQL Injection vulnerability in login query
High: Missing input validation
Medium: Weak password policy
Low: Missing HTTPS redirect
"""

    findings = codex._extract_security_findings(sample_output)
    assert len(findings) == 4
    assert findings[0]["severity"] == "Critical"
    assert "SQL Injection" in findings[0]["description"]
    print(f"[OK] Extracted {len(findings)} security findings")

    for finding in findings:
        print(f"  [{finding['severity']}] {finding['description']}")


if __name__ == "__main__":
    try:
        test_invoker_initialization()
        test_prompt_formatting()
        test_code_block_extraction()
        test_security_findings_extraction()

        print("\n" + "=" * 50)
        print("[OK] All tests passed!")
        print("=" * 50)

    except AssertionError as e:
        print(f"\n[FAIL] Test failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n[ERROR] {e}")
        sys.exit(1)
