-- 1. Get number of monthly active customers.

use sakila;

create or replace view user_activity as
select date_format(convert(return_date,date), '%m') as Activity_Month_number, 
count(*) as active_users
from sakila.rental
group by Activity_Month_number
order by Activity_Month_number
;

select * from user_activity;

-- 2. Active users in the previous month.
-- use lag 
with cte_view as (
select 
    Activity_Month_number,
    active_users,
    lag(active_users,1) over 
		(order by Activity_Month_number) as Last_month
from user_activity)
select  *
from cte_view;
       


-- 3. Percentage change in the number of active customers.

with cte_view as (
select 
    Activity_Month_number,
    active_users,
    lag(active_users,1) over 
		(order by Activity_Month_number) as Last_month
from user_activity)
select  *,
	(active_users - Last_month)/Active_users * 100 as diff
from cte_view;

-- 4. Retained customers every month.

select Activity_Month,count(distinct customr_id) as retained_customers
from user_activity
group by 1
order by 1;

