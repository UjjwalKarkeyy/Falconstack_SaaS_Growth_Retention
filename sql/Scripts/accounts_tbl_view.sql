--CREATE OR REPLACE VIEW accounts_tbl AS
WITH accounts_base AS (
SELECT
    a.account_id,
    a.account_name,
    a.industry,
    a.country,
    a.referral_source,
    a.plan_tier,
    a.seats,
    COALESCE(
        TRY_CAST(a.signup_date AS DATE),
        CAST(TRY_STRPTIME(CAST(a.signup_date AS VARCHAR), '%d-%m-%Y') AS DATE)
    ) AS signup_date,
    MAX(
        CASE
            WHEN UPPER(CAST(a.churn_flag AS VARCHAR)) = 'TRUE' THEN 1
            WHEN UPPER(CAST(a.churn_flag AS VARCHAR)) = 'FALSE' THEN 0
            ELSE NULL
        END
    ) AS churn_flag_value,
    MAX(
        CASE
            WHEN UPPER(CAST(a.is_trial AS VARCHAR)) = 'TRUE' THEN 1
            WHEN UPPER(CAST(a.is_trial AS VARCHAR)) = 'FALSE' THEN 0
            ELSE NULL
        END
    ) AS is_trial_value
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a
GROUP BY
    a.account_id,
    a.account_name,
    a.industry,
    a.country,
    a.referral_source,
    a.plan_tier,
    a.seats,
    COALESCE(
        TRY_CAST(a.signup_date AS DATE),
        CAST(TRY_STRPTIME(CAST(a.signup_date AS VARCHAR), '%d-%m-%Y') AS DATE)
    )
),
churn_dates AS (
SELECT
    c.account_id,
    MAX(
        COALESCE(
            TRY_CAST(c.churn_date AS DATE),
            CAST(TRY_STRPTIME(CAST(c.churn_date AS VARCHAR), '%d-%m-%Y') AS DATE)
        )
    ) AS churn_date
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\churn_events_cleaned.csv' AS c
GROUP BY
    c.account_id
)

SELECT
    a.* EXCLUDE (
        churn_flag_value,
        is_trial_value
    ),
    CASE
        WHEN a.churn_flag_value = 1 THEN 'T'
        WHEN a.churn_flag_value = 0 THEN 'F'
        ELSE 'U'
    END AS churn_flag,
    CASE
        WHEN a.is_trial_value = 1 THEN 'T'
        WHEN a.is_trial_value = 0 THEN 'F'
        ELSE 'U'
    END AS is_trial,
    c.churn_date
FROM
    accounts_base AS a
LEFT JOIN churn_dates AS c
    ON
    a.account_id = c.account_id;

