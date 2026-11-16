#!/usr/bin/env python3
"""
Archive Manifest Cryptographic Verification Utility
===================================================
Project: Industrial AI Surveillance Platform (BNF/RNF)
Purpose: Independent verification of all payload files against root-level MANIFEST.sha256.
         Verifies SHA-256 hashes computed directly from raw disk bytes.
         Checks for missing files, extra uncataloged files, duplicate entries, and malformed paths.
"""

import os
import sys
import argparse
import hashlib
import re

def compute_sha256(file_path):
    h = hashlib.sha256()
    with open(file_path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest().upper()

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parser = argparse.ArgumentParser(description="Verify package integrity against root MANIFEST.sha256.")
    parser.add_argument(
        "--pack-dir",
        default=script_dir,
        help="Path to project pack root directory (default: script directory)."
    )
    args = parser.parse_args()
    pack_dir = os.path.abspath(args.pack_dir)

    print("=" * 80)
    print(" INDUSTRIAL AI SURVEILLANCE PLATFORM — PACKAGE INTEGRITY VERIFIER")
    print(f" Package Directory: {pack_dir}")
    print("=" * 80)

    if not os.path.isdir(pack_dir):
        print(f"[FATAL] Specified directory does not exist: {pack_dir}")
        sys.exit(1)

    manifest_path = os.path.join(pack_dir, "MANIFEST.sha256")
    if not os.path.isfile(manifest_path):
        print(f"[FATAL] Root manifest file not found: {manifest_path}")
        sys.exit(1)

    # 1. Parse MANIFEST.sha256
    manifest_entries = {}
    duplicate_paths = set()
    malformed_lines = []

    hex64_pattern = re.compile(r"^[0-9A-Fa-f]{64}$")

    with open(manifest_path, "r", encoding="utf-8") as f:
        for line_no, raw_line in enumerate(f, start=1):
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue

            parts = line.split(maxsplit=1)
            if len(parts) != 2:
                malformed_lines.append((line_no, line, "Expected hash and path"))
                continue

            sha256_hash, rel_path = parts[0].strip().upper(), parts[1].strip()

            if not hex64_pattern.match(sha256_hash):
                malformed_lines.append((line_no, line, "Invalid 64-character SHA-256 hash"))
                continue

            # Path validation: reject absolute paths and path traversal
            normalized_rel = rel_path.replace("\\", "/")
            if normalized_rel.startswith("/") or ":" in normalized_rel:
                malformed_lines.append((line_no, line, "Absolute paths prohibited"))
                continue

            path_parts = normalized_rel.split("/")
            if ".." in path_parts or "." in path_parts:
                malformed_lines.append((line_no, line, "Path traversal prohibited"))
                continue

            if normalized_rel in manifest_entries:
                duplicate_paths.add(normalized_rel)
            else:
                manifest_entries[normalized_rel] = sha256_hash

    # 2. Inventory physical files on disk
    disk_files = set()
    for root, _, files in os.walk(pack_dir):
        for f in files:
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, pack_dir).replace(os.sep, "/")
            if rel_path == "MANIFEST.sha256":
                continue  # Self-excluded per standard cryptographic manifest convention
            disk_files.add(rel_path)

    # 3. Check missing and extra files
    missing_files = sorted(list(set(manifest_entries.keys()) - disk_files))
    extra_files = sorted(list(disk_files - set(manifest_entries.keys())))

    # 4. Compute and verify SHA-256 hashes
    hash_mismatches = []
    verified_count = 0

    for rel_path, expected_hash in manifest_entries.items():
        if rel_path in missing_files:
            continue
        full_path = os.path.join(pack_dir, rel_path.replace("/", os.sep))
        try:
            actual_hash = compute_sha256(full_path)
            if actual_hash != expected_hash:
                hash_mismatches.append({
                    "path": rel_path,
                    "expected": expected_hash,
                    "actual": actual_hash
                })
            else:
                verified_count += 1
        except Exception as e:
            hash_mismatches.append({
                "path": rel_path,
                "expected": expected_hash,
                "actual": f"ERROR: {e}"
            })

    # 5. Output Summary
    print(f"\nManifest Entries Parsed : {len(manifest_entries)}")
    print(f"Physical Files on Disk  : {len(disk_files)} (excluding MANIFEST.sha256)")
    print(f"Verified Checksums OK   : {verified_count}")

    has_errors = False

    if malformed_lines:
        has_errors = True
        print(f"\n[FAIL] Malformed Manifest Lines ({len(malformed_lines)}):")
        for line_no, line, reason in malformed_lines:
            print(f"  Line {line_no}: {reason} -> '{line}'")

    if duplicate_paths:
        has_errors = True
        print(f"\n[FAIL] Duplicate Manifest Entries ({len(duplicate_paths)}):")
        for p in sorted(duplicate_paths):
            print(f"  - {p}")

    if missing_files:
        has_errors = True
        print(f"\n[FAIL] Missing Files ({len(missing_files)}):")
        for p in missing_files:
            print(f"  - {p}")

    if extra_files:
        has_errors = True
        print(f"\n[FAIL] Extra Uncataloged Files ({len(extra_files)}):")
        for p in extra_files:
            print(f"  - {p}")

    if hash_mismatches:
        has_errors = True
        print(f"\n[FAIL] SHA-256 Hash Mismatches ({len(hash_mismatches)}):")
        for m in hash_mismatches:
            print(f"  - {m['path']}")
            print(f"      Expected: {m['expected']}")
            print(f"      Actual:   {m['actual']}")

    print("\n" + "=" * 80)
    if has_errors:
        print(" VERIFICATION RESULT: FAILED (Archive integrity compromised)")
        print("=" * 80)
        sys.exit(1)
    else:
        print(" VERIFICATION RESULT: PASSED (100% Cryptographic Integrity Confirmed)")
        print(f" All {verified_count} payload files match root MANIFEST.sha256 exactly.")
        print("=" * 80)
        sys.exit(0)

if __name__ == "__main__":
    main()
