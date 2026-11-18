# Industrial AI Surveillance Platform Master Makefile
# Governing Standard: ADR-011..ADR-017 & docs/quality/QUALITY_AND_VERIFICATION_STRATEGY.md

.PHONY: all up down test test-unit test-arch test-rls test-e2e test-soak test-soak-smoke scan-licenses doctor ci clean

all: ci

doctor:
	python scripts/doctor.py

scan-licenses:
	python scripts/license_scanner.py --scan-dir . --disallow "GPL,AGPL,SSPL,BUSL,Non-Commercial,CC-BY-NC"

test-arch:
	python scripts/verify_architecture_boundaries.py

test-rls:
	python tests/security/test_rls.py

test-e2e:
	python tests/e2e/test_vertical_slice.py
	python tests/e2e/test_failure_injection.py

test-unit:
	python -m pytest ai-workers/tests/ tests/test_harness.py

test-soak-smoke:
	python tests/soak/run_30m_soak.py --smoke

test-soak:
	python tests/soak/run_30m_soak.py --duration 1800 --max-growth 0.10

test: test-arch test-rls test-e2e test-unit

up:
	docker compose -f deploy/docker-compose.local.yml up -d

down:
	docker compose -f deploy/docker-compose.local.yml down

ci: doctor scan-licenses test-arch test-rls test-e2e test-soak-smoke test-unit
	@echo "=== ALL MANDATORY QUALITY GATES PASSED (EXIT 0) ==="

clean:
	docker compose -f deploy/docker-compose.local.yml down -v
