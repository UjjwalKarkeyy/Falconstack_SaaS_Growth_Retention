# SQL Analysis Layer

This folder contains the SQL used to turn the cleaned FalconStack SaaS dataset into retention, revenue, concentration, and unit-economics metrics. The scripts are organized as a lightweight analytics layer on top of the cleaned CSV files in `data/cleaned`.

The SQL is written in a DuckDB-friendly style. It reads CSV files directly from disk, normalizes key fields, and then builds reusable views for downstream analysis, dashboards, and metric exports. Several scripts include `CREATE OR REPLACE VIEW` statements that are currently commented out; uncomment those lines when you want to persist each query as a DuckDB view.

## Folder Structure

```text
sql/
  README.md
  Scripts/
    accounts_tbl_view.sql
    subscription_tbl_view.sql
    month_list.sql
    customer_metrics.sql
    retention_metrics.sql
    revenue_metrics.sql
    revenue_retention_metrics.sql
    revenue_concentration.sql
    unit_economics.sql
```

## Data Sources

The base scripts read from cleaned CSV files under:

```text
data/cleaned/accounts_cleaned.csv
data/cleaned/churn_events_cleaned.csv
data/cleaned/subscriptions_cleaned.csv
```

The current SQL uses absolute Windows paths pointing to this repository location:

```text
D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\
```

If the project is moved to another machine or folder, update those paths in `accounts_tbl_view.sql` and `subscription_tbl_view.sql`, or replace them with paths relative to your DuckDB working directory.

## Recommended Execution Order

Run the scripts in dependency order. The later metric scripts depend on the base account, subscription, and month-list views.

1. `accounts_tbl_view.sql`
2. `subscription_tbl_view.sql`
3. `month_list.sql`
4. `customer_metrics.sql`
5. `retention_metrics.sql`
6. `revenue_metrics.sql`
7. `revenue_retention_metrics.sql`
8. `revenue_concentration.sql`
9. `unit_economics.sql`

For persistent views, uncomment the `CREATE OR REPLACE VIEW ... AS` line at the top of each query block before running it. If left commented, the scripts still return query results, but they will not create named views for later scripts to reference.

## Base Views

### `accounts_tbl_view.sql`

Builds the account-level foundation view from cleaned account and churn-event data.

Key work performed:

- Reads `accounts_cleaned.csv`.
- Parses `signup_date` into a proper date.
- Converts boolean-like fields into compact status values:
  - `T` for true
  - `F` for false
  - `U` for unknown or unparseable
- Deduplicates account rows through grouped account attributes.
- Reads `churn_events_cleaned.csv` and attaches the latest churn date per account.

Expected output view:

```text
accounts_tbl
```

This view is the main customer dimension used by retention and customer-count metrics.

### `subscription_tbl_view.sql`

Builds the subscription-level foundation view from cleaned subscription data.

Key work performed:

- Reads `subscriptions_cleaned.csv`.
- Parses `start_date` and `end_date`.
- Preserves special end-date states such as `Ongoing` and `Unknown`.
- Creates an `end_date_status` field with values like `Ongoing`, `Unknown`, and `Ended`.
- Converts trial, upgrade, downgrade, churn, and auto-renew flags into `T`, `F`, or `U`.
- Deduplicates records by `subscription_id`, keeping the preferred row based on end-date quality and latest start date.

Expected output view:

```text
subscription_tbl
```

This view is the main recurring-revenue fact table used by MRR, ARR, NRR, GRR, ARPU, LTV, and concentration metrics.

### `month_list.sql`

Creates a reusable monthly date spine from all meaningful account and subscription dates.

Expected output view:

```text
mnths_list
```

The month list is used to calculate monthly customer counts, retention, churn, MRR movement, ARPU, and LTV consistently across the project.

## Metric Scripts

### `customer_metrics.sql`

Calculates monthly customer base size and customer growth rate.

Expected output view:

```text
customer_growth_vw
```

Main fields:

- `mnth`
- `total_cus`
- `prev_mnth_total`
- `customer_growth_rate`

The script counts customers active at the end of each month and compares the count with the prior month. The notes in the script indicate that customer growth began decreasing after August 2024.

### `retention_metrics.sql`

Calculates customer retention and churn behavior from several angles.

Expected output views:

```text
customer_retention_rate_vw
customer_churn_rate_vw
early_churn_rate_vw
cohort_retention_vw
```

