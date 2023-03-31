-- 1.Get number of monthly active customers.
CREATE OR REPLACE VIEW Monthly_active_users as
SELECT DISTINCT customer_id, convert(last_update, date) as Activity_date,
date_format(convert(return_date,date), '%M') as Activity_Month,
date_format(convert(return_date,date), '%m') as Activity_Month_number,
date_format(convert(return_date,date), '%Y') as Activity_year
FROM sakila.rental;

CREATE OR REPLACE VIEW Count_Monthly_active_users as
SELECT Activity_Month, Activity_year, COUNT(DISTINCT customer_id) as v
FROM Monthly_active_users
GROUP BY 1,2;

SELECT * FROM Count_Monthly_active_users;

-- 2.Active users in the previous month.
CREATE OR REPLACE VIEW Previous_month_active_users as
SELECT  *,
lag(Total_Monthly_active_users,1) OVER () as Prev_month
FROM Count_Monthly_active_users;

SELECT * FROM Previous_month_active_users;

-- 3.Percentage change in the number of active customers.
SELECT *,
Total_Monthly_active_users - Prev_month  /Total_Monthly_active_users  * 100 as percentage_change
FROM Previous_month_active_users;

-- 4. Retained customers every month.

CREATE OR REPLACE VIEW retained_customers as
SELECT 
	mau.Activity_Month, Count(DISTINCT mau.customer_id) as retained_customers
FROM Monthly_active_users mau
LEFT JOIN Monthly_active_users mau2 ON mau.customer_id = mau2.customer_id
    AND mau2.Activity_Month = date_add(mau.Activity_Month, INTERVAL 1 MONTH) 
GROUP BY 1
ORDER BY 1,2;

SELECT * ,
	lag(retained_customers,1) OVER () as lagged,
    Retained_customers - lag(retained_customers,1) OVER ()  as Retain_customer_month
FROM retained_customers



