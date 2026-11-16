# Shawaf AI — Windows PowerShell Task Runner
param (
    [string]$Task = "test"
)

$VenvPython = Join-Path $PSScriptRoot "ai-workers\.venv\Scripts\python.exe"
if (-not (Test-Path $VenvPython)) {
    $VenvPython = "python"
}

switch ($Task.ToLower()) {
    "test" {
        Write-Host "Running Architectural Conformance Tests..." -ForegroundColor Cyan
        & $VenvPython (Join-Path $PSScriptRoot "tests\arch_test.py")
    }
    "bench" {
        Write-Host "Running SPK-02-LOCAL Benchmark..." -ForegroundColor Cyan
        & $VenvPython (Join-Path $PSScriptRoot "ai-workers\bench\run_spk02_benchmark.py")
    }
    "assets" {
        Write-Host "Generating Synthetic Assets & Cleanroom Model..." -ForegroundColor Cyan
        & $VenvPython (Join-Path $PSScriptRoot "data\generate_synthetic_assets.py")
    }
    "up" {
        Write-Host "Starting Docker Compose services..." -ForegroundColor Cyan
        docker compose -f (Join-Path $PSScriptRoot "deploy\docker-compose.local.yml") up -d
    }
    "down" {
        Write-Host "Stopping Docker Compose services..." -ForegroundColor Cyan
        docker compose -f (Join-Path $PSScriptRoot "deploy\docker-compose.local.yml") down -v
    }
    default {
        Write-Host "Usage: .\make.ps1 [test|bench|assets|up|down]" -ForegroundColor Yellow
    }
}
