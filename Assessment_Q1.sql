WITH savings_counts AS (
  SELECT
    s.owner_id,
    COUNT(DISTINCT s.plan_id) AS savings_count,
    SUM(s.confirmed_amount) AS total_savings_kobo
  FROM savings_savingsaccount s
  JOIN plans_plan p ON s.plan_id = p.id
  WHERE p.is_regular_savings = TRUE
    AND s.confirmed_amount > 0
  GROUP BY s.owner_id
),

investment_counts AS (
  SELECT
    s.owner_id,
    COUNT(DISTINCT s.plan_id) AS investment_count,
    SUM(s.confirmed_amount) AS total_investment_kobo
  FROM savings_savingsaccount s
  JOIN plans_plan p ON s.plan_id = p.id
  WHERE p.is_a_fund = TRUE
    AND s.confirmed_amount > 0
  GROUP BY s.owner_id
)

SELECT
  u.id AS owner_id,
  u.name,
  COALESCE(sc.savings_count, 0) AS savings_count,
  COALESCE(ic.investment_count, 0) AS investment_count,
  ROUND(COALESCE(sc.total_savings_kobo, 0) + COALESCE(ic.total_investment_kobo, 0)) / 100.0 AS total_deposits
FROM users_customuser u
JOIN savings_counts sc ON u.id = sc.owner_id
JOIN investment_counts ic ON u.id = ic.owner_id
WHERE sc.savings_count > 0
  AND ic.investment_count > 0
ORDER BY total_deposits DESC;
