-- Lab | SQL Rolling calculations ---------------------------------------------------

-- In this lab, you will be using the Sakila database of movie rentals. -------------

Use sakila;

-- Instructions ---------------------------------------------------------------------

-- 1. Get number of monthly active customers. ---------------------------------------

create or replace view sakila.active_customers as
select 
	count(DISTINCT customer_id) as active_customers,
	date_format(convert(rental_date,date),'%m') as rental_month
from sakila.rental

WHERE return_date IS NOT NULL
GROUP BY rental_month
ORDER BY 1;

select * from sakila.active_customers;


-- 2. Active users in the previous month. -------------------------------------------

SELECT 
	rental_month, 
	Active_Customers,
	LAG(Active_Customers) OVER(ORDER BY rental_month) as Active_Customers_Previous_Month
FROM sakila.active_customers;

-- 3. Percentage change in the number of active customers. --------------------------

SELECT 
	rental_month, 
	Active_Customers,
	LAG(Active_Customers) OVER(ORDER BY rental_month) as Active_Customers_Previous_Month,
	ROUND((Active_Customers - LAG(Active_Customers) OVER(ORDER BY rental_month))*100 / Active_Customers,2) as Percentage_Change
FROM sakila.active_customers;

-- 4. Retained customers every month. -----------------------------------------------

SELECT 
    DATE_FORMAT(d1.payment_date,'%Y-%m') as payment_rental_month,
    COUNT(DISTINCT d1.customer_id) AS retained_customers
FROM 
    sakila.payment d1
    JOIN sakila.payment d2
    ON d1.customer_id = d2.customer_id
        AND DATE_FORMAT(DATE_ADD(d2.payment_date, INTERVAL 1 MONTH), '%Y-%m') = DATE_FORMAT(d1.payment_date, '%Y-%m')
GROUP BY 1
ORDER BY 1;
