# SQL Queries: Approach and Insights

This document explains how I tackled each question, the reasoning behind my solutions, and some challenges I faced along the way.

---

### 1. High-Value Customers with Multiple Products

**What I did:**
I needed to find customers who have at least one savings plan and one investment plan. To do this, I checked the plans table for savings (marked by `is_regular_savings`) and investments (`is_a_fund`). Then I joined with the users table to get customer names, counted how many plans each customer had of both types, and summed up their deposits. Finally, I filtered to keep only those who had both kinds of plans.

**Why this way:**
Using filtered aggregation in one query avoids multiple joins, making the query simpler and efficient. Converting amounts from kobo to the base currency made the results easier to interpret.

---

### 2. Transaction Frequency Analysis

**What I did:**
I calculated how many transactions each customer made, how long they've been active in months, and found their average transactions per month. Based on that average, I grouped customers into "High", "Medium", and "Low" frequency categories. Then I counted how many customers fell into each category.

**Why this way:**
By using a CTE to do the heavy lifting once, the query stays readable and efficient. Also, I made sure to avoid division by zero for customers with very short activity.

---

### 3. Account Inactivity Alert

**What I did:**
I looked for accounts (both savings and investment) where there hasn’t been any transaction in over a year. To do this, I found the most recent transaction date per plan and compared it to today’s date minus 365 days. I combined both savings and investment accounts in one result set, labeling the plan type for clarity.

**Why this way:**
Combining both types with UNION ALL helps get a complete view without repeating logic. Also, filtering early on helps performance.

---

### 4. Customer Lifetime Value (CLV) Estimation

**What I did:**
I estimated each customer’s CLV by calculating how many months they’ve been active since signup, counting total transactions, and then applying a simplified formula using profit per transaction. The final results were sorted by estimated CLV, showing the highest value customers first.

**Why this way:**
I ensured no divide-by-zero issues by setting a minimum tenure of one month. Aggregating transaction values carefully while converting kobo to currency made sure the estimates were accurate.

---

### Challenges and How I Handled Them

* **Amounts stored in kobo:** All amounts were in kobo, so I had to consistently convert to standard currency units during calculations for readability.

* **Divide-by-zero risk:** When calculating averages over time, some customers had very short tenures or only one transaction date. I used safe functions like `GREATEST` to prevent errors.

* **Identifying plan types:** The plan table used multiple boolean flags to mark savings and investments. I had to be careful to filter correctly to avoid misclassifying plans.

* **Balancing clarity and performance:** I aimed to keep queries easy to understand by using CTEs and filtered aggregates, which also help with performance, but actual index tuning would help further in production.
