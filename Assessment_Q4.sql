WITH user_tenure AS (
  SELECT
    u.id AS customer_id,
    u.name,
    GREATEST(
      DATE_PART('year', AGE(CURRENT_DATE, u.date_joined)) * 12 +
      DATE_PART('month', AGE(CURRENT_DATE, u.date_joined)),
      1
    ) AS tenure_months
  FROM users_customuser u
),

user_transactions AS (
  SELECT
    s.owner_id,
    COUNT(*) AS total_transactions,
    SUM(s.confirmed_amount) AS total_inflow_kobo,
    SUM(s.amount_withdrawn) AS total_outflow_kobo
  FROM savings_savingsaccount s
  JOIN plans_plan p ON s.plan_id = p.id
  WHERE p.is_regular_savings = TRUE OR p.is_a_fund = TRUE
  GROUP BY s.owner_id
),

clv_calc AS (
  SELECT
    ut.customer_id,
    ut.name,
    ut.tenure_months,
    COALESCE(utx.total_transactions, 0) AS total_transactions,
    COALESCE((utx.total_inflow_kobo - utx.total_outflow_kobo)/100.0, 0) AS net_amount_currency
  FROM user_tenure ut
  LEFT JOIN user_transactions utx ON ut.customer_id = utx.owner_id
)

SELECT
  customer_id,
  name,
  tenure_months,
  total_transactions,
  ROUND(
    (total_transactions::numeric / tenure_months) * 12 * 
    CASE
      WHEN total_transactions > 0 THEN (net_amount_currency / total_transactions) * 0.001
      ELSE 0
    END,
    2
  ) AS estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;
