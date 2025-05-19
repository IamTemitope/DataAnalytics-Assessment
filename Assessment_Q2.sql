WITH transaction_counts AS (
  SELECT
    s.owner_id,
    COUNT(*) AS total_transactions,
    -- Calculate months active (minimum 1)
    GREATEST(
      DATE_PART('year', AGE(CURRENT_DATE, MIN(s.transaction_date))) * 12 +
      DATE_PART('month', AGE(CURRENT_DATE, MIN(s.transaction_date))),
      1
    ) AS active_months
  FROM savings_savingsaccount s
  GROUP BY s.owner_id
),

customer_freq AS (
  SELECT
    owner_id,
    total_transactions,
    active_months,
    (total_transactions::numeric / active_months) AS avg_transactions_per_month,
    CASE
      WHEN (total_transactions::numeric / active_months) >= 10 THEN 'High Frequency'
      WHEN (total_transactions::numeric / active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category
  FROM transaction_counts
)

SELECT
  frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM customer_freq
GROUP BY frequency_category
ORDER BY 
  CASE frequency_category
    WHEN 'High Frequency' THEN 1
    WHEN 'Medium Frequency' THEN 2
    WHEN 'Low Frequency' THEN 3
  END;
