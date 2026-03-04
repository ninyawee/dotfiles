# Consolidating Multiple Permissive Policies

## The Problem

When you have multiple permissive policies for the same role and action (e.g., two SELECT policies for `authenticated`), Postgres evaluates **all** of them for every query. Access is granted if **any** policy returns true.

## Why It's Suboptimal

Each policy adds:
1. Additional predicate evaluation per row
2. More complex query plans
3. Harder-to-debug access logic

Even if the first policy grants access, subsequent policies are still evaluated (no short-circuit).

## When Multiple Policies Make Sense

- **Different roles**: `anon` vs `authenticated` need separate policies
- **Different actions**: SELECT vs INSERT vs UPDATE need separate policies
- **Restrictive policies**: RESTRICTIVE policies work differently (all must pass)

## When to Consolidate

Same role + same action = consolidate with OR logic.

Instead of:
```
Policy A: user can read own rows
Policy B: admin can read all rows
```

Use:
```
Policy: user can read own rows OR user is admin
```

## Multi-tenant Consideration

In multi-tenant apps, the pattern is:
1. **Tenant isolation** (AND) - must be in same tenant
2. **Access rules** (OR) - owner OR staff OR admin

```sql
USING (
    tenant_check
    AND (owner_check OR role_check)
)
```

This ensures tenant boundary is never crossed, while allowing flexible access within tenant.
