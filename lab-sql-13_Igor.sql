Lab | SQL Rolling calculations

-- Get number of monthly active customers.

SELECT * FROM rental;
CREATE OR REPLACE VIEW monthly_active AS
SELECT 
  YEAR(rental_date) AS year,
  MONTH(rental_date) AS month,
COUNT(DISTINCT customer_id) AS monthly_active_customers
FROM sakila.rental
GROUP BY YEAR(rental_date), MONTH(rental_date)
ORDER BY year, month;

SELECT * FROM monthly_active;

-- Active users in the previous month.

WITH monthly_active AS (
SELECT 
	year, 
    month, 
    monthly_active_customers,
LAG(monthly_active_customers,1) OVER (
	order by year, month) AS previous_num_customers
FROM monthly_active
)
SELECT * FROM monthly_active;

-- Percentage change in the number of active customers.

CREATE OR REPLACE VIEW retained_lagged AS
WITH monthly_active AS (
SELECT
	year, 
    month, 
    monthly_active_customers,
LAG(monthly_active_customers, 1) OVER (
	order by year, month) AS previous_num_customers
FROM monthly_active
)
SELECT *, (monthly_active_customers - previous_num_customers)/monthly_active_customers * 100 as diff 
FROM monthly_active;

SELECT * FROM retained_lagged;

-- Retained customers every month.

SELECT
	year, 
	month, 
	(monthly_active_customers - previous_num_customers) as retained_per_month
FROM retained_lagged;