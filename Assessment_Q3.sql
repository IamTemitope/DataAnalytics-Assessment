WITH last_transaction AS (
  SELECT
    plan_id,
    owner_id,
    MAX(transaction_date) AS last_transaction_date
  FROM savings_savingsaccount
  GROUP BY plan_id, owner_id
),

active_plans AS (
  SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE
      WHEN p.is_regular_savings = TRUE THEN 'Savings'
      WHEN p.is_a_fund = TRUE THEN 'Investment'
      ELSE 'Other'
    END AS type
  FROM plans_plan p
  WHERE p.is_deleted = FALSE
),

plan_activity AS (
  SELECT
    ap.plan_id,
    ap.owner_id,
    ap.type,
    COALESCE(lt.last_transaction_date, DATE '1970-01-01') AS last_transaction_date
  FROM active_plans ap
  LEFT JOIN last_transaction lt ON ap.plan_id = lt.plan_id
)

SELECT
  plan_id,
  owner_id,
  type,
  last_transaction_date,
  CURRENT_DATE - last_transaction_date AS inactivity_days
FROM plan_activity
WHERE last_transaction_date <= CURRENT_DATE - INTERVAL '365 days'
  AND type IN ('Savings', 'Investment')
ORDER BY inactivity_days DESC;
