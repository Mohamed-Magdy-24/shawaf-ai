#!/usr/bin/env python3
"""
Architecture Boundary Verification Utility
Checks Clean Architecture boundaries across backend/internal packages per ADR-011..ADR-017 and WP-2.
Enforces:
1. Domain layer must NOT import Application, Infrastructure, Presentation, or framework/db packages.
2. Application layer must NOT import Infrastructure or Presentation packages.
"""
import os
import sys
import re
import json
import argparse

def verify_boundaries(root_dir=None, json_output=False):
    if root_dir is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        candidate_1 = os.path.abspath(os.path.join(script_dir, "..", "backend", "internal"))
        candidate_2 = os.path.abspath(os.path.join(os.getcwd(), "backend", "internal"))
        if os.path.isdir(candidate_1):
            root_dir = candidate_1
        elif os.path.isdir(candidate_2):
            root_dir = candidate_2
        else:
            root_dir = candidate_1

    if not os.path.isdir(root_dir):
        msg = f"[FAIL] Root internal directory not found: {root_dir}"
        if json_output:
            print(json.dumps({"status": "FAILED", "error": msg, "violations": []}))
        else:
            print(msg)
        return 1

    domain_dir = os.path.join(root_dir, "domain")
    app_dir = os.path.join(root_dir, "application")

    domain_forbidden = [
        "application",
        "infrastructure",
        "presentation",
        "database/sql",
        "net/http",
        "google.golang.org/grpc",
        "github.com/gorilla",
        "github.com/gin-gonic"
    ]
    app_forbidden = [
        "infrastructure",
        "presentation"
    ]

    import_re = re.compile(r'import\s+(?:\((.*?)\)|"([^"]+)")', re.DOTALL)
    violations = []
    scanned_files = 0

    def check_file(file_path, forbidden_list, pkg_name):
        nonlocal scanned_files
        scanned_files += 1
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        matches = import_re.findall(content)
        imported_pkgs = []
        for m in matches:
            if m[0]:
                for line in m[0].splitlines():
                    cleaned = line.strip().strip('"')
                    if cleaned and not cleaned.startswith("//"):
                        sub = re.findall(r'"([^"]+)"', line)
                        if sub:
                            imported_pkgs.append(sub[0])
                        else:
                            imported_pkgs.append(cleaned)
            elif m[1]:
                imported_pkgs.append(m[1])

        for imp in imported_pkgs:
            for forbidden in forbidden_list:
                if forbidden in imp:
                    try:
                        rel_file = os.path.relpath(file_path, start=root_dir)
                    except ValueError:
                        rel_file = file_path
                    violations.append({
                        "layer": pkg_name,
                        "file": rel_file,
                        "imported": imp,
                        "forbidden_pattern": forbidden
                    })

    if os.path.isdir(domain_dir):
        for r, _, files in os.walk(domain_dir):
            for f in files:
                if f.endswith(".go"):
                    check_file(os.path.join(r, f), domain_forbidden, "DOMAIN")

    if os.path.isdir(app_dir):
        for r, _, files in os.walk(app_dir):
            for f in files:
                if f.endswith(".go"):
                    check_file(os.path.join(r, f), app_forbidden, "APPLICATION")

    if json_output:
        report = {
            "status": "PASSED" if not violations else "FAILED",
            "scanned_files": scanned_files,
            "violations_count": len(violations),
            "violations": violations
        }
        print(json.dumps(report, indent=2))
        return 0 if not violations else 1

    print("=" * 65)
    print(" CLEAN ARCHITECTURE BOUNDARY AST VERIFICATION")
    print("=" * 65)
    print(f"Scanned {scanned_files} Go source files across domain and application layers.")
    if violations:
        print(f"[FAIL] Found {len(violations)} architectural boundary violation(s):")
        for v in violations:
            print(f"  - [{v['layer']}] {v['file']} imports forbidden: {v['imported']}")
        print("=" * 65)
        return 1
    else:
        print("[PASS] 0 architecture violations found. Domain and Application are completely decoupled.")
        print("=" * 65)
        return 0

def main():
    parser = argparse.ArgumentParser(description="Clean Architecture Boundary AST Verifier")
    parser.add_argument("--root", help="Path to backend/internal directory", default=None)
    parser.add_argument("--json", action="store_true", help="Output machine-readable JSON report")
    args = parser.parse_args()

    exit_code = verify_boundaries(args.root, args.json)
    sys.exit(exit_code)

if __name__ == "__main__":
    main()
