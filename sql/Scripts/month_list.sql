--CREATE OR REPLACE VIEW mnths_list AS
SELECT DISTINCT
    CAST(DATE_TRUNC('month', month_date) AS DATE) AS mnth
FROM (
    SELECT
        signup_date AS month_date
    FROM
        accounts_tbl

    UNION

    SELECT
        start_date AS month_date
    FROM
        subscription_tbl

    UNION

    SELECT
        end_date AS month_date
    FROM
        subscription_tbl
    WHERE
        end_date IS NOT NULL
)
WHERE
    month_date IS NOT NULL
ORDER BY
    mnth;
