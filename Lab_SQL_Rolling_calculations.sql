
-- Get number of monthly active customers.
--


create or replace view sakila.cust_activity as 
select customer_id,
convert(payment_date,date) as Activity_date,
date_format(convert(payment_date,date), '%Y') as activity_year,
date_format(convert(payment_date,date), '%m') as activity_month
from sakila.payment;

select * from sakila.cust_activity;

create or replace view sakila.cust_count_active as 
select Activity_month,activity_year, count(distinct customer_id) as nb_cust_active
from sakila.cust_activity
group by 2,1  order by activity_year desc ;

 -- Active users in the previous month.
select * from sakila.cust_count_active;

with cte_view as (
select 
Activity_month,activity_year,nb_cust_active,
lag(nb_cust_active,1) over(order by Activity_year, Activity_month) as Last_month
from sakila.cust_count_active
)
select
Activity_year,
Activity_month,
nb_cust_active,
last_month,
(nb_cust_active - Last_month) as difference
from cte_view;

create or replace view sakila.difference as 
with cte_view as (
select 
Activity_month,activity_year,nb_cust_active,
lag(nb_cust_active,1) over(order by Activity_year, Activity_month) as Last_month
from sakila.cust_count_active
)
select
Activity_year,
Activity_month,
nb_cust_active,
last_month,
(nb_cust_active - Last_month) as difference
from cte_view;

select * from sakila.difference;

-- Percentage change in the number of active customers.

create or replace view sakila.percent_cust as 
select 
Activity_year,
Activity_month,
nb_cust_active,
last_month,
difference,
(((nb_cust_active / last_month)-1)*100) as percentage_cust_diff_percent
from sakila.difference;

select * from sakila.percent_cust;

-- Retained customers every month.
-- I calculate the percent of customer retained everymonth and give proper name to the column

select 
Activity_year,
Activity_month,
nb_cust_active,
last_month as Retained_cust_every_month,
difference,
percentage_cust_diff_percent,
(nb_cust_active /last_month  * 100) as retained_customer_percent
from sakila.percent_cust;
