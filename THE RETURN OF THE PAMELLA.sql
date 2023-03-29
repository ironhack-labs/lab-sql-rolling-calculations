use sakila;

-- 1.Get number of monthly active customers.
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

CREATE OR REPLACE VIEW rental_counts AS 
SELECT Activity_date, Activity_year, Activity_Month_number, COUNT(DISTINCT customer_id) AS active_customers 
FROM rental_dates 
GROUP BY Activity_date, Activity_year, Activity_Month_number;

select * from rental_counts;

-- 2.Active users in the previous month.
create or replace view sakila.monthly_active_users as
select
Activity_year, Activity_Month,
Activity_Month_number, count(account_id) as Active_users
from bank.user_activity
group by 1,2,3
order by 1,3;

select * from monthly_active_users;

with cte_view as(
select
	Activity_year,
    Activity_Month,
    Activity_Month_number,
    Active_users,
    lag(Active_users,1) over(
				order by Activity_year,Activity_Month_number) as Last_month
from monthly_active_users)

select *,
	Active_users - Last_month as diff from cte_view;

-- 3.Percentage change in the number of active customers.
with cte_view as(
select
	Activity_year,
    Activity_Month,
    Activity_Month_number,
    Active_users,
    lag(Active_users,1) over(
				order by Activity_year,Activity_Month_number) as Last_month
from monthly_active_users)

select *,
	(Active_users - Last_month)/Active_users * 100 as diff from cte_view;

-- 4.Retained customers every month.
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