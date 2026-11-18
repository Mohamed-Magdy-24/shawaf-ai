-- Industrial AI Surveillance Platform
-- Migration 001: Initial Schema with PostgreSQL 16 Row-Level Security (RLS)
-- Governing Standards: ADR-011, ADR-013, postgres-rls skill, Step 4.1 / 4.4

-- 1. Sites Table (Tenant roots)
CREATE TABLE IF NOT EXISTS sites (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Cameras Table (Composite Key: site_id, id)
CREATE TABLE IF NOT EXISTS cameras (
    id VARCHAR(64) NOT NULL,
    site_id VARCHAR(64) NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    rtsp_main_url TEXT NOT NULL,
    rtsp_sub_url TEXT NOT NULL,
    zone_id VARCHAR(64),
    status VARCHAR(32) NOT NULL DEFAULT 'ONLINE',
    fps_decoded DOUBLE PRECISION NOT NULL DEFAULT 0,
    dropped_frames BIGINT NOT NULL DEFAULT 0,
    last_heartbeat TIMESTAMPTZ,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, id)
);

CREATE INDEX IF NOT EXISTS idx_cameras_site_id ON cameras(site_id);

-- 3. Detection Zones Table (Composite Foreign Key: site_id, camera_id)
CREATE TABLE IF NOT EXISTS detection_zones (
    id VARCHAR(64) NOT NULL,
    site_id VARCHAR(64) NOT NULL,
    camera_id VARCHAR(64) NOT NULL,
    name VARCHAR(255) NOT NULL,
    polygon_json JSONB NOT NULL DEFAULT '[]',
    rule_type VARCHAR(64) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, id),
    CONSTRAINT fk_detection_zones_camera FOREIGN KEY (site_id, camera_id)
        REFERENCES cameras(site_id, id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_detection_zones_site_id ON detection_zones(site_id);

-- 4. Safety Incidents / Events Table
-- Minimal workflow status per FR-ALT-008: NEW -> ACKNOWLEDGED -> RESOLVED | DISMISSED
CREATE TABLE IF NOT EXISTS events (
    id VARCHAR(64) NOT NULL,
    site_id VARCHAR(64) NOT NULL,
    camera_id VARCHAR(64) NOT NULL,
    zone_id VARCHAR(64),
    event_type VARCHAR(128) NOT NULL,
    severity VARCHAR(32) NOT NULL, -- INFO, WARNING, CRITICAL, CRITICAL_FIRE
    status VARCHAR(32) NOT NULL DEFAULT 'NEW', -- NEW, ACKNOWLEDGED, RESOLVED, DISMISSED
    occurred_at_utc TIMESTAMPTZ NOT NULL,
    model_id VARCHAR(64),
    model_version VARCHAR(64),
    confidence REAL NOT NULL DEFAULT 0,
    bboxes JSONB NOT NULL DEFAULT '[]',
    snapshot_rel_path TEXT NOT NULL,
    acknowledged_by VARCHAR(128),
    acknowledged_at_utc TIMESTAMPTZ,
    resolved_by VARCHAR(128),
    resolved_at_utc TIMESTAMPTZ,
    dismissal_reason TEXT,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, id),
    CONSTRAINT fk_events_camera FOREIGN KEY (site_id, camera_id)
        REFERENCES cameras(site_id, id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_events_site_id ON events(site_id);
CREATE INDEX IF NOT EXISTS idx_events_occurred_at ON events(occurred_at_utc DESC);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);

-- 5. Transactional Outbox Table
CREATE TABLE IF NOT EXISTS outbox (
    id BIGSERIAL PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    site_id VARCHAR(64) NOT NULL,
    payload JSONB NOT NULL,
    is_fire_priority BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING', -- PENDING, PROCESSING, PUBLISHED, FAILED
    locked_until TIMESTAMPTZ,
    retry_count INT NOT NULL DEFAULT 0,
    created_at_utc TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at_utc TIMESTAMPTZ,
    CONSTRAINT fk_outbox_event FOREIGN KEY (site_id, event_id)
        REFERENCES events(site_id, id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_outbox_site_id ON outbox(site_id);
CREATE INDEX IF NOT EXISTS idx_outbox_dispatch ON outbox(status, is_fire_priority DESC, id ASC);
CREATE INDEX IF NOT EXISTS idx_outbox_reaper ON outbox(status, locked_until);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) CONFIGURATION
-- Enforces: ENABLE + FORCE ROW LEVEL SECURITY, USING + WITH CHECK
-- Non-superuser app_runtime role respects policies; owners forced to respect
-- ============================================================================

-- Cameras RLS
ALTER TABLE cameras ENABLE ROW LEVEL SECURITY;
ALTER TABLE cameras FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS site_isolation_policy ON cameras;
CREATE POLICY site_isolation_policy ON cameras
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL')
    WITH CHECK (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL');

-- Detection Zones RLS
ALTER TABLE detection_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE detection_zones FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS site_isolation_policy ON detection_zones;
CREATE POLICY site_isolation_policy ON detection_zones
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL')
    WITH CHECK (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL');

-- Events RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE events FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS site_isolation_policy ON events;
CREATE POLICY site_isolation_policy ON events
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL')
    WITH CHECK (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL');

-- Outbox RLS
ALTER TABLE outbox ENABLE ROW LEVEL SECURITY;
ALTER TABLE outbox FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS site_isolation_policy ON outbox;
CREATE POLICY site_isolation_policy ON outbox
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL')
    WITH CHECK (site_id = NULLIF(current_setting('app.site_id', true), '') OR current_setting('app.site_id', true) = 'ALL');

-- ============================================================================
-- OUTBOX FIRE NOTIFY TRIGGER (LISTEN outbox_fire)
-- Fast-path notification for critical fire alerts bypassing polling delay
-- ============================================================================
CREATE OR REPLACE FUNCTION notify_outbox_fire() RETURNS trigger AS $$
BEGIN
    IF NEW.is_fire_priority = TRUE AND NEW.status = 'PENDING' THEN
        PERFORM pg_notify('outbox_fire', json_build_object(
            'outbox_id', NEW.id,
            'event_id', NEW.event_id,
            'site_id', NEW.site_id
        )::text);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_outbox_fire ON outbox;
CREATE TRIGGER trg_outbox_fire
    AFTER INSERT OR UPDATE ON outbox
    FOR EACH ROW
    EXECUTE FUNCTION notify_outbox_fire();

-- ============================================================================
-- SEED DATA FOR LOCAL DEVELOPMENT (BNF and RNF sites & synthetic cameras)
-- ============================================================================
INSERT INTO sites (id, name) VALUES
    ('site_bnf', 'Beni Suef Facility (BNF)'),
    ('site_rnf', 'Sadat City Facility (RNF)'),
    ('BNF', 'Beni Suef Main Factory'),
    ('RNF', 'Sadat City Main Factory')
ON CONFLICT (id) DO NOTHING;

-- Seed cameras temporarily bypassing RLS via superuser/migrator session setting
SELECT set_config('app.site_id', 'ALL', false);
INSERT INTO cameras (id, site_id, name, rtsp_main_url, rtsp_sub_url, zone_id, status)
VALUES
    ('camera01', 'site_bnf', 'BNF Gate & Loading Dock', 'rtsp://mediamtx:8554/bnf/camera01', 'rtsp://mediamtx:8554/bnf/camera01', 'zone_gate_01', 'ONLINE'),
    ('camera01', 'site_rnf', 'RNF Assembly Line North', 'rtsp://mediamtx:8554/rnf/camera01', 'rtsp://mediamtx:8554/rnf/camera01', 'zone_assembly_01', 'ONLINE')
ON CONFLICT (site_id, id) DO NOTHING;
RESET app.site_id;

-- Permissions grant to app_runtime
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_runtime') THEN
        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_runtime;
        GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_runtime;
    END IF;
END
$$;
