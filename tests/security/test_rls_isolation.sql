-- ============================================================================
-- Industrial AI Surveillance Platform: Multi-Tenant Row-Level Security (RLS)
-- Governing Standards: ADR-011, ADR-013, PostgreSQL 16 NOBYPASSRLS Strict Isolation
-- ============================================================================

-- 1. Create Roles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_migrator') THEN
        CREATE ROLE app_migrator WITH LOGIN PASSWORD 'migrator_secret_dev_pass';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_runtime') THEN
        CREATE ROLE app_runtime WITH LOGIN PASSWORD 'runtime_secret_dev_pass'
            NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'outbox_dispatcher') THEN
        CREATE ROLE outbox_dispatcher WITH LOGIN PASSWORD 'dispatcher_secret_dev_pass'
            NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
    END IF;
END
$$;

-- 2. Schema Privileges
GRANT USAGE ON SCHEMA public TO app_runtime;
GRANT USAGE ON SCHEMA public TO outbox_dispatcher;

-- 3. Core Tables
CREATE TABLE IF NOT EXISTS sites (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    location VARCHAR(256) NOT NULL,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cameras (
    id VARCHAR(64) PRIMARY KEY,
    site_id VARCHAR(32) NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    rtsp_main_url TEXT NOT NULL,
    rtsp_sub_url TEXT,
    zone_id VARCHAR(64),
    status VARCHAR(32) NOT NULL DEFAULT 'ONLINE',
    fps_decoded DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    dropped_frames BIGINT NOT NULL DEFAULT 0,
    last_heartbeat TIMESTAMPTZ,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
    id VARCHAR(64) PRIMARY KEY,
    site_id VARCHAR(32) NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    camera_id VARCHAR(64) NOT NULL REFERENCES cameras(id) ON DELETE CASCADE,
    zone_id VARCHAR(64),
    event_type VARCHAR(64) NOT NULL,
    severity VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'NEW',
    occurred_at_utc TIMESTAMPTZ NOT NULL,
    model_id VARCHAR(64),
    model_version VARCHAR(32),
    confidence REAL NOT NULL DEFAULT 0.0,
    snapshot_rel_path VARCHAR(256),
    acknowledged_by VARCHAR(64),
    acknowledged_at TIMESTAMPTZ,
    resolved_by VARCHAR(64),
    resolved_at TIMESTAMPTZ,
    dismissal_reason TEXT,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS outbox (
    id BIGSERIAL PRIMARY KEY,
    site_id VARCHAR(32) NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    event_id VARCHAR(64) NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    payload BYTEA NOT NULL,
    is_fire_priority BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    locked_until TIMESTAMPTZ,
    retry_count INT NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Composite Index for site-filtered queries
CREATE INDEX IF NOT EXISTS idx_cameras_site ON cameras(site_id);
CREATE INDEX IF NOT EXISTS idx_events_site_status ON events(site_id, status);
CREATE INDEX IF NOT EXISTS idx_outbox_queue ON outbox(is_fire_priority DESC, id ASC) WHERE status = 'PENDING';

-- 4. Enable AND Force Row Level Security (FORCE prevents table owner bypass)
ALTER TABLE cameras ENABLE ROW LEVEL SECURITY;
ALTER TABLE cameras FORCE ROW LEVEL SECURITY;

ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE events FORCE ROW LEVEL SECURITY;

ALTER TABLE outbox ENABLE ROW LEVEL SECURITY;
ALTER TABLE outbox FORCE ROW LEVEL SECURITY;

-- 5. Define Strict Tenant Isolation Policies
DROP POLICY IF EXISTS camera_tenant_isolation ON cameras;
CREATE POLICY camera_tenant_isolation ON cameras
    FOR ALL
    USING (site_id = current_setting('app.site_id', true))
    WITH CHECK (site_id = current_setting('app.site_id', true));

DROP POLICY IF EXISTS event_tenant_isolation ON events;
CREATE POLICY event_tenant_isolation ON events
    FOR ALL
    USING (site_id = current_setting('app.site_id', true))
    WITH CHECK (site_id = current_setting('app.site_id', true));

DROP POLICY IF EXISTS outbox_tenant_isolation ON outbox;
CREATE POLICY outbox_tenant_isolation ON outbox
    FOR ALL
    USING (site_id = current_setting('app.site_id', true))
    WITH CHECK (site_id = current_setting('app.site_id', true));

-- 6. Permissions for app_runtime (DML only, NO DDL)
GRANT SELECT, INSERT, UPDATE, DELETE ON cameras TO app_runtime;
GRANT SELECT, INSERT, UPDATE, DELETE ON events TO app_runtime;
GRANT SELECT, INSERT, UPDATE, DELETE ON outbox TO app_runtime;
GRANT SELECT ON sites TO app_runtime;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_runtime;

-- 7. Permissions for outbox_dispatcher (least-privilege: outbox queue only)
GRANT SELECT, UPDATE ON outbox TO outbox_dispatcher;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO outbox_dispatcher;
