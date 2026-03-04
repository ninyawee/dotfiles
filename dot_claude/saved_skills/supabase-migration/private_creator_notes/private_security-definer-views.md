# SECURITY DEFINER Views

## The Problem

Views with `SECURITY DEFINER` execute with the permissions of the view **creator** (usually the database owner), not the querying user. This means:

1. RLS policies are evaluated against the creator's role, not the caller
2. Caller's tenant/user context is ignored
3. Potential cross-tenant data leakage

## Why It's Dangerous

In Supabase:
- Views default to `security_invoker = false` (PostgreSQL default)
- A view created by the `postgres` user bypasses all RLS
- Users can query data they shouldn't have access to

## The Fix: Convert to Functions

Functions with `SECURITY DEFINER` can still be safe if they:

1. Explicitly check `auth.jwt()` or `auth.uid()` in the query
2. Filter by tenant/user before returning data
3. Use `REVOKE/GRANT` to control who can call them

## Why Functions Work Better

- Views are passive—they just define a query
- Functions are active—they can enforce checks before execution
- Functions can use `(SELECT auth.jwt())` inline to filter data
- `REVOKE ALL FROM PUBLIC` + explicit `GRANT` limits exposure

## Pattern

```sql
-- Function enforces tenant check explicitly
CREATE FUNCTION fn_get_data_v1() RETURNS TABLE(...)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = extensions, public, pg_temp
AS $$
    SELECT * FROM tb_data
    WHERE tenant_id = ((SELECT auth.jwt()) ->> 'tenant_id')::uuid
$$;

-- Lock down access
REVOKE ALL ON FUNCTION fn_get_data_v1() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_get_data_v1() TO authenticated;
```

The key difference: the function **contains** the auth check, whereas a view relies on external RLS that SECURITY DEFINER bypasses.
