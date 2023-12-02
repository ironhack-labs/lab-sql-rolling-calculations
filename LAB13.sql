-- 1. Get number of monthly active customers.
select date_format(payment_date, '%Y-%m') as date_wra, count(payment_date) as active_users
from sakila.payment
group by 1;

-- 2. Active users in the previous month.
with cte_prev_month as (
	select date_format(payment_date, '%Y-%m') as date_wra, count(payment_date) as active_users
	from sakila.payment
	group by 1)
select date_wra, active_users, 
		(active_users - lag(active_users,1) over (order by date_wra))as comparison
from cte_prev_month;

-- 3. Percentage change in the number of active customers.
with cte_prev_month as (
	select date_format(payment_date, '%Y-%m') as date_wra, count(payment_date) as active_users
	from sakila.payment
	group by 1)
select date_wra, active_users, 
		(active_users - lag(active_users,1) over (order by date_wra))as comparison,
		concat(round((active_users - lag(active_users,1) over (order by date_wra))/active_users *100), ' %') as '%variation'	
from cte_prev_month;

-- 4. Retained customers every month.

with cte_retained_customer as(
			select *, date_format(payment_date, '%Y-%m') as date_wra from sakila.payment)
select p1.date_wra, count(distinct p1.customer_id) as retained_customers
from cte_retained_customer as p1
inner join cte_retained_customer p2
on p1.customer_id=p2.customer_id and p1.date_wra=p2.date_wra
group by 1 order by 1;
