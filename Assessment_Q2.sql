WITH customer_transactions AS (
  SELECT 
    owner_id,
    COUNT(*) AS total_transactions,
    DATE_TRUNC('month', MIN(transaction_date)) AS first_month,
    DATE_TRUNC('month', MAX(transaction_date)) AS last_month,
    -- Calculate number of months active, at least 1 to avoid division by zero
    GREATEST(
      EXTRACT(YEAR FROM MAX(transaction_date)) * 12 + EXTRACT(MONTH FROM MAX(transaction_date)) -
      EXTRACT(YEAR FROM MIN(transaction_date)) * 12 - EXTRACT(MONTH FROM MIN(transaction_date)) + 1,
      1
    ) AS active_months
  FROM savings_savingsaccount
  GROUP BY owner_id
),
customer_avg_transactions AS (
  SELECT
    owner_id,
    total_transactions,
    active_months,
    total_transactions::FLOAT / active_months AS avg_transactions_per_month
  FROM customer_transactions
),
customer_categories AS (
  SELECT
    owner_id,
    avg_transactions_per_month,
    CASE
      WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
      WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category
  FROM customer_avg_transactions
)
SELECT
  frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM customer_categories
GROUP BY frequency_category
ORDER BY 
  CASE frequency_category
    WHEN 'High Frequency' THEN 1
    WHEN 'Medium Frequency' THEN 2
    WHEN 'Low Frequency' THEN 3
  END;
