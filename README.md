# Financial-Reconciliation-System-using-SQL-and-PowerBI
*Short pitch:**  
A compact, production-minded collection of ETL pipelines, warehouse tables, SQL transforms, and dashboards built to transform noisy transactional data (CSV / MySQL) into a reliable BigQuery data warehouse and Power BI reports. Designed for mid-scale datasets (10k–100k rows) and practical reuse in analytical/operational workflows.

---

## Contents / Projects
1. **Sales & Revenue Insights (SQL + Warehousing)**  
   Build warehouse-ready sales tables in BigQuery with optimized SQL and a Power BI report for revenue analytics.

2. **Customer Order Data Integration & ETL Workflow**  
   ETL pipeline that ingests CSV + MySQL order data, transforms business logic with SQL rules, and loads into BigQuery layers.

3. **Financial Reconciliation System (Validation + Reporting)**  
   SQL-driven validation checks and a compact dashboard to highlight ledger vs. expense mismatches and month-end cash movement.

---


## Architecture & Design (summary)
- **Ingest layer:** Raw files (CSV) and source DB (MySQL) are pulled into a raw staging area.  
- **Transform layer:** SQL transforms normalize data, deduplicate, and convert to analytical schemas (star/snowflake).  
- **Warehouse layer:** Processed, query-optimized tables in BigQuery (or equivalent RDBMS) for reporting.  
- **Reporting layer:** Power BI connects to warehouse tables for dashboards.  
- **Validation layer:** SQL checks detect mismatches and exceptions (financial reconciliation).

---

## Key design choices (why this is practical)
- **SQL-first transforms** for readability, auditability, and easy handoff to analysts.  
- **Layered tables (raw → curated → reporting)** for traceability and safe backfills.  
- **Indexing & partitioning suggestions** (date partitioning in BigQuery) to keep queries fast as data grows.  
- **Documented data flows** so stakeholders can understand transformation logic quickly.

---

## Quickstart — Local (dev) setup
> Prereqs: Python 3.9+, `pip`, Google Cloud SDK (if using BigQuery), access to MySQL (or sample CSVs)

1. Clone the repo
```bash
git clone https://github.com/<your-username>/Finance-Analysis-main.git
cd Finance-Analysis-main

Example ETL (MySQL → BigQuery)

pipelines/etl_mysql_to_bq.py:
Connects to source MySQL, extracts incremental rows using an updated_at column.
Writes to a staging table in BigQuery (append or partitioned load).
Runs a SQL transform to create warehouse.orders_curated.

Example run:

python pipelines/etl_mysql_to_bq.py --mysql-host host --mysql-db orders_db \
  --bq-project your-gcp-project --bq-dataset analytics --bq-table staging_orders



## Create a reporting table (star schema)

CREATE TABLE analytics.orders_fact AS
SELECT
  o.order_id,
  o.customer_id,
  o.order_date,
  o.total_amount,
  p.category_id
FROM warehouse.orders_curated o
JOIN warehouse.products_dim p USING(product_id);


## Optimization hint — window dedupe

WITH latest AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) as rn
  FROM staging.orders
)
SELECT * FROM latest WHERE rn = 1;


## Reconciliation check

SELECT a.date, SUM(a.ledger_amount) ledger, SUM(b.expense_amount) expense,
  SUM(a.ledger_amount) - SUM(b.expense_amount) diff
FROM warehouse.ledger a
FULL JOIN warehouse.expenses b USING(date)
GROUP BY a.date
HAVING ABS(SUM(a.ledger_amount) - SUM(b.expense_amount)) > 1.0;

## Power BI notes

Use the curated BigQuery tables as a single source of truth.
Keep heavy calculations in SQL (warehouse) — Power BI should focus on visualization.
Use incremental refresh on date-partitioned tables to keep dashboards fast.

## Data quality & monitoring

Implement SQL-based checks in sql/checks/ (e.g., null rate, duplicates, aggregation tests).
Schedule checks after ETL runs and slack/email alerts for failures.
Store last successful ETL run timestamp in a meta.etl_runs table for safe incremental extraction.
