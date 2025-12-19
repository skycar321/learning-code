"""
GCX v5 Python Library
=====================

Claude Code용 GCX v5 프로토콜 자동화 라이브러리

주요 모듈:
- gcx_core: 타임스탬프, UTF-8 정규화
- environment: MSYS2 UCRT64 Zsh 환경 감지
- validators: TOML, 한글 UTF-8 검증
- ai_invokers: Codex/Gemini/Claude CLI 래퍼 (핵심)
- parsers: AI 출력 파싱
- requirement_capture: 요구사항 문서화
- formatters: 포맷 변환 (MD ↔ TOML ↔ JSON)
- preflight: 통합 사전 점검
"""

__version__ = "5.0.0"
__author__ = "GCX Protocol Team"

# 핵심 모듈 임포트
from .gcx_core import (
    get_timestamp,
    normalize_utf8,
    safe_filename,
    get_session_id
)

from .environment import (
    is_msys2_ucrt64,
    get_locale_info,
    detect_shell,
    get_environment_info
)

__all__ = [
    # gcx_core
    "get_timestamp",
    "normalize_utf8",
    "safe_filename",
    "get_session_id",

    # environment
    "is_msys2_ucrt64",
    "get_locale_info",
    "detect_shell",
    "get_environment_info",
]
