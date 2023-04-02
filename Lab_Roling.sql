#1 - Get number of monthly active customers.

select distinct
	date_format(convert(r.rental_date,date),'%m') as activity_month,
    monthname(r.rental_date) AS name_activity_month,
    count(r.customer_id) as active_users
from sakila.rental r
group by activity_month
order by activity_month
;

# 2 - Active users in the previous month.

select distinct
	date_format(convert(r.rental_date,date),'%m') as activity_month,
    count(r.customer_id) as active_users,
    lag (count(r.customer_id),1) over( order by date_format(convert(r.rental_date,date),'%m')) as Last_month
from sakila.rental r
group by activity_month
order by activity_month
;

#3 - Percentage change in the number of active customers.

with cte_customer as (
select distinct
	date_format(convert(r.rental_date,date),'%m') as activity_month,
    count(r.customer_id) as active_users,
    lag (count(r.customer_id),1) over( order by date_format(convert(r.rental_date,date),'%m')) as Last_month
from sakila.rental r
group by activity_month
order by activity_month)

select *,
cast((active_users - Last_month)/active_users * 100 as decimal(5,2)) as Percentage 
from cte_customer
;

#4 - Retained customers every month.

with cte_user_activity as (
    select distinct
        date_format(convert(r.rental_date, date),'%Y-%m-01') as activity_month,
        r.customer_id
    from sakila.rental r
    Group by activity_month, r.customer_id
    order by activity_month
),
cte_retained_customers as (
    select
        u2.activity_month,
        count(distinct u1.customer_id) as retained_customers
    from cte_user_activity u1
    join cte_user_activity u2 on u1.customer_id = u2.customer_id and u2.activity_month = DATE_ADD(u1.activity_month, interval 1 month)
    group by activity_month
    order by activity_month
)
 select 
    *,
    lag(retained_customers,1) over() as lagged,
    retained_customers - lag(retained_customers,1) over() as diff
    from retained_customers;