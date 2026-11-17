package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"sort"
	"sync"
	"time"
)

type BenchmarkResult struct {
	Endpoint   string
	TotalReqs  int
	SuccessReqs int
	Duration   time.Duration
	P50Ms      float64
	P95Ms      float64
	P99Ms      float64
	Throughput float64
}

func main() {
	baseURL := os.Getenv("BENCH_BASE_URL")
	if baseURL == "" {
		baseURL = "http://localhost:8080"
	}

	client := &http.Client{
		Timeout: 5 * time.Second,
		Transport: &http.Transport{
			MaxIdleConns:        100,
			MaxIdleConnsPerHost: 50,
			IdleConnTimeout:     90 * time.Second,
		},
	}

	fmt.Println("=================================================================")
	fmt.Println(" SHAWAF AI — High-Throughput LAN Latency & Scalability Benchmark")
	fmt.Printf(" Target Base URL: %s | Total: 1,000 reqs/endpoint | Concurrency: 20\n", baseURL)
	fmt.Println("=================================================================")

	// 1. Authenticate to obtain JWT Bearer Token
	loginBody, _ := json.Marshal(map[string]string{
		"username": "admin_corp",
		"password": "AdminPassword123!",
	})
	resp, err := client.Post(baseURL+"/api/v1/auth/login", "application/json", bytes.NewReader(loginBody))
	if err != nil {
		fmt.Printf("FATAL: Failed to reach login endpoint: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		fmt.Printf("FATAL: Login failed (status %d): %s\n", resp.StatusCode, string(b))
		os.Exit(1)
	}

	var authResp struct {
		Token string `json:"token"`
	}
	_ = json.NewDecoder(resp.Body).Decode(&authResp)
	token := authResp.Token
	fmt.Printf("[Auth] Successfully logged in. JWT token acquired (prefix: %s...)\n\n", token[:20])

	// Connection & socket warm-up
	for i := 0; i < 20; i++ {
		req, _ := http.NewRequest("GET", baseURL+"/healthz", nil)
		if r, err := client.Do(req); err == nil {
			io.Copy(io.Discard, r.Body)
			r.Body.Close()
		}
	}

	endpoints := []struct {
		Name string
		Path string
	}{
		{Name: "Health Check (/healthz)", Path: "/healthz"},
		{Name: "Sites Directory (/api/v1/sites)", Path: "/api/v1/sites"},
		{Name: "Alerts Inbox (/api/v1/sites/{id}/alerts/inbox)", Path: "/api/v1/sites/11111111-1111-1111-1111-111111111111/alerts/inbox"},
		{Name: "Presence Radar (/api/v1/sites/{id}/presence)", Path: "/api/v1/sites/11111111-1111-1111-1111-111111111111/presence"},
	}

	var results []BenchmarkResult

	for _, ep := range endpoints {
		res := runBenchmark(client, baseURL+ep.Path, ep.Name, token, 1000, 20)
		results = append(results, res)
	}

	fmt.Println("\n=========================================================================================")
	fmt.Println("                       OFFICIAL CTO BENCHMARK SCORECARD")
	fmt.Println("=========================================================================================")
	fmt.Printf("%-42s | %-6s | %-8s | %-8s | %-8s | %-10s | %s\n", "Endpoint", "Reqs", "p50 (ms)", "p95 (ms)", "p99 (ms)", "Reqs/sec", "Status")
	fmt.Println("-------------------------------------------+--------+----------+----------+----------+------------+-------")

	allPassed := true
	for _, r := range results {
		pass := r.P95Ms <= 10.0 && r.SuccessReqs == r.TotalReqs
		statusStr := "PASS"
		if !pass {
			statusStr = fmt.Sprintf("FAIL (%d/%d ok)", r.SuccessReqs, r.TotalReqs)
			allPassed = false
		}
		fmt.Printf("%-42s | %-6d | %8.2f | %8.2f | %8.2f | %10.1f | %s\n",
			r.Endpoint, r.TotalReqs, r.P50Ms, r.P95Ms, r.P99Ms, r.Throughput, statusStr)
	}
	fmt.Println("=========================================================================================")
	if allPassed {
		fmt.Println("[VERIFICATION PASSED] All endpoints satisfy strict <10ms LAN p95 latency constraint.")
	} else {
		fmt.Println("[VERIFICATION FAILED] One or more endpoints exceeded 10.0ms p95 latency.")
	}
}

func runBenchmark(client *http.Client, targetURL, name, token string, totalReqs, concurrency int) BenchmarkResult {
	fmt.Printf("--> Benchmarking: %s ... ", name)

	latencies := make([]float64, totalReqs)
	var successCount int64
	var mu sync.Mutex

	reqPerWorker := totalReqs / concurrency
	var wg sync.WaitGroup
	startTime := time.Now()

	for c := 0; c < concurrency; c++ {
		wg.Add(1)
		go func(workerID int) {
			defer wg.Done()
			for i := 0; i < reqPerWorker; i++ {
				idx := workerID*reqPerWorker + i
				req, _ := http.NewRequest(http.MethodGet, targetURL, nil)
				if token != "" {
					req.Header.Set("Authorization", "Bearer "+token)
				}
				t0 := time.Now()
				resp, err := client.Do(req)
				durMs := float64(time.Since(t0).Microseconds()) / 1000.0
				latencies[idx] = durMs

				if err == nil && (resp.StatusCode == http.StatusOK || resp.StatusCode == http.StatusCreated) {
					mu.Lock()
					successCount++
					mu.Unlock()
					_ = resp.Body.Close()
				} else if resp != nil {
					mu.Lock()
					if successCount == 0 {
						b, _ := io.ReadAll(resp.Body)
						fmt.Printf("\n[Error Status %d]: %s\n", resp.StatusCode, string(b))
					}
					mu.Unlock()
					_ = resp.Body.Close()
				}
			}
		}(c)
	}

	wg.Wait()
	totalDuration := time.Since(startTime)

	sort.Float64s(latencies)
	p50 := latencies[int(float64(totalReqs)*0.50)]
	p95 := latencies[int(float64(totalReqs)*0.95)]
	p99 := latencies[int(float64(totalReqs)*0.99)]
	throughput := float64(totalReqs) / totalDuration.Seconds()

	fmt.Printf("DONE in %.2fs (p50: %.2fms, p95: %.2fms, p99: %.2fms)\n", totalDuration.Seconds(), p50, p95, p99)

	return BenchmarkResult{
		Endpoint:    name,
		TotalReqs:   totalReqs,
		SuccessReqs: int(successCount),
		Duration:    totalDuration,
		P50Ms:       p50,
		P95Ms:       p95,
		P99Ms:       p99,
		Throughput:  throughput,
	}
}
