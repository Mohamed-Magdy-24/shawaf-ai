#!/usr/bin/env python3
"""
Master CI Quality Gate Execution Runner
Governing: docs/quality/QUALITY_AND_VERIFICATION_STRATEGY.md, Section 4 (Makefile CI Gate)

Executes all mandated quality assurance gates in sequence:
1. Repository Harness Doctor (scripts/doctor.py)
2. License Compliance Scan (scripts/license_scanner.py)
3. Clean Architecture AST Verification (scripts/verify_architecture_boundaries.py)
4. PostgreSQL 16 RLS Penetration Tests (tests/security/test_rls.py)
5. End-to-End Vertical Slice Tests (tests/e2e/test_vertical_slice.py)
6. Failure-Injection & Recovery Tests (tests/e2e/test_failure_injection.py)
7. Soak Test Smoke Verification (tests/soak/run_30m_soak.py --smoke)
8. Unit Test Suites (pytest ai-workers/tests/ tests/test_harness.py)
"""
import sys
import time
import subprocess
from typing import List, Tuple

GATES: List[Tuple[str, List[str]]] = [
    ("Harness Doctor", [sys.executable, "scripts/doctor.py"]),
    ("License Compliance Scanner", [sys.executable, "scripts/license_scanner.py", "--scan-dir", ".", "--disallow", "GPL,AGPL,SSPL,BUSL,Non-Commercial,CC-BY-NC"]),
    ("Clean Architecture AST Verification", [sys.executable, "scripts/verify_architecture_boundaries.py"]),
    ("PostgreSQL 16 RLS Penetration Suite", [sys.executable, "tests/security/test_rls.py"]),
    ("Vertical Slice Integration Test", [sys.executable, "tests/e2e/test_vertical_slice.py"]),
    ("Failure-Injection & Recovery Suite", [sys.executable, "tests/e2e/test_failure_injection.py"]),
    ("30-Minute Soak Smoke Verification", [sys.executable, "tests/soak/run_30m_soak.py", "--smoke"]),
    ("Harness & Integration Unit Tests", [sys.executable, "-m", "pytest", "tests/"])
]

def main():
    print("=" * 75)
    print(" INDUSTRIAL AI SURVEILLANCE PLATFORM — MASTER CI QUALITY GATES")
    print(" Governing: ADR-011..ADR-017, WP-2, docs/quality/QUALITY_AND_VERIFICATION_STRATEGY.md")
    print("=" * 75)

    all_passed = True
    gate_results = []
    total_start = time.time()

    for name, cmd in GATES:
        print(f"\n>>> EXECUTING GATE: {name}")
        print(f"    Command: {' '.join(cmd)}")
        gate_start = time.time()
        
        proc = subprocess.run(cmd)
        elapsed = time.time() - gate_start
        passed = (proc.returncode == 0)

        gate_results.append((name, passed, elapsed, proc.returncode))
        if not passed:
            all_passed = False
            print(f"!!! GATE FAILED: {name} (Exit code: {proc.returncode})")
            break
        else:
            print(f"--- GATE PASSED: {name} ({elapsed:.2f}s, Exit: 0)")

    total_time = time.time() - total_start
    print("\n" + "=" * 75)
    print(" MASTER CI QUALITY SUMMARY")
    print("=" * 75)
    for name, passed, elapsed, code in gate_results:
        symbol = "[PASS]" if passed else "[FAIL]"
        print(f"  {symbol} {name:<42} (Time: {elapsed:5.2f}s, Exit: {code})")

    print("-" * 75)
    print(f" Total CI Run Time: {total_time:.2f} seconds")

    if all_passed and len(gate_results) == len(GATES):
        print(" [ALL GATES PASSED] Exit code 0 — Ready for Production Approval & Deployment")
        print("=" * 75)
        sys.exit(0)
    else:
        print(" [CI FAILED] One or more mandatory quality gates failed.")
        print("=" * 75)
        sys.exit(1)

if __name__ == "__main__":
    main()
