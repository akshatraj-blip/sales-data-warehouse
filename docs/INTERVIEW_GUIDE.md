I built a SQL Server sales warehouse that turns separate CRM and ERP extracts into a reporting-ready star schema. Raw files land unchanged in Bronze, Silver applies data-quality rules and standardization, and Gold exposes customer and product dimensions plus a sales fact view. The model is designed so analysts can answer revenue, product, and customer questions without having to understand the source-system quirks.

## Live demo sequence

1. Run `./deploy.ps1`. It starts SQL Server in Docker, builds schemas, loads all CSV files, and runs quality checks.
2. Run `analytics/executive_demo.sql`: scorecard, monthly trend, product performance, then customer segments.
3. Show `docs/data_architecture.png` and explain the raw-to-business separation.
4. Open `tests/quality_checks_gold.sql` and explain uniqueness and referential-integrity tests.

## Recruiter questions and concise answers

| Question | Answer |
| --- | --- |
| Why use Bronze, Silver, and Gold? | Bronze protects source traceability, Silver isolates quality logic, and Gold gives analysts simple, stable entities. |
| What data-quality issues did you handle? | I deduplicated customers, normalized codes, rejected future birthdates, parsed invalid dates to NULL, and reconciled inconsistent sales values. |
| Why a star schema? | A central sales fact connected to conformed dimensions keeps BI queries simple and easy to understand. |
| How is this repeatable? | Docker provides the same runtime; `deploy.ps1` applies DDL in order, loads data, and runs tests. |
| What would you improve for production? | Incremental loads and watermarks, orchestration/alerts, a secret manager, CI validation, and materialized Gold tables as volume grows. |
| How do you test it? | Silver checks validate transformations; Gold checks test duplicate keys and orphaned facts. The runner fails on SQL errors. |

## Honest scope statement

This is a portfolio demonstration built on a public educational dataset. Describe the implementation decisions you made; do not present the source dataset or template work as proprietary production experience.
