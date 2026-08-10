# Data

This folder contains the project datasets for the SaaS growth and retention analysis. The `raw/` files are the original inputs, and the `cleaned/` files are the outputs produced by the ETL cleaning notebook.

## Folder Structure

| Folder | Purpose |
| --- | --- |
| `raw/` | Original CSV exports used as the starting point for cleaning and analysis. |
| `cleaned/` | Cleaned CSVs with duplicates, missing values, and invalid records handled in the ETL workflow. |

## Dataset Inventory

| Dataset | Raw Rows | Cleaned Rows | Description |
| --- | ---: | ---: | --- |
| `accounts` | 550 | 537 | Account profile data including company, industry, country, signup source, plan tier, seats, trial status, and churn flag. |
| `churn_events` | 660 | 632 | Churn event records with churn date, reason code, refund amount, upgrade/downgrade context, reactivation flag, and feedback text. |
| `feature_usage` | 27,500 | 26,653 | Product feature usage logs by subscription, date, feature name, usage count, duration, errors, and beta flag. |
| `subscriptions` | 5,500 | 5,309 | Subscription lifecycle data including plan tier, dates, seats, MRR/ARR, trial status, billing, renewal, and churn indicators. |
| `support_tickets` | 2,200 | 1,996 | Support ticket records with submitted/closed timestamps, resolution time, priority, response time, satisfaction, and escalation flag. |

## Notes

- Cleaned files keep the same core schema as the raw files so downstream notebooks, dashboards, and models can use consistent column names.
- Row count reductions come from duplicate removal and issue handling documented in `../ETL/etl1_clean.ipynb`.
- Use the cleaned datasets for analysis, dashboards, and modeling unless the task is specifically about data quality comparison.
