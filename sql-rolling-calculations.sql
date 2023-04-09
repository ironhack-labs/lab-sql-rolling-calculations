
CREATE OR REPLACE VIEW rental_dates as
                SELECT rental_id, 
                       customer_id,
					   date_format(CONVERT(rental_date, DATE),"%Y-%m-01") AS Activity_date,
                       date_format(CONVERT(rental_date, DATE), '%M') AS Activity_Month,
					   date_format(CONVERT(rental_date, DATE), '%m') AS Activity_Month_number,
                       date_format(CONVERT(rental_date, DATE), '%Y') AS Activity_year
                FROM rental
			GROUP BY 1,2
			ORDER BY 1,2;

SELECT 
      * 
FROM rental_dates;

CREATE OR REPLACE VIEW rental_counts AS 
				SELECT Activity_date, 
                       Activity_year, 
                       Activity_Month_number, 
                       COUNT(DISTINCT customer_id) AS customers_active 
                  FROM rental_dates 
              GROUP BY 1,2,3;

SELECT
      *
FROM rental_counts;

SELECT 
      *,
      LAG(customers_active, 1) OVER () AS customers_active_prev
FROM rental_counts;

WITH cte_comparison AS (
                     SELECT 
						   *,
                           LAG(customers_active, 1) OVER () AS customers_active_prev
                     FROM rental_counts
                     )
SELECT
	  Activity_year,
      Activity_month_number,
      ((customers_active - customers_active_prev) / customers_active) * 100 AS percentage_comparison
FROM cte_comparison;


CREATE OR REPLACE VIEW retained_customers AS
                SELECT 
	                  r2.Activity_date,
					  COUNT(DISTINCT r1.customer_id) AS retained_customers
                FROM rental_dates r1
                JOIN rental_dates r2 ON r1.customer_id = r2.customer_id
                     AND r2.Activity_date = DATE_ADD(r1.Activity_date, INTERVAL 1 MONTH)
			group by 1
            order by 1,2;

SELECT 
      *
FROM retained_customers;