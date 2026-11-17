-- 00001_initial_schema.sql: Initial PostgreSQL 16 schema with RLS and Monthly Partitioning
-- Strict Site Isolation & Clean Architecture (ADR-013)

-- 1. Sites (Global reference table, no RLS)
CREATE TABLE IF NOT EXISTS sites (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    code VARCHAR(20) NOT NULL DEFAULT 'BNF',
    timezone VARCHAR(50) NOT NULL DEFAULT 'Africa/Cairo',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Users (Global authentication table, role-based)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL, -- security_manager, senior_management, factory_operator
    site_id UUID REFERENCES sites(id), -- NULL if multi-site executive
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Cameras (Tenant table with Composite PK for site isolation)
CREATE TABLE IF NOT EXISTS cameras (
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    camera_id VARCHAR(100) NOT NULL,
    nvr_id VARCHAR(100),
    name VARCHAR(150) NOT NULL,
    rtsp_sub_url VARCHAR(255) NOT NULL,
    onvif_host VARCHAR(150),
    fps_target INT NOT NULL DEFAULT 15,
    zones TEXT[],
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, camera_id)
);
ALTER TABLE cameras ENABLE ROW LEVEL SECURITY;
ALTER TABLE cameras FORCE ROW LEVEL SECURITY;

CREATE POLICY cameras_site_isolation_policy ON cameras
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::UUID);

-- 4. Zones (Tenant table with Composite FK)
CREATE TABLE IF NOT EXISTS zones (
    site_id UUID NOT NULL,
    zone_id VARCHAR(100) NOT NULL,
    camera_id VARCHAR(100) NOT NULL,
    name VARCHAR(150) NOT NULL,
    polygon_geojson JSONB NOT NULL,
    risk_type VARCHAR(50) NOT NULL, -- RESTRICTED_AREA, PPE_ZONE, FALL_RISK
    schedule_cron VARCHAR(100) NOT NULL DEFAULT '* * * * *',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, zone_id),
    CONSTRAINT fk_zones_camera FOREIGN KEY (site_id, camera_id) REFERENCES cameras(site_id, camera_id) ON DELETE CASCADE
);
ALTER TABLE zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE zones FORCE ROW LEVEL SECURITY;

CREATE POLICY zones_site_isolation_policy ON zones
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::UUID);

-- 5. Events (Partitioned table by Month, Composite PK)
CREATE TABLE IF NOT EXISTS events (
    event_id VARCHAR(64) NOT NULL,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    camera_id VARCHAR(100) NOT NULL,
    zone_id VARCHAR(100),
    event_type VARCHAR(50) NOT NULL,
    severity VARCHAR(20) NOT NULL, -- INFO, WARNING, CRITICAL, CRITICAL_FIRE
    occurred_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    model_id VARCHAR(100) NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    rule_id VARCHAR(100) NOT NULL,
    rule_version VARCHAR(50) NOT NULL,
    confidence REAL NOT NULL,
    snapshot_rel_path VARCHAR(255) NOT NULL,
    subject_status VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN',
    state VARCHAR(50) NOT NULL DEFAULT 'NEW', -- NEW, ACKNOWLEDGED, RESOLVED, DISMISSED
    dismissed_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (event_id, site_id, occurred_at)
) PARTITION BY RANGE (occurred_at);
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE events FORCE ROW LEVEL SECURITY;

CREATE POLICY events_site_isolation_policy ON events
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::UUID);

-- Partitions for 2026 and Default
CREATE TABLE IF NOT EXISTS events_2026_11 PARTITION OF events
    FOR VALUES FROM ('2026-11-01 00:00:00+00') TO ('2026-12-01 00:00:00+00');

CREATE TABLE IF NOT EXISTS events_2026_12 PARTITION OF events
    FOR VALUES FROM ('2026-12-01 00:00:00+00') TO ('2027-01-01 00:00:00+00');

CREATE TABLE IF NOT EXISTS events_default PARTITION OF events DEFAULT;

-- 6. Outbox Table for Guaranteed At-Least-Once Dispatch (ADR-013)
CREATE TABLE IF NOT EXISTS outbox (
    id BIGSERIAL PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    priority VARCHAR(20) NOT NULL, -- NORMAL, CRITICAL, CRITICAL_FIRE
    destination_channel VARCHAR(50) NOT NULL, -- WEBSOCKET, FCM, NTFY
    payload_json JSONB NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, PROCESSING, SENT, FAILED
    attempts INT NOT NULL DEFAULT 0,
    next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    locked_until TIMESTAMPTZ,
    idempotency_key VARCHAR(128) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_outbox_poll ON outbox (status, next_attempt_at) WHERE status IN ('PENDING', 'PROCESSING');
CREATE INDEX IF NOT EXISTS idx_outbox_fire ON outbox (priority, status) WHERE priority = 'CRITICAL_FIRE' AND status = 'PENDING';

-- 7. Outbox Dead Letter Queue
CREATE TABLE IF NOT EXISTS outbox_dead_letter (
    id BIGSERIAL PRIMARY KEY,
    outbox_id BIGINT NOT NULL,
    event_id VARCHAR(64) NOT NULL,
    site_id UUID NOT NULL,
    failure_reason TEXT NOT NULL,
    payload_json JSONB NOT NULL,
    failed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Camera Health Watchdog Table (NFR-OBS-002)
CREATE TABLE IF NOT EXISTS camera_health (
    site_id UUID NOT NULL,
    camera_id VARCHAR(100) NOT NULL,
    online BOOLEAN NOT NULL DEFAULT TRUE,
    fps_decoded REAL NOT NULL DEFAULT 0.0,
    dropped_frames BIGINT NOT NULL DEFAULT 0,
    last_heartbeat_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, camera_id),
    CONSTRAINT fk_health_camera FOREIGN KEY (site_id, camera_id) REFERENCES cameras(site_id, camera_id) ON DELETE CASCADE
);
ALTER TABLE camera_health ENABLE ROW LEVEL SECURITY;
ALTER TABLE camera_health FORCE ROW LEVEL SECURITY;

CREATE POLICY camera_health_site_isolation_policy ON camera_health
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::UUID);

