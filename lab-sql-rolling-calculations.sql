create or replace view sakila.monthly_active_users as
select year(rental_date) as Activity_year, month(rental_date) as Activity_month, 
count(distinct customer_id) as Active_customers
from sakila.rental
group by 1,2 order by 1,2;

select * from sakila.monthly_active_users;

#database contains data from may to august 2005 and february 2006 so we'll not 
#use the data from february 2006 since there is not data available from january 2006 to compare 

with cte_view as (
select Activity_year, Activity_month, Active_customers, 
lag(Active_customers,1) over (order by Activity_year, Activity_month) as Last_month 
from sakila.monthly_active_users)
select *, (Active_customers-Last_month) as difference
from cte_view
where Activity_year=2005;

#percentage change
with cte_view as (
select Activity_year, Activity_month, Active_customers, 
lag(Active_customers,1) over (order by Activity_year, Activity_month) as Last_month 
from sakila.monthly_active_users)
select *, concat(round((Active_customers-Last_month)/Last_month*100,1),'%') as rate
from cte_view
where Activity_year=2005;

create or replace view sakila.distinct_customers as
select distinct customer_id as Customer_id, 
year(rental_date) as Activity_year, month(rental_date) as Activity_month 
from sakila.rental;

select * from sakila.distinct_customers;

#retained customers
select d1.Activity_year, d1.Activity_month,
count(distinct d1.Customer_id) as Retained_customers
from sakila.distinct_customers as d1 inner join sakila.distinct_customers as d2
on d1.Customer_id = d2.Customer_id and d2.Activity_month = d1.Activity_month + 1 
group by 1,2 order by 1,2;
