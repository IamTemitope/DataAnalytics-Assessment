WITH customer_stats AS (
  SELECT
    u.id AS customer_id,
    u.name,
    -- Calculate tenure in months, minimum 1 month to avoid division by zero
    GREATEST(
      DATE_PART('year', AGE(CURRENT_DATE, u.date_joined)) * 12 +
      DATE_PART('month', AGE(CURRENT_DATE, u.date_joined)),
      1
    ) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    COALESCE(SUM(s.amount), 0) AS total_amount
  FROM users_customuser u
  LEFT JOIN savings_savingsaccount s ON s.owner_id = u.id
  GROUP BY u.id, u.name, u.date_joined
)
SELECT
  customer_id,
  name,
  tenure_months,
  total_transactions,
  ROUND(
    (total_transactions::numeric / tenure_months) * 12 * (total_amount * 0.001 / NULLIF(total_transactions,0)),
    2
  ) AS estimated_clv
FROM customer_stats
ORDER BY estimated_clv DESC;
