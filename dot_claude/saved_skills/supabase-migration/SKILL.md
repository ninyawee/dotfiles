---
name: supabase-migration
description: "Database migration toolkit for Supabase projects. Use when: (1) Creating new migration files, (2) Writing schema changes (CREATE TABLE, ALTER, etc.), (3) Adding indexes, triggers, or RLS policies, (4) Fixing RLS performance issues (auth function wrapping, policy consolidation), (5) Validating migration conventions, (6) Running migrations locally, (7) Naming database objects"
license: Proprietary. LICENSE.txt has complete terms
---

# Supabase Database Migrations

Toolkit for creating and managing Supabase database migrations.

**Helper Scripts Available** (uv scripts - no install needed):
- `scripts/new_migration.py` - Create migration file with proper naming
- `scripts/lint_migration.py` - Validate migration against conventions

```bash
uv run scripts/new_migration.py --help
uv run scripts/lint_migration.py --help
```

## Naming Conventions

### Object Prefixes (REQUIRED)

| Object Type | Prefix | Example |
|-------------|--------|---------|
| Tables | `tb_` | `tb_users` |
| Views | `v_` | `v_active_users` |
| Materialized Views | `mv_` | `mv_daily_stats` |
| Functions | `fn_` | `fn_get_balance_v1` |
| Triggers | `tgr_` | `tgr_update_ts` |
| Indexes | `idx_` | `idx_email` |
| Foreign Keys | `fk_` | `fk_order_user` |
| Primary Keys | `pk_` | `pk_users` |
| Unique Constraints | `uq_` | `uq_email` |
| Enum Types | `en_` | `en_status` |
| RLS Policies | `pc_` | `pc_users_select` |

**Functions MUST be versioned:** `fn_calculate_total_v1`, `fn_calculate_total_v2`

### Field Suffixes

| Suffix | Type | Example |
|--------|------|---------|
| `_dt` | date | `birth_dt` |
| `_ts` | timestamp | `login_ts` |
| `_num` | number | `items_num` |
| `_amt` | decimal | `total_amt` |
| `_pct` | decimal | `discount_pct` |
| `_uid` | uuid | `user_uid` |
| `_cd` | text | `status_cd` |
| `_bool` | boolean | `active_bool` |
| `_pn` | text | `contact_pn` |
| `_em` | text | `contact_em` |
| `_txt` | text | `description_txt` |
| `_kg` | decimal | `weight_kg` |
| `_path` | text | `avatar_path` |

**No suffix:** `id`, `name`, `email`, `created_at`, `updated_at`, `deleted_at`

### Rules

- MUST use `lowercase_snake_case`
- Tables MUST use plural forms (`tb_users` not `tb_user`)

## Decision Tree

```
Task → What type of change?
    ├─ New table → uv run scripts/new_migration.py "add_users_table"
    ├─ Alter table → uv run scripts/new_migration.py "add_avatar_to_users" --type alter
    ├─ New function → uv run scripts/new_migration.py "add_calc_fn" --type function
    └─ Before commit → uv run scripts/lint_migration.py migrations/*.sql
```

## File Naming

```
supabase/migrations/YYYYMMDDHHMMSS_description.sql
```

## Migration Template

```sql
-- Migration: [Description]
BEGIN;

-- 1. Types/Enums
DO $$ BEGIN CREATE TYPE en_status AS ENUM ('active', 'inactive');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 2. Tables
CREATE TABLE IF NOT EXISTS tb_examples (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    status_cd en_status NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Comments
COMMENT ON TABLE tb_examples IS 'Module: Description';

-- 4. Indexes
CREATE INDEX IF NOT EXISTS idx_examples_status ON tb_examples(status_cd);

-- 5. Triggers
DROP TRIGGER IF EXISTS tgr_update_examples_timestamp ON tb_examples;
CREATE TRIGGER tgr_update_examples_timestamp
    BEFORE UPDATE ON tb_examples FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 6. RLS (use SELECT wrapper for auth functions - see below)
ALTER TABLE tb_examples ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pc_examples_select ON tb_examples;
CREATE POLICY pc_examples_select ON tb_examples FOR SELECT
    USING (user_uid = (SELECT auth.uid()));

COMMIT;
```

## Supabase Security

### Views - MUST use security_invoker

```sql
CREATE VIEW v_active_users WITH (security_invoker) AS
SELECT * FROM tb_users WHERE deleted_at IS NULL;
```

