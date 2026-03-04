# Function Search Path Security

## The Problem

When a function doesn't set `search_path`, it inherits the caller's session setting. This means object name resolution (tables, functions, operators) can change based on who calls the function.

## Why It's Dangerous

### Object Hijacking Attack

1. Attacker creates a schema that appears early in `search_path`
2. Attacker creates a malicious object with the same name as one your function uses
3. Your function (especially SECURITY DEFINER) executes the attacker's object instead

Example:
```sql
-- Your function references "users" table
SELECT * FROM users WHERE id = $1;

-- Attacker creates: evil_schema.users (a function returning fake data)
-- If evil_schema appears before public in search_path, attack succeeds
```

### Inconsistent Behavior

- Different roles may have different `search_path` settings
- Function behavior changes unpredictably across environments
- Hard to debug because it "works for me" but fails for others

## The Fix

### Set search_path Explicitly

```sql
CREATE OR REPLACE FUNCTION fn_example_v1()
RETURNS void AS $$ ... $$
LANGUAGE plpgsql
SET search_path = extensions, public, pg_temp;
```

### Fix Existing Functions

```sql
ALTER FUNCTION fn_example_v1(/* arg types here */)
SET search_path = extensions, public, pg_temp;
```

## Why pg_temp?

Including `pg_temp` allows the function to use temporary tables if needed. It's safe because:
- Temp tables are session-local
- They can't be created by other users
- They naturally disappear after the session

## Schema Order Matters

```sql
-- Order: extensions first, then public
SET search_path = extensions, public, pg_temp;
```

- `extensions`: Where extension objects live (PostGIS, pg_trgm, etc.)
- `public`: Where your application tables live
- `pg_temp`: Temporary objects (always last, always safe)

## Additional Hardening

For SECURITY DEFINER functions:

1. **Set search_path** - Prevents object hijacking
2. **Fully qualify objects** - `public.tb_users` instead of `tb_users`
3. **REVOKE from PUBLIC** - Limit who can call the function
4. **GRANT to specific roles** - Only allow intended users

```sql
CREATE OR REPLACE FUNCTION fn_sensitive_v1()
RETURNS void AS $$
    SELECT * FROM public.tb_users;  -- Fully qualified
$$ LANGUAGE sql SECURITY DEFINER
SET search_path = public, pg_temp;

REVOKE ALL ON FUNCTION fn_sensitive_v1() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION fn_sensitive_v1() TO authenticated;
```

## Validation

After fixing, test from multiple roles:

```sql
-- As anon
SET ROLE anon;
SELECT fn_example_v1();

-- As authenticated
SET ROLE authenticated;
SELECT fn_example_v1();

-- With weird search_path (should still work correctly)
SET search_path = 'evil_schema, public';
SELECT fn_example_v1();  -- Should ignore evil_schema
```
