-- 1. Get number of monthly active customers.
create or replace view sakila.monthly_active_customer as
select date_format(payment_date, '%Y-%m') as active_dates, count(payment_date) as active_dates
from sakila.payment
group by 1;

select * from sakila.monthly_active_customer;


-- 2. Active users in the previous month.
with cte_prev_month as (
	select active_dates, active_customer
    from sakila.monthly_active_customer)
select cte.active_dates as last_date, cte.active_customer as active_customers
from cte_prev_month cte
where cte.active_dates = (select max(active_dates) from cte_prev_month);


-- 3. Percentage change in the number of active customers.
with cte_retain as (
    select max(active_dates) as last_date
    from sakila.monthly_active_customer
)
select active_dates, active_customer,
(active_customer - lag(active_customer,1) over (order by active_dates))as comparison,
concat(round(((active_customer - lag(active_customer,1) over (order by active_dates)) / lag(active_customer,1) over (order by active_dates) * 100),2),"%") as percentage_change
from sakila.monthly_active_customer;

-- 4. Retained customers every month.
with cte_retained_customer as(
	select *, date_format(payment_date, '%Y-%m') as active_dates from sakila.payment)
select p1.active_dates, count(distinct p1.customer_id) as retained_customers
from cte_retained_customer as p1
inner join cte_retained_customer p2
on p1.customer_id=p2.customer_id and p1.active_dates<>p2.active_dates
group by 1 order by 1;