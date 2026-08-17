CREATE VIEW accounts_tbl AS (
SELECT
        a.* EXCLUDE (
            churn_flag,
            is_trial,
            signup_date
        ),

        CASE
            WHEN a.churn_flag = 'TRUE' THEN 'T'
        WHEN a.churn_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS churn_flag,

        CASE
            WHEN a.is_trial = 'TRUE' THEN 'T'
        WHEN a.is_trial = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS is_trial,

        CAST(a.signup_date AS DATE) AS signup_date,

        CASE
            WHEN c.churn_date IS NOT NULL
            THEN CAST(c.churn_date AS DATE)
        ELSE NULL
    END AS churn_date
FROM
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a
LEFT JOIN
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\churn_events_cleaned.csv' AS c
        ON
    a.account_id = c.account_id
)