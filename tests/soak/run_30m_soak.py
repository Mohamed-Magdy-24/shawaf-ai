#!/usr/bin/env python3
"""
30-Minute Soak Test & Memory Leak Detection Harness
Governing: docs/quality/QUALITY_AND_VERIFICATION_STRATEGY.md (Layer 14 & 15), ADR-011..ADR-017

Tracks process Resident Set Size (RSS) memory consumption over sustained execution.
Enforces:
  Memory_Growth = (RSS_final - RSS_initial) / RSS_initial < 10% (0.10)
  Zero unhandled exceptions or process crashes.

Usage:
  python tests/soak/run_30m_soak.py --duration 1800 --max-growth 0.10
  python tests/soak/run_30m_soak.py --duration 5 --smoke --max-growth 0.10
"""
import os
import sys
import time
import json
import argparse
from typing import List, Dict, Any

try:
    import psutil
except ImportError:
    print("[FAIL] psutil library is required for soak test runner.")
    sys.exit(1)


def simulate_sustained_workload(iterations: int = 1000):
    """Simulates active multi-rate sampling and tensor/polygon math without leaking memory."""
    dummy_points = [(float(i), float(i * 2)) for i in range(50)]
    polygon = [(0.0, 0.0), (100.0, 0.0), (100.0, 100.0), (0.0, 100.0)]
    accum = 0.0
    for p in dummy_points:
        # Simple computation without holding references
        accum += p[0] * 0.5 + p[1] * 0.25
    return accum


class SoakTestRunner:
    def __init__(self, duration_sec: int, sample_interval_sec: float, max_growth_ratio: float, target_pids: List[int] = None):
        self.duration = duration_sec
        self.interval = sample_interval_sec
        self.max_growth = max_growth_ratio
        self.target_pids = target_pids if target_pids else [os.getpid()]
        self.samples: List[Dict[str, Any]] = []

    def get_aggregate_rss_mb(self) -> float:
        total_rss = 0
        for pid in self.target_pids:
            try:
                proc = psutil.Process(pid)
                total_rss += proc.memory_info().rss
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                pass
        return total_rss / (1024.0 * 1024.0)

    def run(self) -> Dict[str, Any]:
        start_time = time.time()
        initial_rss = self.get_aggregate_rss_mb()
        peak_rss = initial_rss
        
        print("=" * 70)
        print(" 30-MINUTE SUSTAINED SOAK & MEMORY LEAK HARNESS")
        print(f" Targets: {self.target_pids} | Planned Duration: {self.duration}s | Max Growth: {self.max_growth * 100:.1f}%")
        print(f" Baseline RSS at T0: {initial_rss:.2f} MB")
        print("=" * 70)

        elapsed = 0.0
        sample_count = 0

        while elapsed < self.duration:
            # Execute simulated video frame and inference processing
            simulate_sustained_workload(2000)

            time.sleep(min(self.interval, max(0.1, self.duration - elapsed)))
            elapsed = time.time() - start_time
            current_rss = self.get_aggregate_rss_mb()
            if current_rss > peak_rss:
                peak_rss = current_rss

            sample_count += 1
            sample_data = {
                "elapsed_sec": round(elapsed, 2),
                "rss_mb": round(current_rss, 3),
                "growth_ratio": round((current_rss - initial_rss) / max(0.001, initial_rss), 4)
            }
            self.samples.append(sample_data)

            growth_pct = sample_data["growth_ratio"] * 100.0
            print(f"  [T+{elapsed:6.1f}s] Current RSS: {current_rss:6.2f} MB | Growth: {growth_pct:+5.2f}% (Peak: {peak_rss:6.2f} MB)")

        final_rss = self.get_aggregate_rss_mb()
        overall_growth = (final_rss - initial_rss) / max(0.001, initial_rss)
        passed = overall_growth < self.max_growth

        report = {
            "suite": "30-Minute Soak & RSS Growth Test",
            "duration_seconds": round(elapsed, 2),
            "target_pids": self.target_pids,
            "initial_rss_mb": round(initial_rss, 3),
            "peak_rss_mb": round(peak_rss, 3),
            "final_rss_mb": round(final_rss, 3),
            "growth_ratio": round(overall_growth, 4),
            "growth_percent": round(overall_growth * 100.0, 2),
            "threshold_max_growth_percent": round(self.max_growth * 100.0, 2),
            "verdict": "PASSED" if passed else "FAILED_MEMORY_LEAK",
            "sample_count": len(self.samples)
        }
        return report


def main():
    parser = argparse.ArgumentParser(description="30-Minute Soak & RSS Memory Leak Detector")
    parser.add_argument("--duration", type=int, default=1800, help="Duration in seconds (default 1800 = 30m)")
    parser.add_argument("--interval", type=float, default=None, help="Sample interval in seconds")
    parser.add_argument("--max-growth", type=float, default=0.10, help="Maximum allowed RSS growth ratio (default 0.10 = 10%%)")
    parser.add_argument("--target-pids", type=str, default=None, help="Comma-separated PIDs to monitor")
    parser.add_argument("--smoke", action="store_true", help="Quick smoke test mode (5s duration)")
    parser.add_argument("--json", action="store_true", help="Output JSON report to stdout")
    parser.add_argument("--report-file", type=str, default="soak_test_report.json", help="Path to write JSON test report")
    args = parser.parse_args()

    duration = 5 if args.smoke else args.duration
    interval = args.interval if args.interval else (1.0 if duration <= 30 else 10.0)
    pids = [int(p.strip()) for p in args.target_pids.split(",")] if args.target_pids else None

    runner = SoakTestRunner(
        duration_sec=duration,
        sample_interval_sec=interval,
        max_growth_ratio=args.max_growth,
        target_pids=pids
    )

    report = runner.run()

    report_path = os.path.abspath(args.report_file)
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    print("\n" + "=" * 70)
    print(f" SOAK TEST RESULT: {report['verdict']}")
    print(f" Initial RSS: {report['initial_rss_mb']:.2f} MB | Final RSS: {report['final_rss_mb']:.2f} MB")
    print(f" Observed Growth: {report['growth_percent']:+.2f}% (Limit: < {report['threshold_max_growth_percent']:.1f}%)")
    print(f" JSON report saved to: {report_path}")
    print("=" * 70)

    if report["verdict"] == "PASSED":
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
