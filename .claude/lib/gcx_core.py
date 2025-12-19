"""
GCX Core Utilities
==================

타임스탬프 생성, UTF-8 정규화, 파일명 안전화 등 핵심 유틸리티
"""

import os
import re
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional


# Session ID (프로세스 시작 시 1회 생성)
_SESSION_ID: Optional[str] = None


def get_timestamp(format_type: str = "standard") -> str:
    """
    타임스탬프 생성 (단일 진실 공급원)

    Args:
        format_type:
            - "standard": YYYYMMDD_HHMMSS (파일명용)
            - "iso": YYYY-MM-DD HH:MM:SS (로그용)
            - "compact": YYYYMMDDHHMMSS (ID용)

    Returns:
        생성된 타임스탬프 문자열

    Examples:
        >>> get_timestamp()
        '20251219_143022'
        >>> get_timestamp("iso")
        '2025-12-19 14:30:22'
    """
    now = datetime.now()

    if format_type == "standard":
        return now.strftime("%Y%m%d_%H%M%S")
    elif format_type == "iso":
        return now.strftime("%Y-%m-%d %H:%M:%S")
    elif format_type == "compact":
        return now.strftime("%Y%m%d%H%M%S")
    else:
        raise ValueError(f"Unknown format_type: {format_type}")


def get_session_id() -> str:
    """
    세션 ID 반환 (프로세스 당 1회 생성, 재사용)

    Returns:
        세션 ID (예: 20251219_143022_a3f7)

    Examples:
        >>> sid1 = get_session_id()
        >>> sid2 = get_session_id()
        >>> sid1 == sid2
        True
    """
    global _SESSION_ID

    if _SESSION_ID is None:
        timestamp = get_timestamp("standard")
        random_suffix = uuid.uuid4().hex[:4]
        _SESSION_ID = f"{timestamp}_{random_suffix}"

    return _SESSION_ID


def normalize_utf8(text: str) -> str:
    """
    UTF-8 문자열 정규화 (Windows MSYS2용)

    Args:
        text: 입력 문자열

    Returns:
        정규화된 UTF-8 문자열

    Notes:
        - NFC 정규화 적용
        - Windows 경로 구분자 → Unix 스타일 변환
    """
    import unicodedata

    # Unicode NFC 정규화
    normalized = unicodedata.normalize('NFC', text)

    # Windows 경로 구분자 변환 (필요시)
    # normalized = normalized.replace('\\', '/')

    return normalized


def safe_filename(text: str, max_length: int = 255) -> str:
    """
    안전한 파일명 생성 (Windows + MSYS2 호환)

    Args:
        text: 원본 문자열
        max_length: 최대 길이 (default: 255)

    Returns:
        안전한 파일명

    Examples:
        >>> safe_filename("Build REST API / Auth")
        'Build_REST_API_Auth'
        >>> safe_filename("TypeScript와 JavaScript의 차이점은?")
        'TypeScript와_JavaScript의_차이점은'
    """
    # Windows 금지 문자 제거: < > : " / \ | ? *
    safe = re.sub(r'[<>:"/\\|?*]', '_', text)

    # 연속 공백 → 단일 공백
    safe = re.sub(r'\s+', ' ', safe)

    # 공백 → 언더스코어
    safe = safe.replace(' ', '_')

    # 길이 제한
    if len(safe) > max_length:
        safe = safe[:max_length]

    # 앞뒤 언더스코어 제거
    safe = safe.strip('_')

    return safe


def get_project_root() -> Path:
    """
    프로젝트 루트 디렉토리 반환

    Returns:
        프로젝트 루트 경로 (Path 객체)

    Notes:
        .gcx 디렉토리를 찾아 상위 디렉토리 반환
    """
    current = Path.cwd()

    # 현재 디렉토리부터 상위로 탐색
    for parent in [current] + list(current.parents):
        if (parent / ".gcx").exists():
            return parent

    # .gcx 못 찾으면 현재 디렉토리 반환
    return current


def ensure_directory(path: Path) -> Path:
    """
    디렉토리 존재 확인 및 생성

    Args:
        path: 디렉토리 경로

    Returns:
        생성된 디렉토리 경로
    """
    path = Path(path)
    path.mkdir(parents=True, exist_ok=True)
    return path


if __name__ == "__main__":
    # 테스트
    print("=== GCX Core Utilities Test ===")
    print(f"Timestamp (standard): {get_timestamp()}")
    print(f"Timestamp (iso): {get_timestamp('iso')}")
    print(f"Session ID: {get_session_id()}")
    print(f"Safe filename: {safe_filename('Build REST API / Auth')}")
    print(f"Project root: {get_project_root()}")
