# Notebooks

Python / pandas was used only as an auxiliary troubleshooting layer during data ingestion, especially for inspecting problematic CSV content and review-text loading issues.

The core analytical workflow is intentionally SQL-first:

```text
Raw CSVs → PostgreSQL → SQL analytical views → Power BI → DAX → Business insights
```

This design keeps the portfolio focused on a BI / Data Analyst workflow while still demonstrating that Python can support ingestion, data inspection, encoding troubleshooting, and automation when required.

No notebook is required to reproduce the final analytical model because the production transformations and validation logic are documented in the `sql/` folder.
