# Private Schema

Hide internal objects from PostgREST API.

| Schema | API Exposure | Use For |
|--------|--------------|---------|
| `public` | Exposed | Client-facing tables, RPC |
| `private` | Hidden | Internal tables, helpers, audit |
| `extensions` | Hidden | PostgreSQL extensions |

```sql
CREATE SCHEMA IF NOT EXISTS private;

-- Internal audit table (NOT accessible via API)
CREATE TABLE private.tb_audit_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    action text NOT NULL,
    table_name text NOT NULL,
    record_id uuid,
    old_data jsonb,
    new_data jsonb,
    performed_by uuid REFERENCES auth.users(id),
    performed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Internal helper function
CREATE OR REPLACE FUNCTION private.fn_helper_v1()
RETURNS void AS $$ BEGIN END; $$
LANGUAGE plpgsql;
```

**When to use `private` schema:**
- Audit/logging tables
- Internal helper functions
- Sensitive data not for direct API access
- Background job tables
