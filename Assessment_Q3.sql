WITH last_transactions AS (
  SELECT 
    plan_id,
    MAX(transaction_date)::date AS last_transaction_date
  FROM savings_savingsaccount
  GROUP BY plan_id
)
SELECT
  p.id AS plan_id,
  p.owner_id,
  CASE 
    WHEN p.plan_type_id = 1 THEN 'Savings'
    WHEN p.plan_type_id = 2 THEN 'Investment'
    ELSE 'Other'
  END AS type,
  COALESCE(lt.last_transaction_date, p.created_on::date) AS last_transaction_date,
  (CURRENT_DATE - COALESCE(lt.last_transaction_date, p.created_on::date)) AS inactivity_days
FROM plans_plan p
LEFT JOIN last_transactions lt ON p.id = lt.plan_id
WHERE p.is_deleted = FALSE
  AND p.status_id = 1   
  AND (CURRENT_DATE - COALESCE(lt.last_transaction_date, p.created_on::date)) > 365
ORDER BY inactivity_days DESC;
