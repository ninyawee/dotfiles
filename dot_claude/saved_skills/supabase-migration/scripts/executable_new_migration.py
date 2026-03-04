#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Create a new Supabase migration file with proper naming and template.

Usage:
    uv run new_migration.py <description> [options]

Examples:
    uv run new_migration.py "add_users_table"
    uv run new_migration.py "add_avatar_to_profiles" --type alter
    uv run new_migration.py "add_calculate_total_fn" --type function
    uv run new_migration.py "add_orders_table" --dir ./migrations
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path

TEMPLATES = {
    "table": '''\
-- Migration: {description}
-- Author: {author}
-- Date: {date}

BEGIN;

-- 1. Types/Enums (if needed)
-- DO $$
-- BEGIN
--     CREATE TYPE en_status AS ENUM ('active', 'inactive');
-- EXCEPTION
--     WHEN duplicate_object THEN NULL;
-- END $$;

-- 2. Table
CREATE TABLE IF NOT EXISTS tb_{table_name} (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Add columns here
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Comments
COMMENT ON TABLE tb_{table_name} IS 'Module: Description';

-- 4. Indexes
-- CREATE INDEX IF NOT EXISTS idx_{table_name}_column ON tb_{table_name}(column);

-- 5. Timestamp trigger
DROP TRIGGER IF EXISTS tgr_update_{table_name}_timestamp ON tb_{table_name};
CREATE TRIGGER tgr_update_{table_name}_timestamp
    BEFORE UPDATE ON tb_{table_name}
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 6. RLS
ALTER TABLE tb_{table_name} ENABLE ROW LEVEL SECURITY;

-- DROP POLICY IF EXISTS pc_{table_name}_select ON tb_{table_name};
-- CREATE POLICY pc_{table_name}_select ON tb_{table_name}
--     FOR SELECT USING (true);

COMMIT;
''',
    "alter": '''\
-- Migration: {description}
-- Author: {author}
-- Date: {date}

BEGIN;

-- Add column
-- ALTER TABLE tb_table_name ADD COLUMN IF NOT EXISTS new_column text;

-- Add index
-- CREATE INDEX IF NOT EXISTS idx_table_column ON tb_table_name(column);

-- Add constraint
-- ALTER TABLE tb_table_name ADD CONSTRAINT uq_table_column UNIQUE (column);

COMMIT;
''',
    "function": '''\
-- Migration: {description}
-- Author: {author}
-- Date: {date}

BEGIN;

CREATE OR REPLACE FUNCTION fn_{func_name}_v1()
RETURNS void AS $$
BEGIN
    -- Function logic here
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = extensions, public, pg_temp;

COMMENT ON FUNCTION fn_{func_name}_v1() IS 'Description';

COMMIT;
''',
    "rls": '''\
-- Migration: {description}
-- Author: {author}
-- Date: {date}

BEGIN;

-- Enable RLS
-- ALTER TABLE tb_table_name ENABLE ROW LEVEL SECURITY;

-- Select policy
DROP POLICY IF EXISTS pc_table_select ON tb_table_name;
CREATE POLICY pc_table_select ON tb_table_name
    FOR SELECT USING (
        -- Condition here
        true
    );

-- Insert policy
-- DROP POLICY IF EXISTS pc_table_insert ON tb_table_name;
-- CREATE POLICY pc_table_insert ON tb_table_name
--     FOR INSERT WITH CHECK (
--         auth.uid() IS NOT NULL
--     );

-- Update policy
-- DROP POLICY IF EXISTS pc_table_update ON tb_table_name;
-- CREATE POLICY pc_table_update ON tb_table_name
--     FOR UPDATE USING (
--         user_uid = auth.uid()
--     );

COMMIT;
''',
    "empty": '''\
-- Migration: {description}
-- Author: {author}
-- Date: {date}

BEGIN;

-- Your migration here

COMMIT;
''',
}


def extract_name(description: str) -> str:
    """Extract a name from the description for use in identifiers."""
    # Remove common prefixes
    for prefix in ["add_", "create_", "update_", "modify_", "remove_", "delete_"]:
        if description.startswith(prefix):
            description = description[len(prefix) :]
            break

    # Remove common suffixes
    for suffix in ["_table", "_fn", "_function", "_trigger", "_policy", "_index"]:
        if description.endswith(suffix):
            description = description[: -len(suffix)]
            break

    return description


def main():
    parser = argparse.ArgumentParser(
        description="Create a new Supabase migration file",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "description",
        help="Migration description in snake_case (e.g., add_users_table)",
    )
    parser.add_argument(
        "--type",
        "-t",
        choices=["table", "alter", "function", "rls", "empty"],
        default="table",
        help="Migration template type (default: table)",
    )
    parser.add_argument(
        "--dir",
        "-d",
        type=Path,
        default=Path("supabase/migrations"),
        help="Migrations directory (default: supabase/migrations)",
    )
    parser.add_argument(
        "--author",
        "-a",
        default="",
        help="Author name for migration header",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the migration without creating file",
    )

    args = parser.parse_args()

    # Generate timestamp and filename
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    filename = f"{timestamp}_{args.description}.sql"
    filepath = args.dir / filename

    # Get template
    template = TEMPLATES.get(args.type, TEMPLATES["empty"])

    # Extract name for identifiers
    name = extract_name(args.description)

    # Format template
    content = template.format(
        description=args.description.replace("_", " ").title(),
        author=args.author,
        date=datetime.now().strftime("%Y-%m-%d"),
        table_name=name,
        func_name=name,
    )

    if args.dry_run:
        print(f"# Would create: {filepath}\n")
        print(content)
        return

    # Create directory if needed
    args.dir.mkdir(parents=True, exist_ok=True)

    # Write file
    filepath.write_text(content)
    print(f"Created: {filepath}")


if __name__ == "__main__":
    main()