Metrics covered:

- Customer retention rate (CRR)
- Customer churn rate
- Early-stage churn within 30 days of signup
- Cohort retention at 30 and 90 days

The script highlights a major retention deterioration in late 2024. December 2024 shows the sharpest customer retention decline, with churn rising materially from November to December. Early churn is also called out as a problem, especially for customers leaving within 30 days of signup.

### `revenue_metrics.sql`

Calculates core recurring-revenue metrics.

Expected output views:

```text
total_arr_vw
revenue_growth_rate_vw
expansion_revenue_rate_vw
contraction_revenue_rate_vw
```

Metrics covered:

- Total ARR
- Monthly recurring revenue trend
- Revenue growth rate
- Expansion revenue rate
- Contraction revenue rate

The script uses MRR as the recurring-revenue proxy because the dataset does not include recognized or billed revenue. It also compares October and November 2024 upgrade and downgrade movement, showing weaker expansion activity and lower contraction revenue over that period.

### `revenue_retention_metrics.sql`

Calculates revenue retention quality using MRR movement components.

Expected output views:

```text
mrr_components_vw
nrr_grr_vw
```

Metrics covered:

- Starting MRR
- Expansion MRR
- Contraction MRR
- Churned MRR
- Net Revenue Retention (NRR)
- Gross Revenue Retention (GRR)

The script compares October and November 2024. The notes indicate that both NRR and GRR declined slightly, with NRR remaining below 100%. That means expansion MRR did not fully offset revenue lost to contraction and churn.

### `revenue_concentration.sql`

Calculates account-level active ARR and top-customer revenue concentration.

Expected output views:

```text
total_arr_per_account_vw
top_5_revenue_share_vw
revenue_concentration_vw
```

Metrics covered:

- Active ARR by account
- Top 5 customer revenue share
- Total top-5 concentration percentage

The script notes that the top 5 customers account for about 5.07% of active ARR, suggesting low revenue concentration risk and limited dependency on a small number of accounts.

### `unit_economics.sql`

Calculates ARPU and LTV using active MRR, active customer counts, and churn rate.

Expected output view:

```text
arpu_ltv_vw
```

Metrics covered:

- Monthly active MRR
- Active customer count
- Average revenue per user/account (ARPU)
- Customer lifetime value (LTV)
- Customer churn rate

The script shows that MRR and active customers grew strongly through much of 2024, then weakened late in the year. ARPU continued to rise because the remaining customer base had higher average value, but LTV dropped as churn increased.

## How To Run

One straightforward way to run the scripts is through the DuckDB CLI:

```powershell
duckdb falconstack.duckdb
```

Then run each script in order:

```sql
.read sql/Scripts/accounts_tbl_view.sql
.read sql/Scripts/subscription_tbl_view.sql
.read sql/Scripts/month_list.sql
.read sql/Scripts/customer_metrics.sql
.read sql/Scripts/retention_metrics.sql
.read sql/Scripts/revenue_metrics.sql
.read sql/Scripts/revenue_retention_metrics.sql
.read sql/Scripts/revenue_concentration.sql
.read sql/Scripts/unit_economics.sql
```

If running from inside the `sql` directory, adjust the `.read` paths:

```sql
.read Scripts/accounts_tbl_view.sql
```

Because many of the view-creation statements are commented, decide first whether you want:

- Ad hoc query output: keep `CREATE OR REPLACE VIEW` commented.
- Reusable metric views: uncomment the matching `CREATE OR REPLACE VIEW ... AS` lines.

For dashboard work, reusable views are usually easier because later tools can query stable table-like objects instead of rerunning full scripts manually.

## Metric Interpretation Notes

The SQL analysis points to one main operating story:

- Acquisition and MRR grew through much of 2024.
- Customer growth weakened after August 2024.
- Retention worsened sharply in late 2024, especially around December.
- Early-stage churn became a major issue, meaning customers were leaving soon after signup.
- NRR stayed below 100% in October and November 2024, so expansion revenue was not enough to offset contraction and churn.
- Revenue concentration risk appears low because the top 5 accounts represent a small share of active ARR.
- ARPU increased even while customer count fell, suggesting the retained base became more valuable on average.
- Higher churn reduced LTV despite stronger ARPU.

Overall, the SQL layer supports the conclusion that FalconStack's growth issue is less about initial acquisition and more about retention durability, early customer activation, and protecting revenue quality after signup.
