#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Run SQL seed files against a PostgreSQL database with progress monitoring.

Usage:
    uv run run_seeds.py <seed_directory> [options]

Examples:
    uv run run_seeds.py supabase/seed/
    uv run run_seeds.py supabase/seed/ --db-url postgres://localhost/mydb
    uv run run_seeds.py supabase/seed/ --pattern "01_*.sql"
    uv run run_seeds.py supabase/seed/ --dry-run
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path


def get_db_url():
    """Get database URL from environment or Supabase config."""
    if os.environ.get("DATABASE_URL"):
        return os.environ["DATABASE_URL"]

    # Try to get from supabase status
    try:
        result = subprocess.run(
            ["supabase", "status", "--output", "json"],
            capture_output=True,
            text=True,
            check=True,
        )
        status = json.loads(result.stdout)
        return status.get("DB_URL", "")
    except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
        return None


def run_seed_file(filepath: Path, db_url: str, dry_run: bool = False) -> bool:
    """Run a single seed file and return success status."""
    print(f"{'[DRY RUN] ' if dry_run else ''}Seeding: {filepath.name}")

    if dry_run:
        return True

    try:
        # Use pv for progress if available, otherwise plain psql
        try:
            subprocess.run(["pv", "--version"], capture_output=True, check=True)
            cmd = f"pv '{filepath}' | psql '{db_url}'"
            shell = True
        except (subprocess.CalledProcessError, FileNotFoundError):
            cmd = ["psql", db_url, "-f", str(filepath)]
            shell = False

        result = subprocess.run(cmd, shell=shell, capture_output=True, text=True)

        if result.returncode != 0:
            print(f"  ERROR: {result.stderr}", file=sys.stderr)
            return False

        print("  OK")
        return True

    except Exception as e:
        print(f"  ERROR: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Run SQL seed files with progress monitoring",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "seed_dir", type=Path, help="Directory containing seed SQL files"
    )
    parser.add_argument(
        "--db-url",
        help="Database URL (default: $DATABASE_URL or from supabase status)",
    )
    parser.add_argument(
        "--pattern", default="*.sql", help="Glob pattern for seed files (default: *.sql)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show which files would be run without executing",
    )
    parser.add_argument(
        "--stop-on-error", action="store_true", help="Stop execution on first error"
    )

    args = parser.parse_args()

    # Validate seed directory
    if not args.seed_dir.is_dir():
        print(f"Error: {args.seed_dir} is not a directory", file=sys.stderr)
        sys.exit(1)

    # Get database URL
    db_url = args.db_url or get_db_url()
    if not db_url and not args.dry_run:
        print(
            "Error: No database URL. Set DATABASE_URL or use --db-url", file=sys.stderr
        )
        sys.exit(1)

    # Find seed files
    seed_files = sorted(args.seed_dir.glob(args.pattern))
    if not seed_files:
        print(f"No files matching '{args.pattern}' in {args.seed_dir}")
        sys.exit(0)

    print(f"Found {len(seed_files)} seed file(s)\n")

    # Run seeds
    success_count = 0
    for filepath in seed_files:
        if run_seed_file(filepath, db_url, args.dry_run):
            success_count += 1
        elif args.stop_on_error:
            print(f"\nStopped after error. {success_count}/{len(seed_files)} completed.")
            sys.exit(1)

    print(f"\nCompleted: {success_count}/{len(seed_files)} seed files")
    sys.exit(0 if success_count == len(seed_files) else 1)


if __name__ == "__main__":
    main()
