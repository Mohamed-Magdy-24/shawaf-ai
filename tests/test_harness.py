#!/usr/bin/env python3
"""
Unit Test Suite for QA Verification Harnesses
Tests the testing harnesses themselves (license scanner, boundary verifier, soak runner).
"""
import os
import sys
import tempfile
import unittest

# Add workspace to path
workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, workspace_root)

from scripts.license_scanner import LicenseScanner
from scripts.verify_architecture_boundaries import verify_boundaries
from tests.soak.run_30m_soak import SoakTestRunner

class TestHarnessIntegrity(unittest.TestCase):

    def test_license_scanner_detects_prohibited_agpl_package(self):
        """Verifies that license scanner correctly catches AGPL/Ultralytics violations."""
        with tempfile.TemporaryDirectory() as temp_dir:
            ai_workers_dir = os.path.join(temp_dir, "ai-workers")
            os.makedirs(ai_workers_dir)
            req_path = os.path.join(ai_workers_dir, "requirements.txt")
            with open(req_path, "w") as f:
                f.write("ultralytics==8.0.0\n")

            scanner = LicenseScanner(temp_dir, ["GPL", "AGPL"])
            report = scanner.run()
            self.assertEqual(report["status"], "FAILED_LICENSE_VIOLATION")
            self.assertGreater(report["violations_count"], 0)
            self.assertTrue(any(v.get("package") == "ultralytics" for v in report["violations"]))

    def test_architecture_verifier_detects_layer_violation(self):
        """Verifies that boundary verifier catches domain layer importing infrastructure."""
        with tempfile.TemporaryDirectory() as temp_dir:
            domain_dir = os.path.join(temp_dir, "domain")
            os.makedirs(domain_dir)
            bad_go_file = os.path.join(domain_dir, "bad.go")
            with open(bad_go_file, "w") as f:
                f.write('package domain\nimport "github.com/industrial-ai/surveillance/backend/internal/infrastructure"\n')

            exit_code = verify_boundaries(root_dir=temp_dir, json_output=False)
            self.assertEqual(exit_code, 1, "Expected boundary verification to fail on forbidden import")

    def test_soak_runner_threshold_detection(self):
        """Verifies soak runner flags memory growth exceeding threshold."""
        # Threshold 0.0001 (very small threshold)
        runner = SoakTestRunner(duration_sec=1, sample_interval_sec=0.5, max_growth_ratio=-1.0)
        report = runner.run()
        self.assertEqual(report["verdict"], "FAILED_MEMORY_LEAK")


if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestHarnessIntegrity)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    sys.exit(0 if result.wasSuccessful() else 1)
