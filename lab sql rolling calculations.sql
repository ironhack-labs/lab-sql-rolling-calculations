select * from sakila.rental;

create or replace view monthly_active as
select year (rental_date) as 'year', month (rental_date) as 'month', count(distinct customer_id)as 'monthly_active_customers'
from sakila.rental
group by year (rental_date), month (rental_date)
order by  year, month;

select * from monthly_active;

with monthly_active as (
select year, month, monthly_active_customers, lag(monthly_active_customers,1) over (
	order by year, month) as 'previous_num_customers'
from monthly_active
)
select * from monthly_active;


create or replace view retained_lagged as
with monthly_active as (
select year, month, monthly_active_customers, lag(monthly_active_customers, 1) over (
	order by year, month) as 'previous_num_customers'
from monthly_active
)
select *, (monthly_active_customers - previous_num_customers)/monthly_active_customers * 100 as 'diff'
from monthly_active;

select * from retained_lagged;

select year, month, (monthly_active_customers - previous_num_customers) as 'retained_per_month'
from retained_lagged;

