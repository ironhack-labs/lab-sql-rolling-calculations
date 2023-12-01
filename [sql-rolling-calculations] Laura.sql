-- 1. Get number of monthly active customers.
create or replace view sakila.customer_activity as
select 
date_format(rental_date, "%Y") as activity_year, 
date_format(rental_date, "%m") as activity_month, 
count(distinct customer_id) as active_users
from sakila.rental
group by 1, 2
order by 1, 2
;
select *
from sakila.customer_activity 
;

-- 2. Active users in the previous month.
-- Here I'm only using the year 2005 because I don't have data for January 2006
create or replace view sakila.monthly_customers as
select activity_year, 
activity_month,
active_users, 
lag(active_users, 1) over (order by activity_year, activity_month) as last_month_users
from sakila.customer_activity 
where activity_year = '2005'
;
select *
from sakila.monthly_customers 
;

-- 3. Percentage change in the number of active customers.
select
activity_year,
activity_month,
active_users,
last_month_users,
round((((active_users / last_month_users)-1)*100),2) as percentage_diff,
(active_users - last_month_users) as user_diff
from
sakila.monthly_customers
;

-- 4. Retained customers every month.
-- > Hasn't that been answered in the previous queries??

