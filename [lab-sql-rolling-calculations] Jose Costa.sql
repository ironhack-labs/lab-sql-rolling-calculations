#1. Get number of monthly active customers.
use sakila;

select * from customer;

select * from rental;

create or replace view rental_dates as
select rental_id, customer_id,
date_format(convert(rental_date, date),"%Y-%m-01") as Activity_date,
date_format(convert(rental_date, date), '%M') as Activity_Month,
date_format(convert(rental_date, date), '%m') as Activity_Month_number,
date_format(convert(rental_date, date), '%Y') as Activity_year
from rental
order by Activity_year, Activity_Month_number;

select * from rental_dates;

create or replace view rental_counts as 
select Activity_date, Activity_year, Activity_Month_number, count(distinct customer_id) as active_customers 
from rental_dates 
group by Activity_year, Activity_Month_number;

select * from rental_counts;

#2. Active users in the previous month.
select *, 
	lag(active_customers,1) over () as active_customers_prev_month
from rental_counts;

#3. Percentage change in the number of active customers.
with cte_compare as (select *, 
	lag(active_customers,1) over () as active_customers_prev_month
from rental_counts)

select
	Activity_year,
    Activity_month_number,
    ((active_customers-active_customers_prev_month)/active_customers)*100 as percentage_change
from cte_compare;

#4. Retained customers every month.
create or replace view retained_customers as
select 
	r2.Activity_date,
    count(distinct r1.customer_id) as retained_customers
from rental_dates r1
join rental_dates r2
	on r1.customer_id=r2.customer_id
    and r2.Activity_date = date_add(r1.Activity_date, interval 1 month)
group by 1
order by 1,2;

select * from retained_customers;