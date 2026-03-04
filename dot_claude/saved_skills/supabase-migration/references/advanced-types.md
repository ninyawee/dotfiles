# Advanced PostgreSQL Types

| Use Case | Type | Benefits |
|----------|------|----------|
| Hierarchical data | `ltree` | Efficient tree queries |
| Time intervals | `tstzrange` | Built-in overlap checks |
| Number ranges | `int8range` | Range operations |

## ltree - Hierarchical Data

```sql
CREATE EXTENSION IF NOT EXISTS ltree SCHEMA extensions;

CREATE TABLE tb_departments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    path ltree NOT NULL
);

-- Insert hierarchy
INSERT INTO tb_departments (name, path) VALUES
    ('Company', 'root'),
    ('Engineering', 'root.engineering'),
    ('Frontend', 'root.engineering.frontend'),
    ('Backend', 'root.engineering.backend');

-- Find all children of engineering
SELECT * FROM tb_departments WHERE path <@ 'root.engineering';

-- Find ancestors
SELECT * FROM tb_departments WHERE path @> 'root.engineering.frontend';
```

## tstzrange - Time Intervals

```sql
CREATE TABLE tb_bookings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    resource_uid uuid NOT NULL,
    period tstzrange NOT NULL,
    -- Prevent overlapping bookings for same resource
    EXCLUDE USING gist (resource_uid WITH =, period WITH &&)
);

-- Check if ranges overlap
SELECT * FROM tb_bookings
WHERE period && tstzrange('2024-01-01', '2024-01-02');

-- Check if timestamp is within range
SELECT * FROM tb_bookings
WHERE period @> '2024-01-01 12:00:00'::timestamptz;
```

## int8range - Number Ranges

```sql
CREATE TABLE tb_price_tiers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    quantity_range int8range NOT NULL,
    price_amt decimal(15,2) NOT NULL,
    EXCLUDE USING gist (quantity_range WITH &&)
);

-- Find tier for quantity
SELECT * FROM tb_price_tiers
WHERE quantity_range @> 50;
```
