SELECT
  u.id AS owner_id,
  u.name,
  COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count,
  COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count,
  COALESCE(SUM(sa.amount), 0) AS total_deposits
FROM users_customuser u
JOIN plans_plan p ON p.owner_id = u.id
  AND p.is_archived = FALSE
  AND p.is_deleted = FALSE
  AND p.amount > 0
LEFT JOIN savings_savingsaccount sa ON sa.plan_id = p.id
GROUP BY u.id, u.name
HAVING 
  COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) > 0
  AND COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) > 0
ORDER BY total_deposits DESC;
