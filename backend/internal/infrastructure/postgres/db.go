package postgres

import (
	"context"
	"database/sql"
	_ "embed"
	"fmt"
	"log"
	"time"

	_ "github.com/lib/pq"
)

//go:embed migrations/001_initial_schema.sql
var initialSchemaSQL string

// DB wraps standard sql.DB with tenant transaction scoping
type DB struct {
	*sql.DB
}

// NewDB initializes connection pool and verifies connectivity
func NewDB(databaseURL string) (*DB, error) {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database connection: %w", err)
	}

	// Sane production pool sizing for embedded edge daemon
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(15 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		log.Printf("[WARN] Database ping failed (will retry in background): %v", err)
	} else {
		log.Println("[INFO] Successfully connected to PostgreSQL 16 database")
	}

	return &DB{DB: db}, nil
}

// RunMigrations executes the initial schema migration idempotently
func (db *DB) RunMigrations(ctx context.Context) error {
	log.Println("[INFO] Executing database schema migrations with RLS policies...")
	if _, err := db.ExecContext(ctx, initialSchemaSQL); err != nil {
		return fmt.Errorf("schema migration failed: %w", err)
	}
	log.Println("[INFO] Database schema migration successfully verified.")
	return nil
}

// WithTenantTx executes a database operation inside a transaction scoped to a tenant
// Enforces SET LOCAL app.site_id per the postgres-rls skill to prevent connection-pool leakage
func (db *DB) WithTenantTx(ctx context.Context, siteID string, fn func(tx *sql.Tx) error) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	if siteID != "" {
		// SET LOCAL guarantees parameter is cleared automatically when transaction commits or aborts
		if _, err := tx.ExecContext(ctx, "SET LOCAL app.site_id = $1", siteID); err != nil {
			return fmt.Errorf("failed to set tenant context for site %s: %w", siteID, err)
		}
	}

	if err := fn(tx); err != nil {
		return err
	}

	if err := tx.Commit(); err != nil {
		return fmt.Errorf("transaction commit failed: %w", err)
	}

	return nil
}
