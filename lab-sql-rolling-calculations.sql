-- 1. Get number of monthly active customers.


WITH cte_active AS (
    SELECT 
        CONVERT(p.payment_date, DATE) AS activity_date,
        c.active AS active_customers,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%Y') AS activity_year,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%M') AS activity_month,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%m') AS activity_month_number
    FROM sakila.payment p
    LEFT JOIN sakila.customer c ON p.customer_id = c.customer_id
    HAVING active_customers = 1
)
SELECT
    activity_year,
    activity_month_number,
    COUNT(active_customers) AS active_users
FROM cte_active
GROUP BY activity_year,activity_month_number;


 -- 2. Active users in the previous month.
WITH cte_active_last_month AS (
    SELECT 
        CONVERT(p.payment_date, DATE) AS activity_date,
        c.active AS active_customers,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%Y') AS activity_year,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%M') AS activity_month,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%m') AS activity_month_number
    FROM sakila.payment p
    LEFT JOIN sakila.customer c ON p.customer_id = c.customer_id
    HAVING active_customers = 1
)
SELECT
    activity_year,
    activity_month_number,
    COUNT(active_customers) AS active_users,
	LAG(count(active_customers), 1) OVER (ORDER BY activity_year, activity_month_number) AS last_month
FROM cte_active_last_month
GROUP BY activity_year,activity_month_number;

-- 3. Percentage change in the number of active customers.

WITH cte_active_last_month AS (
    SELECT 
        CONVERT(p.payment_date, DATE) AS activity_date,
        c.active AS active_customers,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%Y') AS activity_year,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%M') AS activity_month,
        DATE_FORMAT(CONVERT(p.payment_date, DATE), '%m') AS activity_month_number
    FROM sakila.payment p
    LEFT JOIN sakila.customer c ON p.customer_id = c.customer_id
    HAVING active_customers = 1
)
SELECT
    activity_year,
    activity_month_number,
    COUNT(active_customers) AS active_users,
	LAG(count(active_customers), 1) OVER (ORDER BY activity_year, activity_month_number) AS last_month,
    ROUND(((COUNT(active_customers) - LAG(COUNT(active_customers), 1) OVER (ORDER BY activity_year, activity_month_number)) 
    / LAG(COUNT(active_customers), 1) OVER (ORDER BY activity_year, activity_month_number)) * 100, 2) AS percentage_variation
FROM cte_active_last_month
GROUP BY activity_year,activity_month_number;





-- 4.Retained customers every month.
select * from sakila.customer;
select * from sakila.payment;

CREATE OR REPLACE VIEW sakila.user_activity AS
SELECT
    p.customer_id,
    DATE_FORMAT(p.payment_date, '%Y %m') AS activity_year_month
FROM sakila.payment p
LEFT JOIN sakila.customer c ON p.customer_id = c.customer_id;

WITH cte_retained_customers AS (
    SELECT
        customer_id,
        activity_year_month,
        LAG(activity_year_month) OVER (PARTITION BY customer_id ORDER BY activity_year_month) AS last_month
    FROM sakila.user_activity
)
SELECT
    activity_year_month,
    COUNT(DISTINCT customer_id) AS retained_customers_count
FROM cte_retained_customers
WHERE activity_year_month = last_month OR last_month IS NULL
GROUP BY activity_year_month
ORDER BY activity_year_month;