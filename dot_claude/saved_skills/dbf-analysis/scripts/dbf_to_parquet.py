#!/usr/bin/env python3
"""Convert DBF files to Parquet format.

Usage:
    uv run python dbf_to_parquet.py /path/to/*.DBF -o /output/dir/
    uv run python dbf_to_parquet.py file.DBF  # outputs to same directory
"""

import argparse
from pathlib import Path
from decimal import Decimal

from roonpoo import DBF
import pyarrow as pa
import pyarrow.parquet as pq


def convert_dbf_to_parquet(
    dbf_path: Path,
    output_dir: Path | None = None,
    encoding: str = "tis-620",
) -> tuple[Path, int]:
    """Convert a DBF file to Parquet format.

    Args:
        dbf_path: Path to DBF file
        output_dir: Output directory (defaults to same as input)
        encoding: Character encoding (tis-620 or cp874 for Thai)

    Returns:
        Tuple of (output_path, record_count)
    """
    dbf_path = Path(dbf_path)
    if output_dir is None:
        output_dir = dbf_path.parent
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    table = DBF(dbf_path, encoding=encoding, char_decode_errors="replace")
    records = list(table)

    # Build columns
    columns = {f.name: [] for f in table.fields}
    for rec in records:
        for field in table.fields:
            val = rec.get(field.name)
            if isinstance(val, Decimal):
                val = float(val)
            columns[field.name].append(val)

    # Write Parquet
    arrow_table = pa.table(columns)
    output_path = output_dir / f"{dbf_path.stem}.parquet"
    pq.write_table(arrow_table, output_path)

    return output_path, len(records)


def main():
    parser = argparse.ArgumentParser(description="Convert DBF files to Parquet")
    parser.add_argument("files", nargs="+", help="DBF files to convert")
    parser.add_argument("-o", "--output", help="Output directory")
    parser.add_argument(
        "--encoding", default="tis-620", help="Character encoding (default: tis-620)"
    )
    args = parser.parse_args()

    output_dir = Path(args.output) if args.output else None

    for file_pattern in args.files:
        for dbf_path in Path(".").glob(file_pattern) if "*" in file_pattern else [Path(file_pattern)]:
            try:
                out_path, count = convert_dbf_to_parquet(
                    dbf_path, output_dir, args.encoding
                )
                print(f"✓ {dbf_path.name} → {out_path.name} ({count} rows)")
            except Exception as e:
                print(f"✗ {dbf_path.name} → ERROR: {e}")


if __name__ == "__main__":
    main()
