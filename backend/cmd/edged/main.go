package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	_ "github.com/lib/pq"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/grpcserver"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/outbox"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/postgres"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/httpapi"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/ws"
)

func main() {
	log.Println("=================================================================")
	log.Println("   SHAWAF AI (شوف AI) — Industrial Surveillance Edge Daemon (edged)")
	log.Println("   Architecture: On-Premises Multi-Site Edge with RLS Isolation")
	log.Println("=================================================================")

	// 1. Reconcile Configuration (Support both compose and standalone env keys)
	dbURL := getEnvFirst([]string{"POSTGRES_DSN", "DATABASE_URL"}, "postgres://app_runtime:local_dev_runtime_secret_change_me@localhost:5432/surveillance?sslmode=disable")
	httpAddr := getEnvFirst([]string{"EDGED_HTTP_ADDR", "HTTP_PORT"}, ":8080")
	grpcAddr := getEnvFirst([]string{"EDGED_GRPC_ADDR", "GRPC_PORT"}, ":50051")
	go2rtcURL := getEnvFirst([]string{"GO2RTC_INTERNAL_URL", "GO2RTC_URL"}, "http://localhost:1984")
	jwtSecret := getEnvFirst([]string{"EDGED_JWT_SECRET", "JWT_SECRET"}, "local_dev_jwt_hmac_secret_32bytes_min_0001")
	workerToken := getEnvFirst([]string{"EDGED_WORKER_SHARED_TOKEN", "WORKER_TOKEN"}, "local_dev_worker_grpc_shared_secret_token_03")
	timeoutSecStr := getEnvFirst([]string{"EDGED_COVERAGE_LOST_TIMEOUT_SEC", "COVERAGE_LOST_TIMEOUT_SECONDS"}, "15.0")

	timeoutSec, err := strconv.ParseFloat(timeoutSecStr, 64)
	if err != nil {
		timeoutSec = 15.0
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// 2. Database Connection Pool
	log.Printf("[Init] Connecting to PostgreSQL at %s ...", dbURL)
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("[Init] Failed to open PostgreSQL connection: %v", err)
	}
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err := db.Ping(); err != nil {
		log.Printf("[Init] Warning: PostgreSQL not reachable at startup (%v). Daemon will continue in stand-by.", err)
	} else {
		log.Println("[Init] PostgreSQL connected and verified.")
	}
	defer db.Close()

	// 3. Domain Repositories & Application Services
	pgRepo := postgres.NewPostgresRepo(db)
	ingestionSvc := application.NewIngestionService(pgRepo)

	// 4. WebSocket Hub
	wsHub := ws.NewHub()
	go wsHub.Run()

	// 5. Outbox Dispatcher (SKIP LOCKED + LISTEN/NOTIFY)
	dispatcher := outbox.NewDispatcher(db)
	dispatcher.RegisterChannel(wsHub)
	dispatcher.Start(ctx, dbURL)
	defer dispatcher.Stop()

	// 6. Coverage-Lost Watchdog (NFR-OBS-002: < 15s)
	watchdog := application.NewCoverageWatchdog(db, pgRepo, timeoutSec)
	watchdog.Start(ctx)
	defer watchdog.Stop()

	// 7. Go2rtc Zero-Trust Proxy
	go2rtcProxy := go2rtc.NewProxy(go2rtcURL)

	// 8. gRPC Ingestion Server with Shared-Secret Auth
	grpcServer := grpcserver.NewIngestionServer(grpcAddr, ingestionSvc, workerToken)
	if err := grpcServer.Start(); err != nil {
		log.Printf("[gRPC] Warning: gRPC listener failed to start on %s: %v", grpcAddr, err)
	}
	defer grpcServer.Stop()

	// 9. HTTP REST & WebSocket Server
	apiServer := httpapi.NewServer(db, pgRepo, ingestionSvc, go2rtcProxy, wsHub, jwtSecret)
	mux := http.NewServeMux()
	apiServer.RegisterRoutes(mux)

	httpServer := &http.Server{
		Addr:         httpAddr,
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}

	go func() {
		log.Printf("[HTTP] Shawaf AI API & WebSocket listening on %s", httpAddr)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("[HTTP] Server fatal: %v", err)
		}
	}()

	// 10. Graceful Shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
	<-sigCh

	log.Println("\n[Shutdown] Termination signal received. Initiating graceful shutdown...")
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownCancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		log.Printf("[Shutdown] HTTP server forced shutdown: %v", err)
	}

	log.Println("[Shutdown] Shawaf AI Edge Daemon stopped safely.")
}

func getEnvFirst(keys []string, defaultVal string) string {
	for _, k := range keys {
		if val := os.Getenv(k); val != "" {
			return val
		}
	}
	return defaultVal
}
