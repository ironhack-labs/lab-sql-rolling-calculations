use sakila;
-- Get number of monthly active customers.
select * from rental;
create or replace view monthly_active as
SELECT 
  YEAR(rental_date) AS year,
  MONTH(rental_date) AS month,
  COUNT(DISTINCT customer_id) AS monthly_active_customers
FROM rental
GROUP BY YEAR(rental_date), MONTH(rental_date)
ORDER BY year, month;

select * from monthly_active;

-- Active users in the previous month.
with monthly_active as(
select year, month, monthly_active_customers,
lag(monthly_active_customers,1) over(
	order by year, month) as previous_num_customers
FROM 
    monthly_active)
SELECT * FROM monthly_active;

-- Percentage change in the number of active customers.
create or replace view retained_lagged as
with monthly_active as(
select year, month, monthly_active_customers,
lag(monthly_active_customers,1) over(
	order by year, month) as previous_num_customers
FROM 
    monthly_active)
select *, (monthly_active_customers - previous_num_customers)/monthly_active_customers * 100 as diff 
from monthly_active;

select * from retained_lagged;

-- Retained customers every month.
select 
year, month, (monthly_active_customers - previous_num_customers) as Retained_per_month
from retained_lagged;
