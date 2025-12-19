"""
Context Baton Manager
=====================

GCX v6 Context Baton Protocol 구현
Subagent 간 컨텍스트 전달 및 상태 관리
"""

import json
from dataclasses import dataclass, asdict, field
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Any


@dataclass
class BatonMetadata:
    """Baton 메타데이터"""
    session_id: str
    created_at: str
    updated_at: str
    current_phase: str
    total_phases: int = 6


@dataclass
class PhaseResult:
    """단계별 실행 결과"""
    phase_name: str
    status: str  # pending, in_progress, completed, failed
    ai_type: str  # gemini, claude, codex
    model: str
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
    output_files: List[str] = field(default_factory=list)
    summary: Optional[str] = None
    error: Optional[str] = None
    duration: Optional[float] = None  # seconds


@dataclass
class ContextBaton:
    """
    Context Baton - Subagent 간 전달되는 컨텍스트

    GCX v6 프로토콜에서 각 Subagent는 이전 단계의 결과를 받아
    자신의 작업을 수행하고 다음 단계로 Baton을 전달합니다.
    """
    metadata: BatonMetadata
    user_request: str
    project_root: str
    requirements: Dict[str, Any] = field(default_factory=dict)
    planning: Dict[str, Any] = field(default_factory=dict)
    implementation: Dict[str, Any] = field(default_factory=dict)
    verification: Dict[str, Any] = field(default_factory=dict)
    design_review: Dict[str, Any] = field(default_factory=dict)
    qa_validation: Dict[str, Any] = field(default_factory=dict)
    final_report: Dict[str, Any] = field(default_factory=dict)
    phase_results: List[PhaseResult] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        """딕셔너리로 변환"""
        return asdict(self)

    def to_json(self) -> str:
        """JSON 문자열로 변환"""
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'ContextBaton':
        """딕셔너리에서 생성"""
        # Metadata 변환
        metadata = BatonMetadata(**data.get("metadata", {}))

        # PhaseResult 변환
        phase_results = [
            PhaseResult(**pr) for pr in data.get("phase_results", [])
        ]

        return cls(
            metadata=metadata,
            user_request=data.get("user_request", ""),
            project_root=data.get("project_root", ""),
            requirements=data.get("requirements", {}),
            planning=data.get("planning", {}),
            implementation=data.get("implementation", {}),
            verification=data.get("verification", {}),
            design_review=data.get("design_review", {}),
            qa_validation=data.get("qa_validation", {}),
            final_report=data.get("final_report", {}),
            phase_results=phase_results
        )

    @classmethod
    def from_json(cls, json_str: str) -> 'ContextBaton':
        """JSON 문자열에서 생성"""
        data = json.loads(json_str)
        return cls.from_dict(data)


