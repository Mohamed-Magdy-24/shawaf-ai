#!/bin/sh
set -e

# Initialize distinct roles for migrations vs application runtime
# Enforces Step 2.4 & Step 4.1: NOBYPASSRLS for app_runtime
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- 1. Create migration role (owns DDL schemas and tables)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_migrator') THEN
            CREATE ROLE app_migrator WITH LOGIN PASSWORD 'migrator_secret_dev_pass';
        END IF;
    END
    \$\$;

    -- 2. Create runtime application role (strictly DML only, NOBYPASSRLS enforced)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_runtime') THEN
            CREATE ROLE app_runtime WITH LOGIN PASSWORD 'runtime_secret_dev_pass'
                NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
        END IF;
    END
    \$\$;

    -- 3. Create dedicated outbox dispatcher role (least privilege: outbox queue dispatch only)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'outbox_dispatcher') THEN
            CREATE ROLE outbox_dispatcher WITH LOGIN PASSWORD 'dispatcher_secret_dev_pass'
                NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS;
        END IF;
    END
    \$\$;

    -- 4. Grant schema usage and privileges
    GRANT ALL ON SCHEMA public TO app_migrator;
    GRANT USAGE ON SCHEMA public TO app_runtime;
    GRANT USAGE ON SCHEMA public TO outbox_dispatcher;
    ALTER DEFAULT PRIVILEGES FOR ROLE app_migrator IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_runtime;
    ALTER DEFAULT PRIVILEGES FOR ROLE app_migrator IN SCHEMA public
        GRANT USAGE, SELECT ON SEQUENCES TO app_runtime;
    ALTER DEFAULT PRIVILEGES FOR ROLE app_migrator IN SCHEMA public
        GRANT SELECT, UPDATE ON TABLES TO outbox_dispatcher;
    ALTER DEFAULT PRIVILEGES FOR ROLE app_migrator IN SCHEMA public
        GRANT USAGE, SELECT ON SEQUENCES TO outbox_dispatcher;
EOSQL
