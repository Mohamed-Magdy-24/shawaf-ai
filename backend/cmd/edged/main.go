package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/industrial-ai/surveillance/backend/internal/application"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/go2rtc"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/grpcserver"
	"github.com/industrial-ai/surveillance/backend/internal/infrastructure/postgres"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/httpapi"
	"github.com/industrial-ai/surveillance/backend/internal/presentation/ws"
	"google.golang.org/grpc"
)

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}

func main() {
	log.Println("=================================================================")
	log.Println(" Industrial AI Surveillance Edge Daemon (edged)")
	log.Println(" Architecture: Go Clean Architecture + PostgreSQL 16 RLS")
	log.Println(" Governing Standards: ADR-011..ADR-017, Step 4.1..4.5")
	log.Println("=================================================================")

	// 1. Environment Configurations
	httpAddr := getEnv("HTTP_LISTEN_ADDR", ":8080")
	grpcAddr := getEnv("GRPC_LISTEN_ADDR", ":50051")
	databaseURL := getEnv("DATABASE_URL", "postgres://app_runtime:runtime_secret_dev_pass@127.0.0.1:5432/surveillance_dev?sslmode=disable")
	go2rtcURL := getEnv("GO2RTC_API_URL", "http://go2rtc:1984")
	sharedSecret := getEnv("SHARED_SECRET_TOKEN", "dev_shared_secret_token_change_in_prod")
	snapshotDir := getEnv("SNAPSHOT_BASE_DIR", "/var/lib/surveillance/snapshots")

	pollIntervalMs, _ := strconv.Atoi(getEnv("OUTBOX_POLL_INTERVAL_MS", "100"))
	if pollIntervalMs <= 0 {
		pollIntervalMs = 100
	}
	reaperIntervalSec, _ := strconv.Atoi(getEnv("LEASE_REAPER_INTERVAL_SEC", "10"))
	if reaperIntervalSec <= 0 {
		reaperIntervalSec = 10
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// 2. Database Connection & Privileged Schema Migrations
	migratorURL := getEnv("MIGRATOR_DATABASE_URL", "")
	if migratorURL != "" {
		log.Println("[INFO] Connecting with dedicated migration role to execute schema migrations...")
		migDB, err := postgres.NewDB(migratorURL)
		if err != nil {
			log.Fatalf("[FATAL] Failed to connect using migration credentials: %v", err)
		}
		migCtx, migCancel := context.WithTimeout(ctx, 30*time.Second)
		if err := migDB.RunMigrations(migCtx); err != nil {
			migCancel()
			migDB.Close()
			log.Fatalf("[FATAL] Privileged schema migration failed: %v", err)
		}
		migCancel()
		migDB.Close()
	}

	// Connect with unprivileged app_runtime connection
	db, err := postgres.NewDB(databaseURL)
	if err != nil {
		log.Fatalf("[FATAL] Failed to initialize database: %v", err)
	}
	defer db.Close()

	// Verify schema is available and fail closed if unavailable
	verifyCtx, verifyCancel := context.WithTimeout(ctx, 5*time.Second)
	if err := db.VerifySchema(verifyCtx); err != nil {
		verifyCancel()
		log.Fatalf("[FATAL] Application failing closed: schema unavailable for app_runtime: %v", err)
	}
	verifyCancel()

	// 3. Infrastructure Repositories
	incidentRepo := postgres.NewIncidentRepository(db)
	cameraRepo := postgres.NewCameraRepository(db)
	outboxRepo := postgres.NewOutboxRepository(db)

	// 4. WebSocket Hub (Broadcaster Port)
	wsHub := ws.NewHub()
	go wsHub.Run()

	// 5. Application Services
	eventService := application.NewEventService(incidentRepo, outboxRepo, cameraRepo)
	cameraService := application.NewCameraService(cameraRepo, eventService)
	ticketService := application.NewTicketService()
	outboxService := application.NewOutboxService(outboxRepo, wsHub)

	// 6. Transactional Outbox Background Dispatcher & Lease Reaper Loops
	wakeDispatchChan := make(chan struct{}, 1)
	triggerImmediateDispatch := func() {
		select {
		case wakeDispatchChan <- struct{}{}:
		default:
		}
	}

	// 6a. PostgreSQL LISTEN outbox_fire (fast-path fire alerts)
	fireListener := postgres.NewFireAlertListener(databaseURL, triggerImmediateDispatch)
	fireListener.Start(ctx)

	// 6b. Outbox Dispatcher Loop
	go func() {
		ticker := time.NewTicker(time.Duration(pollIntervalMs) * time.Millisecond)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				_, _ = outboxService.DispatchPending(ctx, 50, 30*time.Second)
			case <-wakeDispatchChan:
				log.Println("[INFO] Immediate outbox dispatch triggered by fire notification")
				_, _ = outboxService.DispatchPending(ctx, 50, 30*time.Second)
			}
		}
	}()

	// 6c. Lease Reaper Loop (Recovers crashed/killed PROCESSING outbox rows)
	go func() {
		// Run immediate reap on startup to catch any orphaned records from prior shutdown/crash
		reapCtx, reapCancel := context.WithTimeout(ctx, 5*time.Second)
		_, _ = outboxService.ReapExpiredLeases(reapCtx)
		reapCancel()

		ticker := time.NewTicker(time.Duration(reaperIntervalSec) * time.Second)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				_, _ = outboxService.ReapExpiredLeases(ctx)
			}
		}
	}()

	// 7. Zero-Trust go2rtc SDP Proxy Client
	go2rtcProxy := go2rtc.NewSDPProxyClient(go2rtcURL)

	// 8. HTTP & WebSocket Server
	authenticator := httpapi.NewAuthenticator(sharedSecret)
	httpHandler := httpapi.NewHandler(
		eventService,
		cameraService,
		ticketService,
		wsHub,
		go2rtcProxy,
		snapshotDir,
		authenticator,
	)
	httpMux := http.NewServeMux()
	httpHandler.RegisterRoutes(httpMux)

	httpServer := &http.Server{
		Addr:         httpAddr,
		Handler:      httpMux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		log.Printf("[INFO] HTTP REST & WebSocket API listening on %s", httpAddr)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("[FATAL] HTTP server failed: %v", err)
		}
	}()

	// 9. gRPC Ingestion Server (Zero Raw Frames over gRPC)
	grpcLis, err := net.Listen("tcp", grpcAddr)
	if err != nil {
		log.Fatalf("[FATAL] Failed to listen on gRPC addr %s: %v", grpcAddr, err)
	}

	grpcServerImpl := grpcserver.NewServer(eventService, cameraService, sharedSecret, triggerImmediateDispatch)
	grpcSrv := grpc.NewServer()
	grpcserver.Register(grpcSrv, grpcServerImpl)

	go func() {
		log.Printf("[INFO] gRPC Ingestion server listening on %s (Zero Raw Frames enforced)", grpcAddr)
		if err := grpcSrv.Serve(grpcLis); err != nil {
			log.Fatalf("[FATAL] gRPC server error: %v", err)
		}
	}()

	// 10. Graceful Shutdown Coordinator
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	sig := <-sigChan
	log.Printf("[INFO] Received signal %v; initiating graceful shutdown...", sig)

	// Cancel background loops
	cancel()

	// Stop gRPC server gracefully
	grpcSrv.GracefulStop()
	log.Println("[INFO] gRPC server stopped.")

	// Shutdown HTTP server with 10s deadline
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownCancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		log.Printf("[ERROR] HTTP server shutdown error: %v", err)
	}
	log.Println("[INFO] HTTP server stopped.")

	fmt.Println("[INFO] edged daemon exited cleanly.")
}
