# Excel Workbook

This folder contains the Excel workbook used to summarize data cleaning results and communicate data quality improvements.

## File

| File | Description |
| --- | --- |
| `data_cleaning_dashboard.xlsx` | Workbook containing source/cleaned table views, data quality metrics, supporting chart sheets, and the final dashboard. |

## Workbook Structure

The workbook includes table-specific sheets for accounts, churn events, feature usage, subscriptions, and support tickets, plus supporting sheets for quality metrics:

- `Completeness Scores`
- `Unclean Completeness`
- `Uniqueness`
- `Validity`
- `Issue Reduction`
- `KPI Metrics`
- `Final Data Quality`
- `Issues Resolved Chart`
- `Completeness Graph`
- `Row Retention Graph`
- `Data Cleaning Dashboard`

## Data Cleaning Dashboard

The `Data Cleaning Dashboard` sheet is the main deliverable in this workbook. It summarizes the quality outcome after cleaning across the project tables.

![Data cleaning dashboard](assets/data_cleaning_dashboard.png)

Dashboard highlights:

| Metric | Dashboard Value |
| --- | ---: |
| Completeness | 100.0% |
| Uniqueness | 100.0% |
| Validity | 62.7% |
| Issue Reduction | 100.0% |

Important dashboard sections:

- **Completeness Improvement Across Tables** compares before/after completeness for Accounts, Churn Events, Features Usage, Subscriptions, and Support Tickets.
- **Issues Resolved During Cleaning by Table** shows the number of documented cleaning issue types addressed for each table.
- **Row Cleaning Affecting Row Retention** shows before, after, and removed row counts for each table.
- **Final Data Quality Score** compares the final quality score across the cleaned tables.

## Notes

- The dashboard image in `assets/data_cleaning_dashboard.png` was exported directly from the workbook dashboard sheet.
- The workbook is intended as a presentation layer for the cleaning process, while the cleaned CSVs in `../data/cleaned/` remain the main analysis-ready data source.
