# Sales Data Warehouse

An end-to-end SQL Server warehouse that combines CRM and ERP sales data into a clean, analytics-ready star schema. It runs locally with Docker and includes a recruiter-friendly demo script, data-quality checks, and documented production next steps.


## What this demonstrates

- **Data engineering:** repeatable CSV ingestion, SQL stored-procedure ETL, and layered transformations.
- **Data quality:** deduplication, standardized source values, invalid-date handling, and sales reconciliation.
- **Data modelling:** reporting-ready customer and product dimensions joined to a sales fact view.
- **Business impact:** executive revenue, trend, product-performance, and customer-segmentation queries.
- **Operational readiness:** Dockerized SQL Server, a one-command deployment, and post-load checks.

## Architecture

`CSV sources → Bronze (raw) → Silver (cleaned/conformed) → Gold (star schema) → SQL analytics`

| Layer | Purpose | Example |
| --- | --- | --- |
| Bronze | Preserves source data with minimal handling. | CRM and ERP landing tables |
| Silver | Cleans, standardizes, and integrates values. | Validated customer, product, and sales records |
| Gold | Gives reporting users stable business entities. | `dim_customers`, `dim_products`, `fact_sales` |

## Run it locally

**Prerequisite:** Docker Desktop running on Windows. No local SQL Server or SSMS installation is required.

```powershell
cd C:\path\to\interview-ready-data-warehouse
.\deploy.ps1
```

The command starts SQL Server 2022 Developer Edition, recreates `DataWarehouse`, loads both source systems, and runs the quality-check SQL. The reset is intentional: it keeps the demo repeatable.

Connect with any SQL client:

```text
Server: localhost,1433
Database: DataWarehouse
Authentication: SQL Login
User: sa
Password: InterviewDemo!2026
```

Run [`analytics/executive_demo.sql`](analytics/executive_demo.sql) for the four-minute business demo. To stop the database later, run `docker compose down`; use `docker compose down -v` only when you also want to remove local database data.

## Interview use

The short walkthrough and prepared answers are in [`docs/INTERVIEW_GUIDE.md`](docs/INTERVIEW_GUIDE.md). Start with the scorecard query, then explain how the Bronze → Silver → Gold layers make the result trustworthy and reusable.

## Repository map

```text
analytics/                 Business-facing demo queries
datasets/                  CRM and ERP source extracts
docs/                      Architecture, catalog, and interview guide
scripts/                   Database DDL and ETL procedures
tests/                     Silver and Gold quality checks
compose.yaml               Reproducible SQL Server runtime
deploy.ps1                 One-command local deployment
```

## Production evolution

For production, replace full reloads with incremental loading and watermarks; orchestrate jobs with retries, alerts, and lineage; move credentials into a secret manager; add CI checks; and consider physical Gold tables/materialization as data volume grows.

## Attribution

This package adapts the public educational project from Data With Baraa. See the included MIT license and preserve attribution when publishing a derivative.