-- 9. Incident Audit and Action Log
CREATE TABLE IF NOT EXISTS incident_actions (
    id BIGSERIAL PRIMARY KEY,
    event_id VARCHAR(64) NOT NULL,
    site_id UUID NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    action_type VARCHAR(50) NOT NULL, -- ACKNOWLEDGE, RESOLVE, DISMISS
    note TEXT,
    action_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE incident_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE incident_actions FORCE ROW LEVEL SECURITY;

CREATE POLICY incident_actions_site_isolation_policy ON incident_actions
    FOR ALL
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::UUID);

-- 10. Single-Use WebSocket Tickets (ADR-017)
CREATE TABLE IF NOT EXISTS ws_tickets (
    ticket_id VARCHAR(64) PRIMARY KEY,
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ
);

-- 11. Platform Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    site_id UUID REFERENCES sites(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource VARCHAR(100) NOT NULL,
    details_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed Baseline Factory Sites
INSERT INTO sites (id, name, location, code, timezone, is_active) VALUES
    ('11111111-1111-1111-1111-111111111111', 'BNF', 'BNF', 'BNF', 'Africa/Cairo', true)
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, location = EXCLUDED.location, code = EXCLUDED.code;

INSERT INTO sites (id, name, location, code, timezone, is_active) VALUES
    ('22222222-2222-2222-2222-222222222222', 'RNF', 'RNF', 'RNF', 'Africa/Cairo', true)
    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, location = EXCLUDED.location, code = EXCLUDED.code;

-- Seed Default Security and Admin Users (password: 'AdminPassword123!')
-- Hash generated via argon2id
INSERT INTO users (id, username, password_hash, role, site_id) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin_corp', '$argon2id$v=19$m=65536,t=3,p=4$2dlbQGJ5+bwwXKiJXY+x+Q$vD95L7DhgjK8bcf/FDYaYV9K9uKObrczjJ3K70lyFr4', 'senior_management', NULL),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'sec_mgr_bnf', '$argon2id$v=19$m=65536,t=3,p=4$2dlbQGJ5+bwwXKiJXY+x+Q$vD95L7DhgjK8bcf/FDYaYV9K9uKObrczjJ3K70lyFr4', 'security_manager', '11111111-1111-1111-1111-111111111111'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'sec_mgr_rnf', '$argon2id$v=19$m=65536,t=3,p=4$2dlbQGJ5+bwwXKiJXY+x+Q$vD95L7DhgjK8bcf/FDYaYV9K9uKObrczjJ3K70lyFr4', 'security_manager', '22222222-2222-2222-2222-222222222222')
    ON CONFLICT (username) DO NOTHING;

-- Seed Cameras for BNF and RNF
INSERT INTO cameras (site_id, camera_id, name, rtsp_sub_url) VALUES
    ('11111111-1111-1111-1111-111111111111', 'bnf_cam_01', 'BNF Warehouse Loading Dock', 'rtsp://mediamtx:8554/bnf_cam_01'),
    ('11111111-1111-1111-1111-111111111111', 'bnf_cam_02', 'BNF Perimeter North Fence', 'rtsp://mediamtx:8554/bnf_cam_02'),
    ('22222222-2222-2222-2222-222222222222', 'rnf_cam_01', 'RNF Assembly Line A', 'rtsp://mediamtx:8554/rnf_cam_01'),
    ('22222222-2222-2222-2222-222222222222', 'rnf_cam_02', 'RNF Hazardous Storage Zone', 'rtsp://mediamtx:8554/rnf_cam_02')
    ON CONFLICT (site_id, camera_id) DO NOTHING;

-- Seed Restricted Polygon Zones
INSERT INTO zones (site_id, zone_id, camera_id, name, polygon_geojson, risk_type) VALUES
    ('11111111-1111-1111-1111-111111111111', 'bnf_zone_restricted_01', 'bnf_cam_01', 'Loading Dock Danger Perimeter',
     '{"type":"Polygon","coordinates":[[[100,100],[500,100],[500,300],[100,300],[100,100]]]}', 'RESTRICTED_AREA')
    ON CONFLICT (site_id, zone_id) DO NOTHING;
