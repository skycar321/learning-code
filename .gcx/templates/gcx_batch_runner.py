#!/usr/bin/env python3
"""
GCX v4.0 Batch Runner
여러 작업을 순차적으로 실행하고 결과를 수집합니다.
"""

import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional
import argparse
import json


class GCXBatchRunner:
    """GCX 배치 실행기"""

    def __init__(self, script_path: str = ".gcx/templates/gcx_test_simple.sh"):
        self.script_path = Path(script_path)
        self.results: List[Dict] = []

    def run_task(self, task: str, timeout: int = 180) -> Dict:
        """단일 작업 실행"""
        print(f"\n{'='*60}")
        print(f"[{datetime.now().strftime('%H:%M:%S')}] 실행 중: {task}")
        print(f"{'='*60}\n")

        start_time = time.time()
        result = {
            "task": task,
            "start_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "status": "pending",
            "duration": 0,
            "error": None,
        }

        try:
            # Bash 스크립트 실행
            process = subprocess.run(
                ["bash", str(self.script_path), task],
                capture_output=True,
                text=True,
                timeout=timeout,
                encoding="utf-8",
                errors="replace",
            )

            duration = time.time() - start_time
            result["duration"] = round(duration, 2)
            result["end_time"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

            if process.returncode == 0:
                result["status"] = "success"
                print(f"\n[OK] 성공 ({duration:.1f}초)")
            else:
                result["status"] = "failed"
                result["error"] = process.stderr[:500] if process.stderr else "Unknown error"
                print(f"\n[FAIL] 실패 ({duration:.1f}초)")
                print(f"에러: {result['error'][:200]}")

        except subprocess.TimeoutExpired:
            result["status"] = "timeout"
            result["duration"] = timeout
            result["error"] = f"Timeout after {timeout}s"
            print(f"\n[TIMEOUT] 타임아웃 ({timeout}초)")

        except Exception as e:
            result["status"] = "error"
            result["duration"] = time.time() - start_time
            result["error"] = str(e)
            print(f"\n[ERROR] 에러: {e}")

        return result

    def run_batch(self, tasks: List[str], timeout: int = 180) -> List[Dict]:
        """여러 작업 순차 실행"""
        print("\n" + "=" * 50)
        print("   GCX v4.0 Batch Runner")
        print("=" * 50)
        print(f"\n총 {len(tasks)}개 작업 실행 예정")

        for i, task in enumerate(tasks, 1):
            print(f"\n진행: [{i}/{len(tasks)}]")
            result = self.run_task(task, timeout)
            self.results.append(result)

        return self.results

    def print_summary(self):
        """실행 결과 요약"""
        print("\n\n" + "=" * 50)
        print("   Batch Execution Summary")
        print("=" * 50 + "\n")

        success_count = sum(1 for r in self.results if r["status"] == "success")
        failed_count = sum(1 for r in self.results if r["status"] == "failed")
        timeout_count = sum(1 for r in self.results if r["status"] == "timeout")
        error_count = sum(1 for r in self.results if r["status"] == "error")

        print(f"총 작업: {len(self.results)}")
        print(f"  [OK] 성공: {success_count}")
        print(f"  [FAIL] 실패: {failed_count}")
        print(f"  [TIMEOUT] 타임아웃: {timeout_count}")
        print(f"  [ERROR] 에러: {error_count}")
        print()

        total_duration = sum(r["duration"] for r in self.results)
        print(f"총 실행 시간: {total_duration:.1f}초 ({total_duration/60:.1f}분)")
        print()

        # 개별 결과
        print("--- 개별 결과 ---")
        for i, result in enumerate(self.results, 1):
            status_icon = {
                "success": "[OK]",
                "failed": "[FAIL]",
                "timeout": "[TIMEOUT]",
                "error": "[ERROR]",
            }.get(result["status"], "[?]")

            print(f"\n[{i}] {status_icon} {result['task']}")
            print(f"    상태: {result['status']}")
            print(f"    시간: {result['duration']:.1f}초")
            if result.get("error"):
                print(f"    에러: {result['error'][:100]}...")

        print()

    def save_report(self, output_file: Optional[str] = None):
        """결과를 JSON 파일로 저장"""
        if output_file is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_file = f".gcx/output/batch_report_{timestamp}.json"

        output_path = Path(output_file)
        output_path.parent.mkdir(parents=True, exist_ok=True)

        report = {
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "total_tasks": len(self.results),
            "summary": {
                "success": sum(1 for r in self.results if r["status"] == "success"),
                "failed": sum(1 for r in self.results if r["status"] == "failed"),
                "timeout": sum(1 for r in self.results if r["status"] == "timeout"),
                "error": sum(1 for r in self.results if r["status"] == "error"),
            },
            "total_duration": sum(r["duration"] for r in self.results),
            "results": self.results,
        }

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, ensure_ascii=False, indent=2)

        print(f"[REPORT] 보고서 저장: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="GCX v4.0 배치 실행 도구")
    parser.add_argument(
        "--tasks-file",
        help="작업 목록 파일 (한 줄에 하나씩)",
    )
    parser.add_argument(
        "--tasks",
        nargs="+",
        help="작업 목록 (공백으로 구분)",
    )
    parser.add_argument(
        "--script",
        default=".gcx/templates/gcx_test_simple.sh",
        help="실행할 스크립트 경로",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=180,
        help="각 작업 타임아웃 (초)",
    )
    parser.add_argument(
        "--output",
        help="결과 저장 파일 (JSON)",
    )

    args = parser.parse_args()

    # 작업 목록 가져오기
    tasks = []
    if args.tasks_file:
        with open(args.tasks_file, "r", encoding="utf-8") as f:
            tasks = [line.strip() for line in f if line.strip() and not line.startswith("#")]
    elif args.tasks:
        tasks = args.tasks
    else:
        print("❌ 오류: --tasks-file 또는 --tasks 중 하나를 지정해야 합니다.")
        parser.print_help()
        sys.exit(1)

    if not tasks:
        print("❌ 오류: 실행할 작업이 없습니다.")
        sys.exit(1)

    # 배치 실행
    runner = GCXBatchRunner(args.script)
    runner.run_batch(tasks, timeout=args.timeout)

    # 결과 출력
    runner.print_summary()

    # 보고서 저장
    if args.output:
        runner.save_report(args.output)
    else:
        runner.save_report()


if __name__ == "__main__":
    main()
