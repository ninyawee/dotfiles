#!/usr/bin/env python3
"""Inspect DBF file structure and sample data.

Usage:
    uv run python inspect_dbf.py file.DBF
    uv run python inspect_dbf.py file.DBF --records 10
    uv run python inspect_dbf.py /path/to/*.DBF --summary
"""

import argparse
from pathlib import Path

from roonpoo import DBF


def inspect_dbf(dbf_path: Path, num_records: int = 3, show_fields: bool = True):
    """Inspect a DBF file and print structure."""
    table = DBF(dbf_path, encoding="tis-620", char_decode_errors="replace")

    print(f"\n{'=' * 60}")
    print(f"File: {dbf_path.name}")
    print(f"{'=' * 60}")
    print(f"DBF Version: {table.dbversion}")
    print(f"Last Modified: {table.date}")
    print(f"Records: {table.header.numrecords}")

    if show_fields:
        print(f"\nFields ({len(table.fields)}):")
        for f in table.fields:
            print(f"  {f.name:15} {f.type:3} len={f.length}")

    if num_records > 0:
        print(f"\nSample records ({num_records}):")
        for i, record in enumerate(table):
            if i >= num_records:
                break
            # Compact display
            items = [f"{k}={v!r}" for k, v in list(record.items())[:5]]
            print(f"  [{i}] {', '.join(items)}...")


def summarize_dbf(dbf_path: Path):
    """Print one-line summary of DBF file."""
    try:
        table = DBF(dbf_path, encoding="tis-620", char_decode_errors="replace")
        print(f"{dbf_path.name:20} {table.header.numrecords:>8} records  {len(table.fields):>3} fields  {table.date}")
    except Exception as e:
        print(f"{dbf_path.name:20} ERROR: {e}")


def main():
    parser = argparse.ArgumentParser(description="Inspect DBF file structure")
    parser.add_argument("files", nargs="+", help="DBF files to inspect")
    parser.add_argument("-r", "--records", type=int, default=3, help="Sample records to show")
    parser.add_argument("--summary", action="store_true", help="One-line summary per file")
    parser.add_argument("--no-fields", action="store_true", help="Don't show field list")
    args = parser.parse_args()

    for file_pattern in args.files:
        paths = list(Path(".").glob(file_pattern)) if "*" in file_pattern else [Path(file_pattern)]
        for dbf_path in sorted(paths):
            if args.summary:
                summarize_dbf(dbf_path)
            else:
                inspect_dbf(dbf_path, args.records, not args.no_fields)


if __name__ == "__main__":
    main()
