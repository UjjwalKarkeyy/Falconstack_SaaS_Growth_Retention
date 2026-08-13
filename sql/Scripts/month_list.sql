-- create the list of months
CREATE VIEW mnths_list AS (
SELECT
    DISTINCT
        DATE_TRUNC('month', signup_date) AS mnth
FROM
    (
    SELECT
        CAST(a.signup_date AS DATE) AS signup_date
    FROM
        'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a
)
ORDER BY
    DATE_TRUNC('month', signup_date)
)