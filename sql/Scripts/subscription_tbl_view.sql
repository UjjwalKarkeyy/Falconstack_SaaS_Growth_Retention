CREATE VIEW subscription_tbl AS (
SELECT
    s.* EXCLUDE (is_trial,
    upgrade_flag,
    downgrade_flag,
    churn_flag,
    auto_renew_flag,
    end_date,
    start_date),
    STRFTIME(
        s.start_date, 
        '%Y-%m-%d'
        ) AS start_date,
    CASE
        WHEN s.end_date NOT IN ('Ongoing', 'Unknown')
            THEN STRFTIME(
                TRY_STRPTIME(s.end_date, '%d-%m-%Y'),
                '%Y-%m-%d'
                )
        WHEN s.end_date = 'Ongoing' THEN 'Ongoing'
        ELSE 'Unknown'
    END AS end_date,
    CASE 
        WHEN s.is_trial = 'TRUE' THEN 'T'
        WHEN s.is_trial = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS is_trial,
       CASE 
        WHEN s.upgrade_flag = 'TRUE' THEN 'T'
        WHEN s.upgrade_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS upgrade_flag,
       CASE 
        WHEN s.downgrade_flag = 'TRUE' THEN 'T'
        WHEN s.downgrade_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS downgrade_flag,
       CASE 
        WHEN s.churn_flag = 'TRUE' THEN 'T'
        WHEN s.churn_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS churn_flag,
       CASE 
        WHEN s.auto_renew_flag = 'TRUE' THEN 'T'
        WHEN s.auto_renew_flag = 'FALSE' THEN 'F'
        ELSE 'U'
    END AS auto_renew_flag,
FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s
)