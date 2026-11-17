-- Migration: 00002_employees_and_nvrs.sql
-- Description: Adds NVR onboarding, Employee records, and Face Embeddings with strict multi-site Row Level Security (RLS)

-- 1. NVRs Table
CREATE TABLE IF NOT EXISTS nvrs (
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    nvr_id VARCHAR(100) NOT NULL,
    name VARCHAR(150) NOT NULL,
    vendor VARCHAR(50) NOT NULL DEFAULT 'GENERIC',
    host_ip VARCHAR(100) NOT NULL,
    port INT NOT NULL DEFAULT 554,
    username VARCHAR(100) NOT NULL,
    encrypted_password TEXT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, nvr_id)
);

ALTER TABLE nvrs ENABLE ROW LEVEL SECURITY;
ALTER TABLE nvrs FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS nvrs_site_isolation_policy ON nvrs;
CREATE POLICY nvrs_site_isolation_policy ON nvrs
    FOR ALL
    TO app_runtime
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid);

-- 2. Employees Table
CREATE TABLE IF NOT EXISTS employees (
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    employee_id VARCHAR(100) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    department VARCHAR(100) NOT NULL DEFAULT 'OPERATIONS',
    photo_rel_path VARCHAR(255),
    source_type VARCHAR(50) NOT NULL DEFAULT 'MANUAL_UPLOAD',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, employee_id)
);

ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS employees_site_isolation_policy ON employees;
CREATE POLICY employees_site_isolation_policy ON employees
    FOR ALL
    TO app_runtime
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid);

-- 3. Employee Embeddings Table (512-d L2-normalized float32 vectors)
CREATE TABLE IF NOT EXISTS employee_embeddings (
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    employee_id VARCHAR(100) NOT NULL,
    model_version VARCHAR(50) NOT NULL DEFAULT 'mobilefacenet-v1',
    embedding_fp32_bytes BYTEA NOT NULL,
    photo_sha256 VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, employee_id, model_version),
    CONSTRAINT fk_embeddings_employee FOREIGN KEY (site_id, employee_id) REFERENCES employees(site_id, employee_id) ON DELETE CASCADE
);

ALTER TABLE employee_embeddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_embeddings FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS employee_embeddings_site_isolation_policy ON employee_embeddings;
CREATE POLICY employee_embeddings_site_isolation_policy ON employee_embeddings
    FOR ALL
    TO app_runtime
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid);

-- 4. Employee Presence Table ("Who & Where" real-time presence tracking)
CREATE TABLE IF NOT EXISTS employee_presence (
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    employee_id VARCHAR(100) NOT NULL,
    camera_id VARCHAR(100) NOT NULL,
    zone_id VARCHAR(100),
    confidence REAL NOT NULL DEFAULT 1.0,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (site_id, employee_id),
    CONSTRAINT fk_presence_employee FOREIGN KEY (site_id, employee_id) REFERENCES employees(site_id, employee_id) ON DELETE CASCADE
);

ALTER TABLE employee_presence ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_presence FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS employee_presence_site_isolation_policy ON employee_presence;
CREATE POLICY employee_presence_site_isolation_policy ON employee_presence
    FOR ALL
    TO app_runtime
    USING (site_id = NULLIF(current_setting('app.site_id', true), '')::uuid);

-- 5. Events Table Extension
ALTER TABLE events ADD COLUMN IF NOT EXISTS employee_id VARCHAR(100);
ALTER TABLE events ADD COLUMN IF NOT EXISTS employee_name VARCHAR(150);

-- 6. Permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON nvrs, employees, employee_embeddings, employee_presence TO app_runtime;
GRANT ALL ON nvrs, employees, employee_embeddings, employee_presence TO app_migrator;
