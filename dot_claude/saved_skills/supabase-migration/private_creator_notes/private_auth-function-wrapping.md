# Auth Function Wrapping in RLS

## The Problem

When you use `auth.uid()`, `auth.jwt()`, or `current_setting()` directly in RLS policy expressions, Postgres may re-evaluate these function calls **for every row** being checked. This is because the query planner doesn't always recognize these as stable values that only need to be computed once per statement.

## Why It Happens

PostgreSQL's planner categorizes functions by volatility:
- **IMMUTABLE**: Same inputs always produce same outputs (can be pre-computed)
- **STABLE**: Returns same result within a single statement (should be computed once)
- **VOLATILE**: Can return different results on each call

The `auth.*()` functions are marked STABLE, but within an RLS policy's USING clause, the planner sometimes fails to "pull out" the function call and cache it. Instead, it inlines the call into the row-by-row filter.

## Why (SELECT ...) Works

Wrapping in a scalar subquery `(SELECT auth.uid())` forces the planner to evaluate it as a separate, single-row subquery. The result is then treated as a constant for the rest of the statement. This is a well-known PostgreSQL optimization pattern.

## Performance Impact

On tables with thousands of rows:
- **Without wrapper**: `auth.uid()` called N times (once per row)
- **With wrapper**: `(SELECT auth.uid())` called once, result reused

This can mean 10-100x performance improvement on large tables.
