package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "github.com/lib/pq"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/config"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/governance"
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

	// 1. Reconcile Configuration via Typed Config
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("[Init] Failed to load configuration: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// 2. Database Connection Pool
	log.Printf("[Init] Connecting to PostgreSQL at %s ...", cfg.DatabaseURL)
	db, err := sql.Open("postgres", cfg.DatabaseURL)
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
	dispatcher.Start(ctx, cfg.DatabaseURL)
	defer dispatcher.Stop()

	// 6. Coverage-Lost Watchdog (NFR-OBS-002: < 15s)
	watchdog := application.NewCoverageWatchdog(db, pgRepo, cfg.CoverageLostTimeoutSec)
	watchdog.Start(ctx)
	defer watchdog.Stop()

	// 7. Go2rtc Zero-Trust Proxy & Stream Gateway
	go2rtcProxy := go2rtc.NewProxy(cfg.Go2RTCInternalURL)
	streamGateway := go2rtc.NewStreamGateway(cfg.Go2RTCInternalURL)
	identityAdapter := governance.NewBlockedIdentityAdapter()

	// 8. gRPC Ingestion Server with Shared-Secret Auth
	grpcServer := grpcserver.NewIngestionServer(cfg.GRPCAddr, ingestionSvc, cfg.WorkerSharedToken)
	if err := grpcServer.Start(); err != nil {
		log.Printf("[gRPC] Warning: gRPC listener failed to start on %s: %v", cfg.GRPCAddr, err)
	}
	defer grpcServer.Stop()

	// 9. HTTP REST & WebSocket Server (with Hexagonal Integration Ports)
	apiServer := httpapi.NewServer(db, pgRepo, ingestionSvc, go2rtcProxy, wsHub, cfg.JWTSecret)
	apiServer.SetEncryptionKey(cfg.EncryptionKey)
	apiServer.SetEvidenceDir(cfg.EvidenceDir)
	apiServer.SetPorts(pgRepo, streamGateway, identityAdapter, identityAdapter)
	mux := http.NewServeMux()
	apiServer.RegisterRoutes(mux)

	httpServer := &http.Server{
		Addr:         cfg.HTTPAddr,
		Handler:      apiServer.Handler(mux),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
	}

	go func() {
		log.Printf("[HTTP] Shawaf AI API & WebSocket listening on %s", cfg.HTTPAddr)
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

