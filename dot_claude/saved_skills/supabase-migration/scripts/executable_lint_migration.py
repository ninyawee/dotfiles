#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Lint Supabase migration files for convention compliance.

Usage:
    uv run lint_migration.py <file_or_directory> [options]

Examples:
    uv run lint_migration.py supabase/migrations/
    uv run lint_migration.py supabase/migrations/20251212_add_users.sql
    uv run lint_migration.py supabase/migrations/ --fix
"""

import argparse
import re
import sys
from pathlib import Path

# Convention patterns
PATTERNS = {
    "table_prefix": (r"\bCREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?!tb_)\w+", "Tables must use tb_ prefix"),
    "view_prefix": (r"\bCREATE\s+(?:OR\s+REPLACE\s+)?VIEW\s+(?!v_)\w+", "Views must use v_ prefix"),
    "function_prefix": (r"\bCREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+(?!fn_|private\.fn_)\w+", "Functions must use fn_ prefix"),
    "function_version": (r"\bCREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+fn_[^_]+(?!_v\d)", "Functions should be versioned (_v1, _v2)"),
    "trigger_prefix": (r"\bCREATE\s+TRIGGER\s+(?!tgr_)\w+", "Triggers must use tgr_ prefix"),
    "index_prefix": (r"\bCREATE\s+(?:UNIQUE\s+)?INDEX\s+(?:IF\s+NOT\s+EXISTS\s+)?(?!idx_)\w+", "Indexes must use idx_ prefix"),
    "enum_prefix": (r"\bCREATE\s+TYPE\s+(?!en_)\w+\s+AS\s+ENUM", "Enum types must use en_ prefix"),
    "policy_prefix": (r"\bCREATE\s+POLICY\s+(?!pc_)\w+", "RLS policies must use pc_ prefix"),
    "extension_schema": (r"\bCREATE\s+EXTENSION\s+(?:IF\s+NOT\s+EXISTS\s+)?\w+(?!\s+SCHEMA\s+extensions)", "Extensions should use SCHEMA extensions"),
    "security_invoker": (r"\bCREATE\s+(?:OR\s+REPLACE\s+)?VIEW\s+\w+(?!\s+WITH\s+\(security_invoker\))", "Views should use WITH (security_invoker)"),
    "search_path": (r"LANGUAGE\s+plpgsql(?!.*SET\s+search_path)", "Functions should SET search_path"),
}

# Warnings (non-blocking)
WARNINGS = {
    "no_transaction": (r"^(?!.*\bBEGIN\b)", "Consider wrapping in BEGIN/COMMIT transaction"),
    "no_comment_table": (r"\bCREATE\s+TABLE\b(?!.*COMMENT\s+ON\s+TABLE)", "Consider adding COMMENT ON TABLE"),
    "insert_in_migration": (r"\bINSERT\s+INTO\b", "INSERT statements should be in seed files, not migrations"),
}


def lint_file(filepath: Path, strict: bool = False) -> list[dict]:
    """Lint a single migration file and return issues."""
    content = filepath.read_text()
    issues = []

    # Check filename format
    if not re.match(r"^\d{14}_\w+\.sql$", filepath.name):
        issues.append({
            "file": filepath.name,
            "line": 0,
            "severity": "error",
            "message": f"Filename should match YYYYMMDDHHMMSS_description.sql",
        })

    # Check patterns
    for name, (pattern, message) in PATTERNS.items():
        for match in re.finditer(pattern, content, re.IGNORECASE | re.MULTILINE):
            line_num = content[:match.start()].count("\n") + 1
            issues.append({
                "file": filepath.name,
                "line": line_num,
                "severity": "error",
                "message": message,
                "match": match.group()[:50],
            })

    # Check warnings
    for name, (pattern, message) in WARNINGS.items():
        if re.search(pattern, content, re.IGNORECASE | re.MULTILINE | re.DOTALL):
            issues.append({
                "file": filepath.name,
                "line": 0,
                "severity": "warning",
                "message": message,
            })

    return issues


def main():
    parser = argparse.ArgumentParser(
        description="Lint Supabase migrations for convention compliance",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "path",
        type=Path,
        help="Migration file or directory to lint",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Treat warnings as errors",
    )
    parser.add_argument(
        "--quiet",
        "-q",
        action="store_true",
        help="Only show errors, not warnings",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output as JSON",
    )

    args = parser.parse_args()

    # Find files to lint
    if args.path.is_dir():
        files = sorted(args.path.glob("*.sql"))
    elif args.path.is_file():
        files = [args.path]
    else:
        print(f"Error: {args.path} not found", file=sys.stderr)
        sys.exit(1)

    if not files:
        print(f"No SQL files found in {args.path}")
        sys.exit(0)

    # Lint all files
    all_issues = []
    for filepath in files:
        issues = lint_file(filepath, args.strict)
        all_issues.extend(issues)

    # Filter warnings if quiet
    if args.quiet:
        all_issues = [i for i in all_issues if i["severity"] == "error"]

    # Output
    if args.json:
        import json
        print(json.dumps(all_issues, indent=2))
    else:
        errors = [i for i in all_issues if i["severity"] == "error"]
        warnings = [i for i in all_issues if i["severity"] == "warning"]

        for issue in all_issues:
            severity = issue["severity"].upper()
            line = f":{issue['line']}" if issue["line"] > 0 else ""
            match_info = f" ({issue['match']})" if "match" in issue else ""
            print(f"{issue['file']}{line}: [{severity}] {issue['message']}{match_info}")

        print(f"\n{len(files)} file(s) checked: {len(errors)} error(s), {len(warnings)} warning(s)")

        if errors or (args.strict and warnings):
            sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
