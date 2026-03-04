---
name: supabase-db
description: "PostgreSQL conventions overview for Supabase projects. Use when: (1) Need overview of database design principles, (2) Understanding tight-fit design philosophy, (3) Quick reference for standard table structure"
license: Proprietary. LICENSE.txt has complete terms
---

# PostgreSQL Conventions for Supabase

Overview of database design principles for Supabase projects.

**Environment:** PostgreSQL 17 on Supabase.

## Key Principles

1. **Consistency** - All objects follow predictable naming patterns
2. **Self-documenting** - Names indicate purpose and type
3. **Type safety** - Suffixes indicate data types
4. **Tight-fit design** - Only add confirmed requirements

## Tight-Fit Design

MUST NOT add speculative columns:

| Don't Add Speculatively | Add When |
|-------------------------|----------|
| `deleted_at` | Soft delete confirmed |
| `created_by`, `updated_by` | Audit trail required |
| `metadata jsonb` | Flexible data needed |
| Indexes | Query patterns known |

## Standard Table Structure

```sql
CREATE TABLE tb_examples (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## Related Skills

| Skill | Use For |
|-------|---------|
| **supabase-migration** | Creating migrations, naming conventions, security patterns |
| **supabase-seeding** | Populating test data, bulk loading |
| **supabase-bootstrap** | Setting up new projects, tooling config |
