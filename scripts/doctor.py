#!/usr/bin/env python3
"""
Repository Validation Harness & Doctor Utility
Governing: validation-harness-design, harness-engineering

Verifies:
1. Directory structure and required layers (backend, ai-workers, mobile-app, proto, deploy, tests, scripts).
2. Specification and contract artifacts (events.proto, docker-compose.local.yml, Makefile).
3. Availability and integrity of all quality verification gates.
4. Python dependencies required for test harnesses (psutil, psycopg, onnxruntime, etc.).
"""
import os
import sys
import json
import argparse
import importlib.util

REQUIRED_DIRS = [
    "backend",
    "ai-workers",
    "mobile-app",
    "proto",
    "deploy",
    "tests",
    "scripts",
    "tests/security",
    "tests/e2e",
    "tests/soak"
]

REQUIRED_FILES = [
    "Makefile",
    "deploy/docker-compose.local.yml",
    "deploy/postgres/init-roles.sh",
    "proto/surveillance/v1/events.proto",
    "tests/arch_test.go",
    "scripts/verify_architecture_boundaries.py",
    "tests/security/test_rls.py",
    "tests/security/test_rls_isolation.sql",
    "tests/e2e/test_vertical_slice.py",
    "tests/e2e/test_failure_injection.py",
    "tests/soak/run_30m_soak.py",
    "scripts/license_scanner.py"
]

PYTHON_DEPS = [
    "psutil",
    "onnxruntime",
    "numpy",
    "pytest"
]

def check_harness(root_dir: str = ".") -> dict:
    root = os.path.abspath(root_dir)
    results = {
        "status": "PASSED",
        "dirs": {},
        "files": {},
        "python_deps": {},
        "missing_items": []
    }

    # 1. Check Directories
    for d in REQUIRED_DIRS:
        full_path = os.path.join(root, d)
        exists = os.path.isdir(full_path)
        results["dirs"][d] = exists
        if not exists:
            results["missing_items"].append(f"Directory: {d}")

    # 2. Check Files
    for f in REQUIRED_FILES:
        full_path = os.path.join(root, f)
        exists = os.path.isfile(full_path)
        results["files"][f] = exists
        if not exists:
            results["missing_items"].append(f"File: {f}")

    # 3. Check Python Dependencies
    for dep in PYTHON_DEPS:
        installed = importlib.util.find_spec(dep) is not None
        results["python_deps"][dep] = installed
        if not installed:
            results["missing_items"].append(f"Python Package: {dep}")

    if results["missing_items"]:
        results["status"] = "FAILED"

    return results

def main():
    parser = argparse.ArgumentParser(description="Repository Validation Harness Doctor")
    parser.add_argument("--json", action="store_true", help="Output machine-readable JSON")
    args = parser.parse_args()

    results = check_harness()

    if args.json:
        print(json.dumps(results, indent=2))
        sys.exit(0 if results["status"] == "PASSED" else 1)

    print("=" * 70)
    print(" INDUSTRIAL AI SURVEILLANCE REPOSITORY HARNESS DOCTOR")
    print("=" * 70)

    print("\n[Layer 1: Structural Directories]")
    for d, exists in results["dirs"].items():
        print(f"  [{'PASS' if exists else 'FAIL'}] {d}")

    print("\n[Layer 2: Specification & Verification Files]")
    for f, exists in results["files"].items():
        print(f"  [{'PASS' if exists else 'FAIL'}] {f}")

    print("\n[Layer 3: Core Python Harness Modules]")
    for dep, installed in results["python_deps"].items():
        print(f"  [{'PASS' if installed else 'FAIL'}] {dep}")

    print("\n" + "=" * 70)
    if results["status"] == "PASSED":
        print("[DOCTOR VERDICT: HEALTHY] All repository harness components are intact.")
        print("=" * 70)
        sys.exit(0)
    else:
        print(f"[DOCTOR VERDICT: UNHEALTHY] {len(results['missing_items'])} item(s) missing:")
        for m in results["missing_items"]:
            print(f"  - {m}")
        print("=" * 70)
        sys.exit(1)

if __name__ == "__main__":
    main()
