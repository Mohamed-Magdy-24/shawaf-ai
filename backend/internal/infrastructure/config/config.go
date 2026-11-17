package config

import (
	"fmt"
	"os"
	"strconv"
)

// Config encapsulates typed configuration for the edged daemon loaded from environment variables
type Config struct {
	DatabaseURL            string
	HTTPAddr               string
	GRPCAddr               string
	Go2RTCInternalURL      string
	JWTSecret              string
	WorkerSharedToken      string
	EncryptionKey          string
	EvidenceDir            string
	CoverageLostTimeoutSec float64
	SiteBNFID              string
	SiteRNFID              string
}

// Load reads and parses configuration from environment variables
func Load() (*Config, error) {
	dbURL := getEnvFirst([]string{"POSTGRES_DSN", "DATABASE_URL"}, "")
	if dbURL == "" {
		dbURL = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
			getEnvFirst([]string{"POSTGRES_RUNTIME_USER", "POSTGRES_USER"}, "app_runtime"),
			getEnvFirst([]string{"POSTGRES_RUNTIME_PASSWORD", "POSTGRES_PASSWORD"}, "local_dev_runtime_secret_change_me"),
			getEnvFirst([]string{"POSTGRES_HOST"}, "localhost"),
			getEnvFirst([]string{"POSTGRES_PORT"}, "5432"),
			getEnvFirst([]string{"POSTGRES_DB"}, "surveillance"),
		)
	}

	httpAddr := getEnvFirst([]string{"EDGED_HTTP_ADDR", "HTTP_PORT"}, ":8080")
	grpcAddr := getEnvFirst([]string{"EDGED_GRPC_ADDR", "GRPC_PORT"}, ":50051")
	go2rtcURL := getEnvFirst([]string{"GO2RTC_INTERNAL_URL", "GO2RTC_URL"}, "http://localhost:1984")
	jwtSecret := getEnvFirst([]string{"EDGED_JWT_SECRET", "JWT_SECRET"}, "")
	if jwtSecret == "" {
		jwtSecret = "local_dev_jwt_hmac_secret_32bytes_min_0001"
	}

	workerToken := getEnvFirst([]string{"EDGED_WORKER_SHARED_TOKEN", "WORKER_TOKEN"}, "")
	if workerToken == "" {
		workerToken = "local_dev_worker_grpc_shared_secret_token_03"
	}

	encKey := getEnvFirst([]string{"EDGED_ENCRYPTION_KEY", "ENCRYPTION_KEY"}, "")
	if encKey == "" {
		encKey = "local_dev_secret_key_32bytes_min_0001"
	}

	evidenceDir := getEnvFirst([]string{"EDGED_EVIDENCE_DIR", "EVIDENCE_DIR"}, "/var/lib/surveillance/evidence")
	timeoutSecStr := getEnvFirst([]string{"EDGED_COVERAGE_LOST_TIMEOUT_SEC", "COVERAGE_LOST_TIMEOUT_SECONDS"}, "15.0")
	timeoutSec, err := strconv.ParseFloat(timeoutSecStr, 64)
	if err != nil {
		timeoutSec = 15.0
	}

	return &Config{
		DatabaseURL:            dbURL,
		HTTPAddr:               httpAddr,
		GRPCAddr:               grpcAddr,
		Go2RTCInternalURL:      go2rtcURL,
		JWTSecret:              jwtSecret,
		WorkerSharedToken:      workerToken,
		EncryptionKey:          encKey,
		EvidenceDir:            evidenceDir,
		CoverageLostTimeoutSec: timeoutSec,
		SiteBNFID:              getEnvFirst([]string{"SITE_BNF_ID"}, "11111111-1111-1111-1111-111111111111"),
		SiteRNFID:              getEnvFirst([]string{"SITE_RNF_ID"}, "22222222-2222-2222-2222-222222222222"),
	}, nil
}

func getEnvFirst(keys []string, fallback string) string {
	for _, key := range keys {
		if val := os.Getenv(key); val != "" {
			return val
		}
	}
	return fallback
}
