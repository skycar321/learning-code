"""
모델 설정 로더
===============

AI 모델 설정을 models.json에서 로드하고 관리합니다.
사용자는 models.json만 수정하면 모든 AI 모델 버전을 업데이트할 수 있습니다.
"""

import json
from pathlib import Path
from typing import Optional, Tuple


class ModelConfig:
    """AI 모델 설정 관리 클래스 (Singleton)"""

    _config = None
    CONFIG_PATH = Path(__file__).parent.parent / "config" / "models.json"

    @classmethod
    def load(cls, force_reload: bool = False) -> dict:
        """
        모델 설정 로드 (Singleton 패턴)

        Args:
            force_reload: 강제 재로드 여부

        Returns:
            모델 설정 딕셔너리

        Raises:
            FileNotFoundError: 설정 파일이 없는 경우
            json.JSONDecodeError: JSON 파싱 실패
        """
        if cls._config is None or force_reload:
            if not cls.CONFIG_PATH.exists():
                raise FileNotFoundError(
                    f"모델 설정 파일을 찾을 수 없습니다: {cls.CONFIG_PATH}"
                )

            with open(cls.CONFIG_PATH, "r", encoding="utf-8") as f:
                cls._config = json.load(f)

        return cls._config

    @classmethod
    def get_model(cls, ai_type: str, purpose: str = "default") -> str:
        """
        AI 타입과 용도에 따른 모델 ID 반환

        Args:
            ai_type: AI 타입 (claude, codex, gemini)
            purpose: 용도 (default, planning, quick, design, reasoning 등)

        Returns:
            모델 ID 문자열

        Examples:
            >>> ModelConfig.get_model("claude", "planning")
            'claude-opus-4-5-20251101'
            >>> ModelConfig.get_model("codex", "quick")
            'gpt-4.1-mini'

        Raises:
            ValueError: 알 수 없는 AI 타입
            KeyError: 알 수 없는 용도
        """
        config = cls.load()
        models = config.get("models", {})

        if ai_type not in models:
            raise ValueError(
                f"알 수 없는 AI 타입: {ai_type}. "
                f"사용 가능: {list(models.keys())}"
            )

        ai_config = models[ai_type]

        # Alias 먼저 확인
        if purpose in ai_config.get("alias", {}):
            return ai_config["alias"][purpose]

        # 직접 매핑 확인
        if purpose in ai_config:
            return ai_config[purpose]

        # 기본값 반환
        return ai_config["default"]

    @classmethod
    def get_task_model(cls, task_name: str) -> Tuple[str, Optional[str]]:
        """
        태스크에 매핑된 모델 반환 (primary, fallback)

        Args:
            task_name: 태스크 이름 (requirement-capture, plan-architect 등)

        Returns:
            (primary_model, fallback_model) 튜플
            fallback_model은 None일 수 있음

        Examples:
            >>> ModelConfig.get_task_model("plan-architect")
            ('claude-opus-4-5-20251101', 'gemini-2.5-pro')
            >>> ModelConfig.get_task_model("design-review")
            ('gemini-2.5-pro', None)
        """
        config = cls.load()
        mapping = config.get("taskMapping", {}).get(task_name, {})

        # Primary 모델
        primary = mapping.get("primary", "claude.default")
        ai_type, purpose = primary.split(".")
        primary_model = cls.get_model(ai_type, purpose)

        # Fallback 모델
        fallback_model = None
        fallback = mapping.get("fallback")

        if fallback:
            fb_type, fb_purpose = fallback.split(".")
            fallback_model = cls.get_model(fb_type, fb_purpose)

        return primary_model, fallback_model

    @classmethod
    def get_version(cls) -> str:
        """설정 파일 버전 반환"""
        config = cls.load()
        return config.get("version", "unknown")

    @classmethod
    def get_last_updated(cls) -> str:
        """마지막 업데이트 날짜 반환"""
        config = cls.load()
        return config.get("lastUpdated", "unknown")

    @classmethod
    def validate_config(cls) -> bool:
        """
        설정 파일 유효성 검증

        Returns:
            유효하면 True, 아니면 False
        """
        try:
            config = cls.load()

            # 필수 키 확인
            required_keys = ["models", "taskMapping"]
            for key in required_keys:
                if key not in config:
                    print(f"❌ 필수 키 누락: {key}")
                    return False

            # AI 타입 확인
            models = config.get("models", {})
            required_ai_types = ["claude", "codex", "gemini"]

            for ai_type in required_ai_types:
                if ai_type not in models:
                    print(f"❌ AI 타입 누락: {ai_type}")
                    return False

                # default 키 확인
                if "default" not in models[ai_type]:
                    print(f"❌ {ai_type}에 'default' 모델이 없습니다")
                    return False

            print("✅ 모델 설정 파일이 유효합니다")
            return True

        except Exception as e:
            print(f"❌ 검증 실패: {e}")
            return False


if __name__ == "__main__":
    # 테스트
    print("=== Model Config Test ===\n")

    # 설정 검증
    print("[1/5] 설정 파일 유효성 검증")
    ModelConfig.validate_config()

    # 버전 정보
    print(f"\n[2/5] 설정 버전: {ModelConfig.get_version()}")
    print(f"     마지막 업데이트: {ModelConfig.get_last_updated()}")

    # 개별 모델 조회
    print("\n[3/5] 개별 모델 조회")
    print(f"Claude Planning: {ModelConfig.get_model('claude', 'planning')}")
    print(f"Codex Quick: {ModelConfig.get_model('codex', 'quick')}")
    print(f"Gemini Design: {ModelConfig.get_model('gemini', 'design')}")

    # Alias 조회
    print("\n[4/5] Alias 조회")
    print(f"Claude Opus: {ModelConfig.get_model('claude', 'opus')}")
    print(f"Codex Max: {ModelConfig.get_model('codex', 'max')}")

    # 태스크 매핑
    print("\n[5/5] 태스크 모델 매핑")
    tasks = ["requirement-capture", "plan-architect", "tdd-generator", "design-review"]

    for task in tasks:
        primary, fallback = ModelConfig.get_task_model(task)
        fallback_str = f" (fallback: {fallback})" if fallback else " (no fallback)"
        print(f"{task}: {primary}{fallback_str}")
