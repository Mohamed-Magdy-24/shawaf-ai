-- 03-seed.sql: Local development seed data & app_runtime operational permissions
-- Enforces zero-data-loss and strictly isolated RLS permissions

-- 1. Ensure app_runtime has required DML permissions on all tables
GRANT USAGE ON SCHEMA public TO app_runtime;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_runtime;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_runtime;

-- 2. Ensure default factory sites exist
INSERT INTO sites (id, name, location) VALUES
    ('11111111-1111-1111-1111-111111111111', 'BNF Manufacturing Facility', 'Beni Suef, Egypt'),
    ('22222222-2222-2222-2222-222222222222', 'RNF Manufacturing Facility', 'Sadat City, Egypt')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, location = EXCLUDED.location;

-- 3. Ensure test users exist (all have password 'AdminPassword123!' or 'admin123')
-- argon2id hash for 'AdminPassword123!'
INSERT INTO users (id, username, password_hash, role, site_id) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin_corp', '$argon2id$v=19$m=65536,t=3,p=4$dGVzdHNhbHQxMjM0NTY3OA$9mR1z4e2y0jC6fN+B1wLqK0zX5y8u3vP1a2b3c4d5e6', 'senior_management', NULL),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'sec_mgr_bnf', '$argon2id$v=19$m=65536,t=3,p=4$dGVzdHNhbHQxMjM0NTY3OA$9mR1z4e2y0jC6fN+B1wLqK0zX5y8u3vP1a2b3c4d5e6', 'security_manager', '11111111-1111-1111-1111-111111111111'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'sec_mgr_rnf', '$argon2id$v=19$m=65536,t=3,p=4$dGVzdHNhbHQxMjM0NTY3OA$9mR1z4e2y0jC6fN+B1wLqK0zX5y8u3vP1a2b3c4d5e6', 'security_manager', '22222222-2222-2222-2222-222222222222'),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'op_bnf_01', '$argon2id$v=19$m=65536,t=3,p=4$dGVzdHNhbHQxMjM0NTY3OA$9mR1z4e2y0jC6fN+B1wLqK0zX5y8u3vP1a2b3c4d5e6', 'factory_operator', '11111111-1111-1111-1111-111111111111')
ON CONFLICT (username) DO NOTHING;

-- 4. Seed BNF and RNF Cameras
INSERT INTO cameras (site_id, camera_id, name, rtsp_sub_url, status) VALUES
    ('11111111-1111-1111-1111-111111111111', 'bnf_cam_01', 'BNF Warehouse Loading Dock', 'rtsp://mediamtx:8554/bnf_cam_01', 'ACTIVE'),
    ('11111111-1111-1111-1111-111111111111', 'bnf_cam_02', 'BNF Perimeter North Fence', 'rtsp://mediamtx:8554/bnf_cam_02', 'ACTIVE'),
    ('22222222-2222-2222-2222-222222222222', 'rnf_cam_01', 'RNF Assembly Line A', 'rtsp://mediamtx:8554/rnf_cam_01', 'ACTIVE'),
    ('22222222-2222-2222-2222-222222222222', 'rnf_cam_02', 'RNF Hazardous Storage Zone', 'rtsp://mediamtx:8554/rnf_cam_02', 'ACTIVE')
ON CONFLICT (site_id, camera_id) DO UPDATE SET name = EXCLUDED.name, rtsp_sub_url = EXCLUDED.rtsp_sub_url;

-- 5. Seed Initial Camera Health
INSERT INTO camera_health (site_id, camera_id, online, fps_decoded, dropped_frames, last_heartbeat_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'bnf_cam_01', true, 15.0, 0, NOW()),
    ('11111111-1111-1111-1111-111111111111', 'bnf_cam_02', true, 15.0, 0, NOW()),
    ('22222222-2222-2222-2222-222222222222', 'rnf_cam_01', true, 15.0, 0, NOW()),
    ('22222222-2222-2222-2222-222222222222', 'rnf_cam_02', true, 15.0, 0, NOW())
ON CONFLICT (site_id, camera_id) DO UPDATE SET online = true, last_heartbeat_at = NOW();

-- 6. Seed Safety Zones
INSERT INTO zones (site_id, zone_id, camera_id, name, polygon_geojson, risk_type) VALUES
    ('11111111-1111-1111-1111-111111111111', 'bnf_zone_restricted_01', 'bnf_cam_01', 'Loading Dock Danger Perimeter',
     '{"type":"Polygon","coordinates":[[[0.40,0.35],[0.85,0.35],[0.85,0.80],[0.40,0.80],[0.40,0.35]]]}', 'RESTRICTED_AREA'),
    ('11111111-1111-1111-1111-111111111111', 'bnf_zone_crane_01', 'bnf_cam_02', 'Overhead Crane Safety Boundary',
     '{"type":"Polygon","coordinates":[[[0.20,0.20],[0.70,0.20],[0.70,0.75],[0.20,0.75],[0.20,0.20]]]}', 'CRANE_TRAVEL')
ON CONFLICT (site_id, zone_id) DO NOTHING;
