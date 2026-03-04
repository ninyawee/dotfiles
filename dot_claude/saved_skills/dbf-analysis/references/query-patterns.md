# DuckDB Query Patterns for Thai Accounting Data

Advanced query patterns for analyzing Thai legacy accounting databases.

## Setup

```python
import duckdb
con = duckdb.connect()
parquet_dir = 'path/to/parquet'
```

## Aggregation Queries

### Monthly Revenue Summary

```sql
SELECT
    strftime(DATEDOC, '%Y-%m') as month,
    COUNT(*) as invoices,
    ROUND(SUM(AMOUNT_A), 2) as revenue
FROM '{parquet_dir}/ARTR.parquet'
WHERE DATEDOC IS NOT NULL
GROUP BY strftime(DATEDOC, '%Y-%m')
ORDER BY month
```

### Top Customers by Revenue

```sql
SELECT
    a.ACCID,
    m.COMP,
    COUNT(*) as txn_count,
    ROUND(SUM(a.AMOUNT_A), 2) as total_revenue
FROM '{parquet_dir}/ARTR.parquet' a
LEFT JOIN '{parquet_dir}/ARMST.parquet' m ON a.ACCID = m.ACCID
GROUP BY a.ACCID, m.COMP
ORDER BY total_revenue DESC
LIMIT 20
```

### GL Account Balances

```sql
SELECT
    GLID,
    ROUND(SUM(DEBIT), 2) as total_debit,
    ROUND(SUM(CREDIT), 2) as total_credit,
    ROUND(SUM(DEBIT) - SUM(CREDIT), 2) as balance
FROM '{parquet_dir}/GLTR.parquet'
GROUP BY GLID
ORDER BY ABS(balance) DESC
```

## Date-Based Analysis

### Aging Analysis

```sql
SELECT
    CASE
        WHEN DUEDATE >= CURRENT_DATE THEN 'Current'
        WHEN DUEDATE >= CURRENT_DATE - INTERVAL '30 days' THEN '1-30 days'
        WHEN DUEDATE >= CURRENT_DATE - INTERVAL '60 days' THEN '31-60 days'
        WHEN DUEDATE >= CURRENT_DATE - INTERVAL '90 days' THEN '61-90 days'
        ELSE 'Over 90 days'
    END as aging_bucket,
    COUNT(*) as invoices,
    ROUND(SUM(BALANCE), 2) as total_balance
FROM '{parquet_dir}/ARTR.parquet'
WHERE BALANCE > 0
GROUP BY aging_bucket
ORDER BY
    CASE aging_bucket
        WHEN 'Current' THEN 1
        WHEN '1-30 days' THEN 2
        WHEN '31-60 days' THEN 3
        WHEN '61-90 days' THEN 4
        ELSE 5
    END
```

### Year-over-Year Comparison

```sql
SELECT
    EXTRACT(YEAR FROM DATEDOC) as year,
    EXTRACT(MONTH FROM DATEDOC) as month,
    COUNT(*) as transactions,
    ROUND(SUM(AMOUNT_A), 2) as revenue
FROM '{parquet_dir}/ARTR.parquet'
WHERE DATEDOC IS NOT NULL
GROUP BY year, month
ORDER BY year, month
```

## Cross-Table Analysis

### Customer with Transaction Details

```sql
SELECT
    m.ACCID,
    m.COMP,
    m.TEL,
    m.CREDITDAY,
    m.CREDITAMT,
    COUNT(t.DOCNO) as total_invoices,
    ROUND(SUM(t.AMOUNT_A), 2) as total_sales,
    ROUND(SUM(t.BALANCE), 2) as outstanding
FROM '{parquet_dir}/ARMST.parquet' m
LEFT JOIN '{parquet_dir}/ARTR.parquet' t ON m.ACCID = t.ACCID
GROUP BY m.ACCID, m.COMP, m.TEL, m.CREDITDAY, m.CREDITAMT
HAVING total_invoices > 0
ORDER BY total_sales DESC
```

### Payment Performance

```sql
SELECT
    m.ACCID,
    m.COMP,
    COUNT(DISTINCT t.DOCNO) as invoices,
    COUNT(DISTINCT p.DOCNO) as payments,
    ROUND(SUM(t.AMOUNT_A), 2) as total_invoiced,
    ROUND(SUM(p.PAYAMT), 2) as total_paid
FROM '{parquet_dir}/ARMST.parquet' m
JOIN '{parquet_dir}/ARTR.parquet' t ON m.ACCID = t.ACCID
LEFT JOIN '{parquet_dir}/ARPAY.parquet' p ON t.DOCNO = p.INVNO
GROUP BY m.ACCID, m.COMP
ORDER BY total_invoiced DESC
LIMIT 20
```

## Data Quality Checks

### Find Orphan Transactions

```sql
-- AR transactions without matching customer
SELECT DISTINCT t.ACCID
FROM '{parquet_dir}/ARTR.parquet' t
LEFT JOIN '{parquet_dir}/ARMST.parquet' m ON t.ACCID = m.ACCID
WHERE m.ACCID IS NULL
```

### Check for Duplicates

```sql
SELECT DOCNO, COUNT(*) as count
FROM '{parquet_dir}/ARTR.parquet'
GROUP BY DOCNO
HAVING count > 1
```

### Date Range Validation

```sql
SELECT
    MIN(DATEDOC) as earliest,
    MAX(DATEDOC) as latest,
    COUNT(*) as records,
    COUNT(DATEDOC) as with_date,
    COUNT(*) - COUNT(DATEDOC) as missing_date
FROM '{parquet_dir}/ARTR.parquet'
```

## Export Patterns

### Export to CSV

```python
result = con.execute(query).fetchdf()
result.to_csv('output.csv', index=False)
```

### Export to Excel

```python
result = con.execute(query).fetchdf()
result.to_excel('output.xlsx', index=False)
```

### Export Summary Report

```python
import pandas as pd

# Multiple queries to single Excel with sheets
with pd.ExcelWriter('report.xlsx') as writer:
    con.execute(revenue_query).fetchdf().to_excel(writer, sheet_name='Revenue')
    con.execute(customers_query).fetchdf().to_excel(writer, sheet_name='Customers')
    con.execute(aging_query).fetchdf().to_excel(writer, sheet_name='Aging')
```

## Performance Tips

### Use Parquet Predicate Pushdown

```sql
-- Filter pushes to Parquet scan
SELECT * FROM '{parquet_dir}/ARTR.parquet'
WHERE DATEDOC >= '2023-01-01' AND DATEDOC < '2024-01-01'
```

### Limit Early

```sql
-- Limit before expensive operations
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY AMOUNT_A DESC) as rn
    FROM '{parquet_dir}/ARTR.parquet'
) WHERE rn <= 100
```

### Use EXPLAIN

```sql
EXPLAIN SELECT ... -- View query plan
EXPLAIN ANALYZE SELECT ... -- View plan with execution stats
```
