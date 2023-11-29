-- 1) Getting number of monthly active customers
select date_format(rental_date, "%Y") as activity_year, date_format(rental_date, "%m") as activity_month, count(distinct customer_id) as active_users
from sakila.rental
group by 1, 2
order by 1, 2;

-- 2) Active users in the previous month
-- Since there is a jump from August 2005 to February 2006, I'm going to ignore that last month (February 2006) because there is no information about its previous month (January 2006)
select activity_year, activity_month, lag(active_users, 1) over (order by activity_year, activity_month) as last_month_active_users
from (
select date_format(rental_date, "%Y") as activity_year, date_format(rental_date, "%m") as activity_month, count(distinct customer_id) as active_users
from sakila.rental
group by 1, 2
order by 1, 2
) sub1
where activity_year = 2005;

-- 3) Percentage change in the number of active customers
select activity_year, activity_month, active_users, last_month_active_users, 100*(active_users - last_month_active_users)/last_month_active_users as percentage_change_of_active_customers
from (
select activity_year, activity_month, active_users, lag(active_users, 1) over (order by activity_year, activity_month) as last_month_active_users
from (
select date_format(rental_date, "%Y") as activity_year, date_format(rental_date, "%m") as activity_month, count(distinct customer_id) as active_users
from sakila.rental
group by 1, 2
order by 1, 2
) sub1
where activity_year = 2005
) sub2;

-- 4) Retained customers every month
select d1.activity_year, d1.activity_month, count(distinct d1.customer_id) as retained_customers
from (
select distinct customer_id, date_format(rental_date, "%Y") as activity_year, date_format(rental_date, "%m") as activity_month
from sakila.rental
where date_format(rental_date, "%Y") = 2005
) as d1
inner join (
select distinct customer_id, date_format(rental_date, "%Y") as activity_year, date_format(rental_date, "%m") as activity_month
from sakila.rental
where date_format(rental_date, "%Y") = 2005
) as d2 on (d1.customer_id = d2.customer_id and d2.activity_month = d1.activity_month + 1) 
group by 1,2
order by 1,2;