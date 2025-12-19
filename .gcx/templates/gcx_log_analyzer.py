#!/usr/bin/env python3
"""
GCX v4.0 Log Analyzer
파이프라인 로그를 분석하고 통계를 제공합니다.
"""

import os
import glob
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple
import argparse


class GCXLogAnalyzer:
    """GCX 로그 분석기"""

    def __init__(self, log_dir: str = ".gcx/pipeline/logs"):
        self.log_dir = Path(log_dir)
        self.stats: Dict[str, int] = {
            "total_logs": 0,
            "gemini_logs": 0,
            "claude_logs": 0,
            "codex_logs": 0,
        }

    def analyze(self) -> Dict:
        """로그 파일 분석"""
        if not self.log_dir.exists():
            return {"error": f"로그 디렉토리가 없습니다: {self.log_dir}"}

        log_files = list(self.log_dir.glob("*.log"))
        log_files += list(self.log_dir.glob("*.txt"))

        self.stats["total_logs"] = len(log_files)

        for log_file in log_files:
            if "gemini" in log_file.name:
                self.stats["gemini_logs"] += 1
            elif "claude" in log_file.name:
                self.stats["claude_logs"] += 1
            elif "codex" in log_file.name:
                self.stats["codex_logs"] += 1

        return self.stats

    def get_recent_logs(self, limit: int = 10) -> List[Tuple[str, str, int]]:
        """최근 로그 파일 목록 반환"""
        log_files = list(self.log_dir.glob("*.log"))
        log_files += list(self.log_dir.glob("*.txt"))

        # 수정 시간 기준 정렬
        log_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)

        results = []
        for log_file in log_files[:limit]:
            size = log_file.stat().st_size
            mtime = datetime.fromtimestamp(log_file.stat().st_mtime)
            results.append((log_file.name, mtime.strftime("%Y-%m-%d %H:%M:%S"), size))

        return results

    def find_errors(self) -> List[Tuple[str, List[str]]]:
        """로그에서 에러 찾기"""
        error_patterns = [
            r"error",
            r"failed",
            r"exception",
            r"traceback",
            r"❌",
        ]

        results = []
        log_files = list(self.log_dir.glob("*.log"))
        log_files += list(self.log_dir.glob("*.txt"))

        for log_file in log_files:
            try:
                with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read().lower()

                    errors_found = []
                    for pattern in error_patterns:
                        if re.search(pattern, content, re.IGNORECASE):
                            errors_found.append(pattern)

                    if errors_found:
                        results.append((log_file.name, errors_found))
            except Exception as e:
                print(f"⚠️  {log_file.name} 읽기 실패: {e}")

        return results

    def get_pipeline_stats(self) -> Dict:
        """파이프라인 실행 통계"""
        claude_outputs = list(self.log_dir.glob("claude_output_*.txt"))
        codex_outputs = list(self.log_dir.glob("codex_output_*.txt"))

        # Codex 승인 횟수 카운트
        approved_count = 0
        improvement_count = 0

        for codex_log in codex_outputs:
            try:
                with open(codex_log, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()

                    if re.search(r"APPROVED", content, re.IGNORECASE):
                        approved_count += 1
                    elif re.search(r"개선|improve|수정|fix", content, re.IGNORECASE):
                        improvement_count += 1
            except Exception:
                pass

        return {
            "total_claude_outputs": len(claude_outputs),
            "total_codex_reviews": len(codex_outputs),
            "codex_approved": approved_count,
            "codex_improvements": improvement_count,
        }

    def print_summary(self):
        """분석 결과 출력"""
        print("=" * 50)
        print("   GCX v4.0 Log Analysis Summary")
        print("=" * 50)
        print()

        # 기본 통계
        stats = self.analyze()
        print("--- 기본 통계 ---")
        print(f"  총 로그 파일: {stats['total_logs']}")
        print(f"  - Gemini: {stats['gemini_logs']}")
        print(f"  - Claude: {stats['claude_logs']}")
        print(f"  - Codex: {stats['codex_logs']}")
        print()

        # 파이프라인 통계
        pipeline_stats = self.get_pipeline_stats()
        print("--- 파이프라인 통계 ---")
        print(f"  Claude 출력: {pipeline_stats['total_claude_outputs']}")
        print(f"  Codex 리뷰: {pipeline_stats['total_codex_reviews']}")
        print(f"  - 승인 (APPROVED): {pipeline_stats['codex_approved']}")
        print(f"  - 개선 제안: {pipeline_stats['codex_improvements']}")
        print()

        # 최근 로그
        recent_logs = self.get_recent_logs(5)
        print("--- 최근 로그 (최근 5개) ---")
        for name, mtime, size in recent_logs:
            size_kb = size / 1024
            print(f"  - {name}")
            print(f"    {mtime} ({size_kb:.1f} KB)")
        print()

        # 에러 검사
        errors = self.find_errors()
        if errors:
            print("--- 발견된 에러 ---")
            for log_name, error_patterns in errors:
                print(f"  [!] {log_name}")
                print(f"      패턴: {', '.join(error_patterns)}")
        else:
            print("--- 에러 ---")
            print("  [OK] 에러가 발견되지 않았습니다")
        print()

        # 디스크 사용량
        total_size = sum(f.stat().st_size for f in self.log_dir.glob("*") if f.is_file())
        print(f"--- 디스크 사용량 ---")
        print(f"  {self.log_dir}: {total_size / 1024 / 1024:.2f} MB")
        print()


def main():
    parser = argparse.ArgumentParser(description="GCX v4.0 로그 분석 도구")
    parser.add_argument(
        "--log-dir",
        default=".gcx/pipeline/logs",
        help="로그 디렉토리 경로 (기본값: .gcx/pipeline/logs)",
    )
    parser.add_argument(
        "--errors-only",
        action="store_true",
        help="에러만 표시",
    )
    parser.add_argument(
        "--recent",
        type=int,
        default=5,
        help="최근 N개 로그 표시 (기본값: 5)",
    )

    args = parser.parse_args()

    analyzer = GCXLogAnalyzer(args.log_dir)

    if args.errors_only:
        errors = analyzer.find_errors()
        if errors:
            print("발견된 에러:")
            for log_name, error_patterns in errors:
                print(f"  ⚠️  {log_name}: {', '.join(error_patterns)}")
        else:
            print("✅ 에러가 발견되지 않았습니다")
    else:
        analyzer.print_summary()


if __name__ == "__main__":
    main()
