--CREATE OR REPLACE VIEW subscription_tbl AS
WITH raw_subscriptions AS (
SELECT
    s.* EXCLUDE (
        is_trial,
        upgrade_flag,
        downgrade_flag,
        churn_flag,
        auto_renew_flag,
        end_date,
        start_date
    ),
    COALESCE(
        TRY_CAST(s.start_date AS DATE),
        CAST(TRY_STRPTIME(CAST(s.start_date AS VARCHAR), '%d-%m-%Y') AS DATE)
    ) AS start_date,
    COALESCE(
        TRY_CAST(s.end_date AS DATE),
        CAST(TRY_STRPTIME(CAST(s.end_date AS VARCHAR), '%d-%m-%Y') AS DATE)
    ) AS end_date,
    CASE
        WHEN s.end_date = 'Ongoing' THEN 'Ongoing'
        WHEN s.end_date = 'Unknown' THEN 'Unknown'
        WHEN COALESCE(
            TRY_CAST(s.end_date AS DATE),
            CAST(TRY_STRPTIME(CAST(s.end_date AS VARCHAR), '%d-%m-%Y') AS DATE)
        ) IS NOT NULL THEN 'Ended'
        ELSE 'Unknown'
    END AS end_date_status,
    CASE
        WHEN UPPER(CAST(s.is_trial AS VARCHAR)) = 'TRUE' THEN 'T'
        WHEN UPPER(CAST(s.is_trial AS VARCHAR)) = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS is_trial,
    CASE
        WHEN UPPER(CAST(s.upgrade_flag AS VARCHAR)) = 'TRUE' THEN 'T'
        WHEN UPPER(CAST(s.upgrade_flag AS VARCHAR)) = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS upgrade_flag,
    CASE
        WHEN UPPER(CAST(s.downgrade_flag AS VARCHAR)) = 'TRUE' THEN 'T'
        WHEN UPPER(CAST(s.downgrade_flag AS VARCHAR)) = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS downgrade_flag,
    CASE
        WHEN UPPER(CAST(s.churn_flag AS VARCHAR)) = 'TRUE' THEN 'T'
        WHEN UPPER(CAST(s.churn_flag AS VARCHAR)) = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS churn_flag,
    CASE
        WHEN UPPER(CAST(s.auto_renew_flag AS VARCHAR)) = 'TRUE' THEN 'T'
        WHEN UPPER(CAST(s.auto_renew_flag AS VARCHAR)) = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS auto_renew_flag,
    ROW_NUMBER() OVER (
        PARTITION BY s.subscription_id
        ORDER BY
            CASE
                WHEN COALESCE(
                    TRY_CAST(s.end_date AS DATE),
                    CAST(TRY_STRPTIME(CAST(s.end_date AS VARCHAR), '%d-%m-%Y') AS DATE)
                ) IS NOT NULL THEN 1
                WHEN s.end_date = 'Ongoing' THEN 2
                WHEN s.end_date = 'Unknown' THEN 3
                ELSE 4
            END,
            COALESCE(
                TRY_CAST(s.start_date AS DATE),
                CAST(TRY_STRPTIME(CAST(s.start_date AS VARCHAR), '%d-%m-%Y') AS DATE)
            ) DESC
    ) AS row_num
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s
)

SELECT
    * EXCLUDE (row_num)
FROM
    raw_subscriptions
WHERE
    row_num = 1;
