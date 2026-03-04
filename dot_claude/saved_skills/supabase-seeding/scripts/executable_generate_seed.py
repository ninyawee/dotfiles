#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "faker",
# ]
# ///
"""
Generate seed data SQL from table schema or templates.

Usage:
    uv run generate_seed.py <table_name> [options]

Examples:
    uv run generate_seed.py tb_users --count 100
    uv run generate_seed.py tb_products --count 50 --output seed/03_products.sql
    uv run generate_seed.py tb_orders --template orders.json
"""

import argparse
import json
import sys
import uuid
from pathlib import Path
from typing import Any

from faker import Faker


def generate_uuid() -> str:
    """Generate a UUID v4."""
    return str(uuid.uuid4())


def generate_value(column_name: str, column_type: str, fake: Faker | None = None) -> str:
    """Generate a fake value based on column name and type."""
    name_lower = column_name.lower()

    # UUID fields
    if column_type == "uuid" or name_lower == "id" or name_lower.endswith("_uid"):
        return f"'{generate_uuid()}'"

    # Timestamps
    if name_lower in ("created_at", "updated_at") or name_lower.endswith("_ts"):
        return "CURRENT_TIMESTAMP"

    # Dates
    if name_lower.endswith("_dt"):
        if fake:
            return f"'{fake.date()}'"
        return "'2024-01-01'"

    # Email
    if name_lower == "email" or name_lower.endswith("_em"):
        if fake:
            return f"'{fake.email()}'"
        return "'user@example.com'"

    # Phone
    if name_lower.endswith("_pn"):
        if fake:
            return f"'{fake.phone_number()[:20]}'"
        return "'+1234567890'"

    # Name fields
    if name_lower == "name" or "name" in name_lower:
        if fake:
            return f"'{fake.name()}'"
        return "'Test Name'"

    # Boolean
    if column_type == "boolean" or name_lower.endswith("_bool"):
        return "false"

    # Amount/Money
    if name_lower.endswith("_amt"):
        if fake:
            return f"{fake.pydecimal(min_value=1, max_value=1000, right_digits=2)}"
        return "100.00"

    # Percentage
    if name_lower.endswith("_pct"):
        return "0"

    # Count/Number
    if name_lower.endswith("_num"):
        return "1"

    # Code/Status
    if name_lower.endswith("_cd"):
        return "'active'"

    # Text
    if name_lower.endswith("_txt"):
        if fake:
            return f"'{fake.sentence()[:100]}'"
        return "'Sample text'"

    # Path
    if name_lower.endswith("_path"):
        return "NULL"

    # Default text
    if column_type == "text":
        return "'sample'"

    # Default number
    if column_type in ("integer", "bigint", "smallint"):
        return "0"

    if column_type in ("decimal", "numeric", "real", "double precision"):
        return "0.0"

    return "NULL"


def generate_insert(
    table_name: str, columns: list[dict], count: int, use_faker: bool = True
) -> str:
    """Generate INSERT statements for a table."""
    fake = Faker() if use_faker else None

    col_names = [c["name"] for c in columns]
    header = f"INSERT INTO {table_name} ({', '.join(col_names)}) VALUES"

    rows = []
    for i in range(count):
        if fake:
            fake.seed_instance(i)  # Reproducible
        values = [generate_value(c["name"], c["type"], fake) for c in columns]
        rows.append(f"    ({', '.join(values)})")

    return f"{header}\n{',\n'.join(rows)}\nON CONFLICT DO NOTHING;"


def main():
    parser = argparse.ArgumentParser(
        description="Generate seed data SQL",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("table_name", nargs="?", help="Table name (e.g., tb_users)")
    parser.add_argument(
        "--count", "-n", type=int, default=10, help="Number of rows to generate (default: 10)"
    )
    parser.add_argument(
        "--output", "-o", type=Path, help="Output file (default: stdout)"
    )
    parser.add_argument(
        "--columns",
        "-c",
        help='Column definitions as JSON array: [{"name": "id", "type": "uuid"}, ...]',
    )
    parser.add_argument(
        "--template", "-t", type=Path, help="JSON template file with column definitions"
    )
    parser.add_argument(
        "--no-faker", action="store_true", help="Don't use Faker for realistic data"
    )
    parser.add_argument(
        "--wrap-transaction", action="store_true", help="Wrap output in BEGIN/COMMIT"
    )

    args = parser.parse_args()

    if not args.table_name:
        parser.print_help()
        print("\nExample column definitions:")
        print(
            '  --columns \'[{"name": "id", "type": "uuid"}, {"name": "email", "type": "text"}, {"name": "created_at", "type": "timestamptz"}]\''
        )
        sys.exit(1)

    # Get column definitions
    if args.template:
        with open(args.template) as f:
            columns = json.load(f)
    elif args.columns:
        columns = json.loads(args.columns)
    else:
        # Default columns for common tables
        columns = [
            {"name": "id", "type": "uuid"},
            {"name": "name", "type": "text"},
            {"name": "created_at", "type": "timestamptz"},
            {"name": "updated_at", "type": "timestamptz"},
        ]
        print(
            "Using default columns. Specify --columns for custom schema.", file=sys.stderr
        )

    # Generate SQL
    sql = generate_insert(
        args.table_name, columns, args.count, use_faker=not args.no_faker
    )

    if args.wrap_transaction:
        sql = f"BEGIN;\n\n{sql}\n\nCOMMIT;"

    # Output
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(sql)
        print(f"Generated {args.count} rows -> {args.output}")
    else:
        print(sql)


if __name__ == "__main__":
    main()
