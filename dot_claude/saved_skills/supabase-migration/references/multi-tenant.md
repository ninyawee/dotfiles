# Multi-Tenant Architecture

Use row-level security (RLS) with discriminator columns.

**Required column:**
- `environment_cd` - Separates dev and prod data

**Optional columns:**
- `tenant_uid` - For SaaS multi-tenant applications
- `platform_cd` - For multi-platform applications

```sql
CREATE TABLE tb_examples (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Environment isolation (REQUIRED)
    environment_cd text NOT NULL DEFAULT 'dev'
        CHECK (environment_cd IN ('dev', 'prod')),

    -- Tenant isolation (OPTIONAL - for SaaS)
    tenant_uid uuid REFERENCES tb_tenants(id),

    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- RLS policies
CREATE POLICY pc_examples_environment ON tb_examples
    USING (environment_cd = current_setting('app.environment', true));

CREATE POLICY pc_examples_tenant ON tb_examples
    USING (tenant_uid = current_setting('app.tenant_uid', true)::uuid);
```

**Environment config:**
```sql
SET app.environment = 'prod';
SET app.tenant_uid = 'uuid-here';
```
