CREATE OR REPLACE VIEW account_support_vw AS

SELECT
    account_id,

    COUNT(DISTINCT ticket_id) AS support_ticket_count,

    AVG(resolution_time_hours) AS avg_resolution_hours,

    AVG(first_response_time_minutes) AS avg_first_response_minutes,

    AVG(
        CASE
            WHEN satisfaction_score >= 0
            THEN satisfaction_score
        END
    ) AS avg_satisfaction_score,

    SUM(
        CASE
            WHEN escalation_flag = TRUE THEN 1
            ELSE 0
        END
    ) AS escalation_count

FROM
    'D:\GitHub\Falconstack_SaaS_Growth_Retention\data\cleaned\support_tickets_cleaned.csv'

GROUP BY
    account_id;