class BatonManager:
    """Context Baton 관리 클래스"""

    def __init__(self, project_root: Optional[Path] = None):
        """
        Args:
            project_root: 프로젝트 루트 디렉토리
        """
        if project_root is None:
            project_root = Path.cwd()

        self.project_root = Path(project_root)
        self.state_dir = self.project_root / ".gcx" / "state"
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.baton_file = self.state_dir / "project_context.json"

    def create_baton(self, user_request: str, session_id: str) -> ContextBaton:
        """
        새로운 Baton 생성

        Args:
            user_request: 사용자 요청
            session_id: 세션 ID

        Returns:
            생성된 ContextBaton 객체
        """
        now = datetime.now().isoformat()

        metadata = BatonMetadata(
            session_id=session_id,
            created_at=now,
            updated_at=now,
            current_phase="requirement-capture",
            total_phases=6
        )

        baton = ContextBaton(
            metadata=metadata,
            user_request=user_request,
            project_root=str(self.project_root)
        )

        self.save_baton(baton)
        return baton

    def load_baton(self) -> Optional[ContextBaton]:
        """
        저장된 Baton 로드

        Returns:
            ContextBaton 객체 또는 None (파일이 없는 경우)
        """
        if not self.baton_file.exists():
            return None

        with open(self.baton_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        return ContextBaton.from_dict(data)

    def save_baton(self, baton: ContextBaton) -> None:
        """
        Baton 저장

        Args:
            baton: 저장할 ContextBaton 객체
        """
        # 업데이트 시간 갱신
        baton.metadata.updated_at = datetime.now().isoformat()

        with open(self.baton_file, "w", encoding="utf-8") as f:
            f.write(baton.to_json())

    def update_phase(
        self,
        phase_name: str,
        data: Dict[str, Any],
        output_files: Optional[List[str]] = None
    ) -> ContextBaton:
        """
        특정 단계의 데이터 업데이트

        Args:
            phase_name: 단계 이름 (requirements, planning, implementation 등)
            data: 저장할 데이터
            output_files: 생성된 출력 파일 목록

        Returns:
            업데이트된 ContextBaton
        """
        baton = self.load_baton()
        if baton is None:
            raise ValueError("Baton이 초기화되지 않았습니다")

        # 해당 단계 데이터 업데이트
        if hasattr(baton, phase_name):
            setattr(baton, phase_name, data)

        # 현재 단계 업데이트
        baton.metadata.current_phase = phase_name

        # PhaseResult 업데이트
        for pr in baton.phase_results:
            if pr.phase_name == phase_name:
                pr.status = "completed"
                pr.completed_at = datetime.now().isoformat()
                if output_files:
                    pr.output_files = output_files
                break

        self.save_baton(baton)
        return baton

    def add_phase_result(self, phase_result: PhaseResult) -> None:
        """
        단계별 결과 추가

        Args:
            phase_result: 추가할 PhaseResult 객체
        """
        baton = self.load_baton()
        if baton is None:
            raise ValueError("Baton이 초기화되지 않았습니다")

        # 기존 결과 업데이트 또는 새로 추가
        updated = False
        for i, pr in enumerate(baton.phase_results):
            if pr.phase_name == phase_result.phase_name:
                baton.phase_results[i] = phase_result
                updated = True
                break

        if not updated:
            baton.phase_results.append(phase_result)

        self.save_baton(baton)

    def get_phase_result(self, phase_name: str) -> Optional[PhaseResult]:
        """
        특정 단계의 결과 조회

        Args:
            phase_name: 단계 이름

        Returns:
            PhaseResult 또는 None
        """
        baton = self.load_baton()
        if baton is None:
            return None

        for pr in baton.phase_results:
            if pr.phase_name == phase_name:
                return pr

        return None

    def clear_baton(self) -> None:
        """Baton 파일 삭제"""
        if self.baton_file.exists():
            self.baton_file.unlink()

    def get_summary(self) -> Dict[str, Any]:
        """
        Baton 요약 정보 반환

        Returns:
            요약 정보 딕셔너리
        """
        baton = self.load_baton()
        if baton is None:
            return {"status": "no_baton", "message": "Baton이 초기화되지 않았습니다"}

        completed_phases = [
            pr.phase_name for pr in baton.phase_results if pr.status == "completed"
        ]

        return {
            "status": "active",
            "session_id": baton.metadata.session_id,
            "current_phase": baton.metadata.current_phase,
            "completed_phases": completed_phases,
            "total_phases": baton.metadata.total_phases,
            "progress": f"{len(completed_phases)}/{baton.metadata.total_phases}"
        }


if __name__ == "__main__":
    # 테스트
    print("=== Context Baton Manager Test ===\n")

    # Baton 생성
    print("[1/5] Baton 생성")
    manager = BatonManager()
    baton = manager.create_baton(
        user_request="REST API 구현",
        session_id="test_20251219_001"
    )
    print(f"✅ Baton 생성됨: {baton.metadata.session_id}")

    # PhaseResult 추가
    print("\n[2/5] Phase Result 추가")
    phase1 = PhaseResult(
        phase_name="requirement-capture",
        status="completed",
        ai_type="gemini",
        model="gemini-2.5-pro",
        started_at=datetime.now().isoformat(),
        completed_at=datetime.now().isoformat(),
        output_files=[".gcx/00_requirements/user_request_20251219.md"],
        summary="요구사항 캡처 완료",
        duration=5.2
    )
    manager.add_phase_result(phase1)
    print("✅ requirement-capture 단계 완료")

    # Baton 로드
    print("\n[3/5] Baton 로드")
    loaded_baton = manager.load_baton()
    print(f"✅ 로드된 세션: {loaded_baton.metadata.session_id}")
    print(f"   현재 단계: {loaded_baton.metadata.current_phase}")

    # 요약 정보
    print("\n[4/5] 요약 정보")
    summary = manager.get_summary()
    for key, value in summary.items():
        print(f"   {key}: {value}")

    # Baton 저장 위치
    print(f"\n[5/5] Baton 저장 위치")
    print(f"   {manager.baton_file}")
