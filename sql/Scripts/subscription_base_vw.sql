CREATE OR REPLACE VIEW subscription_base_vw AS

SELECT
    s.subscription_id,
    s.account_id,

    a.industry,
    a.country,
    a.referral_source,

    s.plan_tier,

    a.signup_date,
    s.start_date,
    s.end_date,

    s.seats,
    s.mrr_amount,
    s.arr_amount,

    s.is_trial,
    s.churn_flag,
    s.upgrade_flag,
    s.downgrade_flag,
    s.billing_frequency,
    s.auto_renew_flag,

    CASE
        WHEN s.end_date = 'Ongoing' THEN TRUE
        ELSE FALSE
    END AS is_active

FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\subscriptions_cleaned.csv' AS s

LEFT JOIN
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\accounts_cleaned.csv' AS a

ON s.account_id = a.account_id;