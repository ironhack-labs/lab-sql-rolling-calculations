USE sakila;

# 1. Get number of monthly active customers.
SELECT
	date_format(rental_date,'%Y') as rental_year,
    date_format(rental_date,'%m') as rental_month,
    date_format(rental_date,'%M') as rental_month_number,
    count(distinct customer_id) as active_customers
FROM rental
GROUP BY 1,2,3
ORDER BY 1;

# 2. Active users in the previous month.
SELECT
	date_format(rental_date,'%Y') as rental_year,
    date_format(rental_date,'%m') as rental_month,
    date_format(rental_date,'%M') as rental_month_number,
    LAG(count(distinct customer_id),1) OVER (ORDER BY date_format(rental_date,'%m')) as active_customers_previous_month
FROM rental
WHERE date_format(rental_date,'%Y') = 2005
GROUP BY 1,2,3
ORDER BY 1;

# 3. Percentage change in the number of active customers.
create or replace view monthly_active_customers as
SELECT
	date_format(rental_date,'%Y-%m-01') as activity_date,
    date_format(rental_date,'%Y') as rental_year,
	date_format(rental_date,'%m') as rental_month_number,
	date_format(rental_date,'%M') as rental_month,
	count(distinct customer_id) as active_customers,
	lag(count(distinct customer_id),1) OVER () as last_month_active_customers
FROM rental
GROUP BY 1,2,3,4
ORDER BY 1;

SELECT * from monthly_active_customers;

SELECT
	rental_month_number,
    rental_month,
    active_customers,
    (active_customers - last_month_active_customers)/last_month_active_customers * 100 as Month_on_Month
FROM monthly_active_customers
WHERE rental_year = 2005
;

# 4. Retained customers every month.
create or replace view customer_activity as
SELECT
	customer_id,
	date_format(rental_date,'%Y-%m-%d') as activity_date,
    date_format(rental_date,'%Y') as rental_year,
	date_format(rental_date,'%m') as rental_month_number,
	date_format(rental_date,'%M') as rental_month
FROM rental;

SELECT * FROM customer_activity;

create or replace view distinct_customers as
SELECT
	date_format(activity_date,'%Y-%m-01') as activity_date,
    date_format(activity_date,'%Y') as rental_year,
    date_format(activity_date,'%m') as rental_month_number,
    date_format(activity_date,'%M') as rental_month,
    customer_id
FROM customer_activity;

SELECT * FROM distinct_customers;

SELECT
	dc2.activity_date,
    dc2.rental_month,
    count(distinct dc1.customer_id) as retained_customers
FROM distinct_customers dc1
JOIN distinct_customers dc2
	ON dc1.customer_id = dc2.customer_id
    AND dc2.activity_date = date_add(dc1.activity_date,INTERVAL 1 MONTH)
GROUP BY 1,2
;