**SECURITY DEFINER views must be converted to functions:**

Views with SECURITY DEFINER bypass RLS of the querying user. Convert to a function with explicit tenant/auth checks.

```sql
-- BAD: View with SECURITY DEFINER bypasses caller's RLS
CREATE VIEW v_line_responders WITH (security_definer) AS
SELECT tenant_id, ... FROM tb_line_events GROUP BY ...;

-- GOOD: Function with explicit auth check
CREATE OR REPLACE FUNCTION fn_get_line_responders_v1()
RETURNS TABLE (
    tenant_id uuid,
    responder_user_id text,
    message_count bigint
) LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = extensions, public, pg_temp
AS $$
    SELECT tenant_id, event_payload->>'user_id', COUNT(*)
    FROM public.tb_line_events
    WHERE tenant_id = ((SELECT auth.jwt()) ->> 'tenant_id')::uuid
    GROUP BY tenant_id, event_payload->>'user_id';
$$;

REVOKE ALL ON FUNCTION fn_get_line_responders_v1() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_get_line_responders_v1() TO authenticated;
```

### Functions - MUST set search_path

Mutable search_path allows object hijacking. Always set explicitly.

```sql
-- New function
CREATE OR REPLACE FUNCTION fn_example_v1()
RETURNS void AS $$ BEGIN END; $$
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = extensions, public, pg_temp;

-- Fix existing function
ALTER FUNCTION fn_find_nearby_facilities(/* arg types */)
SET search_path = extensions, public, pg_temp;
```

| Scenario | search_path |
|----------|-------------|
| Uses extensions (PostGIS, etc.) | `extensions, public, pg_temp` |
| No extensions | `public, pg_temp` |
| SECURITY DEFINER + auth | Add `REVOKE/GRANT` (see Views section) |

### Extensions - MUST use extensions schema

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA extensions;
```

### RLS Performance - MUST wrap auth functions in SELECT

| Bad | Good |
|-----|------|
| `auth.uid()` | `(SELECT auth.uid())` |
| `auth.jwt()` | `(SELECT auth.jwt())` |
| `auth.role()` | `(SELECT auth.role())` |
| `current_setting(...)` | `(SELECT current_setting(...))` |

```sql
-- Wrap auth functions to avoid per-row re-evaluation
USING (user_uid = (SELECT auth.uid()))
USING (org_uid = ((SELECT auth.jwt()) ->> 'org_id')::uuid)
```

### RLS Performance - Consolidate multiple permissive policies

Same role + same action = consolidate with OR (don't create multiple policies).

| Scenario | Approach |
|----------|----------|
| Same role, same action | Consolidate with OR |
| Different roles | Keep separate policies |
| Different actions | Keep separate policies |

```sql
-- Single policy with OR instead of multiple permissive policies
CREATE POLICY pc_records_select ON tb_records FOR SELECT
TO authenticated
USING (
    ((SELECT auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin'
    OR user_uid = (SELECT auth.uid())
);
```

**Multi-tenant pattern:**

```sql
CREATE POLICY pc_registrations_select ON tb_registrations FOR SELECT
TO authenticated
USING (
    tenant_id = (((SELECT auth.jwt()) -> 'app_metadata' ->> 'tenant_id')::smallint)
    AND (
        ((SELECT auth.jwt()) -> 'app_metadata' ->> 'role') = ANY (ARRAY['staff', 'admin'])
        OR user_uid = (SELECT auth.uid())
    )
);
```

## Running Migrations

```bash
supabase db reset    # Reset and apply all
supabase db push     # Deploy to remote
```

## References

| Topic | When to Read |
|-------|--------------|
| [auth-function-wrapping.md](creator_notes/auth-function-wrapping.md) | Why `(SELECT auth.*)` improves performance |
| [policy-consolidation.md](creator_notes/policy-consolidation.md) | Why multiple permissive policies hurt performance |
| [security-definer-views.md](creator_notes/security-definer-views.md) | Why SECURITY DEFINER views are dangerous |
| [function-search-path.md](creator_notes/function-search-path.md) | Why mutable search_path is dangerous |
| [multi-tenant.md](references/multi-tenant.md) | Setting up SaaS/multi-env isolation |
| [private-schema.md](references/private-schema.md) | Hiding tables from API |
| [jsonb.md](references/jsonb.md) | Using flexible JSON columns |
| [advanced-types.md](references/advanced-types.md) | ltree, tstzrange, int8range |
