"""
Environment Detection
=====================

MSYS2 UCRT64 Zsh 환경 감지 및 검증
"""

import os
import platform
import subprocess
from dataclasses import dataclass
from typing import Optional, Dict, List


@dataclass
class EnvironmentInfo:
    """환경 정보 데이터 클래스"""
    os_type: str  # windows, linux, darwin
    is_msys2: bool
    msystem: Optional[str]  # UCRT64, MINGW64, MSYS, None
    shell: str  # bash, zsh, powershell, cmd
    locale: Dict[str, str]  # LANG, LC_ALL
    is_korean_safe: bool
    has_named_pipes: bool
    python_version: str
    recommendations: List[str]


def is_msys2() -> bool:
    """
    MSYS2 환경인지 확인

    Returns:
        MSYS2 환경이면 True
    """
    return 'MSYSTEM' in os.environ


def is_msys2_ucrt64() -> bool:
    """
    MSYS2 UCRT64 환경인지 확인 (GCX v5 권장)

    Returns:
        MSYS2 UCRT64 환경이면 True
    """
    msystem = os.environ.get('MSYSTEM', '')
    return msystem == 'UCRT64'


def get_msystem() -> Optional[str]:
    """
    현재 MSYSTEM 반환

    Returns:
        MSYSTEM 값 (UCRT64, MINGW64, MSYS 등) 또는 None
    """
    return os.environ.get('MSYSTEM')


def detect_shell() -> str:
    """
    현재 셸 감지

    Returns:
        셸 이름 (bash, zsh, powershell, cmd, unknown)
    """
    # SHELL 환경 변수 확인
    shell_path = os.environ.get('SHELL', '')

    if 'zsh' in shell_path.lower():
        return 'zsh'
    elif 'bash' in shell_path.lower():
        return 'bash'

    # PowerShell 확인
    if os.environ.get('PSModulePath'):
        return 'powershell'

    # Windows cmd 확인
    if platform.system() == 'Windows' and not shell_path:
        return 'cmd'

    return 'unknown'


def get_locale_info() -> Dict[str, str]:
    """
    로케일 정보 반환

    Returns:
        로케일 정보 딕셔너리 (LANG, LC_ALL)
    """
    return {
        'LANG': os.environ.get('LANG', ''),
        'LC_ALL': os.environ.get('LC_ALL', '')
    }


def is_korean_locale() -> bool:
    """
    한글 로케일인지 확인

    Returns:
        ko_KR.UTF-8 설정되어 있으면 True
    """
    lang = os.environ.get('LANG', '')
    lc_all = os.environ.get('LC_ALL', '')

    return 'ko_KR.UTF-8' in lang or 'ko_KR.UTF-8' in lc_all


def has_named_pipe_support() -> bool:
    """
    Named Pipe (mkfifo) 지원 여부 확인

    Returns:
        mkfifo 명령어가 존재하면 True
    """
    try:
        result = subprocess.run(
            ['which', 'mkfifo'],
            capture_output=True,
            text=True,
            timeout=2
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def check_cli_tools() -> Dict[str, bool]:
    """
    필수 CLI 도구 존재 확인

    Returns:
        도구별 존재 여부 딕셔너리
    """
    tools = ['claude', 'codex', 'gemini', 'python3', 'zsh']
    results = {}

    for tool in tools:
        try:
            result = subprocess.run(
                ['which', tool],
                capture_output=True,
                text=True,
                timeout=2
            )
            results[tool] = result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            results[tool] = False

    return results


def get_environment_info() -> EnvironmentInfo:
    """
    전체 환경 정보 수집

    Returns:
        EnvironmentInfo 객체
    """
    os_type = platform.system().lower()
    locale = get_locale_info()
    is_korean = is_korean_locale()
    shell = detect_shell()

    # 권장 사항 생성
    recommendations = []

    if not is_msys2_ucrt64():
        recommendations.append("MSYS2 UCRT64 환경 사용 권장 (현재: {})".format(
            get_msystem() or "MSYS2 아님"
        ))

    if shell != 'zsh':
        recommendations.append("Zsh 사용 권장 (현재: {})".format(shell))

    if not is_korean:
        recommendations.append(
            "한글 로케일 설정 권장: export LANG=ko_KR.UTF-8"
        )

    return EnvironmentInfo(
        os_type=os_type,
        is_msys2=is_msys2(),
        msystem=get_msystem(),
        shell=shell,
        locale=locale,
        is_korean_safe=is_korean,
        has_named_pipes=has_named_pipe_support(),
        python_version=platform.python_version(),
        recommendations=recommendations
    )


def print_environment_info():
    """환경 정보 출력 (디버깅용)"""
    info = get_environment_info()

    # Windows 호환성을 위해 ASCII 체크마크 사용
    def status_icon(is_ok: bool) -> str:
        return "[OK]" if is_ok else "[X]"

    print("=" * 50)
    print("GCX v5 Environment Info")
    print("=" * 50)
    print(f"OS: {info.os_type}")
    print(f"MSYS2: {info.is_msys2}")
    print(f"MSYSTEM: {info.msystem or 'N/A'}")
    print(f"Shell: {info.shell}")
    print(f"Locale LANG: {info.locale['LANG']}")
    print(f"Locale LC_ALL: {info.locale['LC_ALL']}")
    print(f"Korean Safe: {status_icon(info.is_korean_safe)}")
    print(f"Named Pipes: {status_icon(info.has_named_pipes)}")
    print(f"Python: {info.python_version}")

    print("\n" + "=" * 50)
    print("CLI Tools")
    print("=" * 50)
    tools = check_cli_tools()
    for tool, exists in tools.items():
        print(f"{tool}: {status_icon(exists)}")

    if info.recommendations:
        print("\n" + "=" * 50)
        print("Recommendations")
        print("=" * 50)
        for i, rec in enumerate(info.recommendations, 1):
            print(f"{i}. {rec}")
    else:
        print("\n[OK] All environment settings meet GCX v5 recommendations!")


if __name__ == "__main__":
    print_environment_info()
