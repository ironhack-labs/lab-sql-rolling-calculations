-- 1. Get number of monthly active customers.
CREATE OR REPLACE VIEW monthly_active_users as
SELECT date_format(return_date, '%m') as Month, count(DISTINCT customer_id) as Active_Customers 
FROM sakila.rental
WHERE return_date IS NOT NULL
GROUP BY Month
ORDER BY 1;
SELECT * FROM monthly_active_users;

-- 2. Active users in the previous month.
SELECT Month, Active_Customers,
		LAG(Active_Customers) OVER(ORDER BY Month) as Active_Customers_Previous_Month
FROM monthly_active_users;

-- 3. Percentage change in the number of active customers.
SELECT Month, Active_Customers,
		LAG(Active_Customers) OVER(ORDER BY Month) as Active_Customers_Previous_Month,
        ROUND((Active_Customers - LAG(Active_Customers) OVER(ORDER BY Month))*100 / Active_Customers,2) as Percentage_Change
FROM monthly_active_users;

-- 4. Retained customers every month.
SELECT 
    DATE_FORMAT(d1.payment_date,'%Y-%m') as payment_month,
    COUNT(DISTINCT d1.customer_id) AS retained_customers
FROM 
    sakila.payment d1
    JOIN sakila.payment d2
    ON d1.customer_id = d2.customer_id
        AND DATE_FORMAT(DATE_ADD(d2.payment_date, INTERVAL 1 MONTH), '%Y-%m') = DATE_FORMAT(d1.payment_date, '%Y-%m')
GROUP BY 1
ORDER BY 1;