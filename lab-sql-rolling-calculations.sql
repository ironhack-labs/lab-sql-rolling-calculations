# Instructions
# 1.Get number of monthly active customers.
Use sakila;

 
 SELECT
	count(distinct customer_id) as active_customer,
    date_format(convert(rental_date,date),'%Y-%M-1') as Activity_date
FROM sakila.rental
GROUP BY Activity_date
;


-- 2.Active users in the previous month.



create or replace view user_activity as
SELECT
	customer_id,
    convert(rental_date, date) as Activity_date,
    date_format(convert(rental_date,date),'%M') as Activity_Month,
	date_format(convert(rental_date,date),'%m') as Activity_Month_number,
	date_format(convert(rental_date,date),'%Y') as Activity_Year
FROM sakila.rental;

create or replace view sakila.monthly_Active_users as (
Select Activity_Year, Activity_Month,
Activity_Month_number,count(distinct customer_id) as Active_users
FROM sakila.user_activity
group by 1,2,3
order by 1,3)
;

with cte_view as (
SELECT
	Activity_Year,
    Activity_Month,
    Activity_Month_number,
    Active_users,
    lag(Active_users,1) over(  
				order by Activity_year,Activity_Month_number) as Last_month
	from monthly_Active_users)



-- 3.Percentage change in the number of active customers.

SELECT
	*,
    (Active_users - Last_month)/Active_users * 100 as Percentage_change
FROM cte_view;





-- 4.Retained customers every month.

create or replace view sakila.distinct_users as 
select distinct
	date_format(convert(Activity_date,date),'%Y-%m-01') as Activity_Month,
    customer_id
    From sakila.user_activity;
    
    
 create or replace view retained_customers as   
 SELECT   
     d2.Activity_Month,
    count(distinct d1.customer_id) as Retained_customers
    from distinct_users d1
	join distinct_users d2 on d1.customer_id = d2.customer_id and d2.Activity_Month = date_add(d1.Activity_Month, INTERVAL 1 MONTH)
    group by 1
    order by 1,2;
    
    
    
    SELECT 
    *,
    lag(Retained_customers,1) over() as lagged,
    Retained_customers - lag(Retained_customers,1) over() as diff
    FROM retained_customers
    
    
    







