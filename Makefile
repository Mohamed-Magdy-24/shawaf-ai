# Shawaf AI — Build & Operational Makefile

.PHONY: all build test bench up down clean

all: test bench

build:
	docker compose -f deploy/docker-compose.local.yml build

up:
	docker compose -f deploy/docker-compose.local.yml up -d

down:
	docker compose -f deploy/docker-compose.local.yml down -v

test:
	python tests/arch_test.py

bench:
	python ai-workers/bench/run_spk02_benchmark.py

generate-assets:
	python data/generate_synthetic_assets.py

clean:
	rm -rf data/synthetic/*.mp4 data/models/*.onnx
