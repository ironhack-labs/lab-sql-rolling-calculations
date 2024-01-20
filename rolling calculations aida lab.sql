-- 1 Get number of monthly active customers.
-- 2 Active users in the previous month.
-- 3 Percentage change in the number of active customers.
-- 4 Retained customers every month.

use sakila;

-- 1
SELECT customer_id, active,SUM(active) OVER (PARTITION BY customer_id ORDER BY MONTH(19/01/2024)) AS monthly_active_customers
FROM sakila.customer;

-- 2
SELECT active, customer_id, CONCAT(first_name, ' ', last_name) AS full_name,
  LAG(active) OVER (PARTITION BY customer_id ORDER BY first_name) AS active_previous_month
FROM sakila.customer;

-- 3
SELECT customer_id, active, LAG(active) OVER (ORDER BY last_update) AS previous_active,
ROUND(((active - LAG(active) OVER (ORDER BY last_update)) / LAG(active) OVER (ORDER BY last_update)) * 100, 2) AS percentage_change
FROM sakila.customer;

-- 4
WITH CustomerRetention AS (
  SELECT
    customer_id,
    last_update,
    active,
    LAG(active) OVER (PARTITION BY customer_id ORDER BY last_update) AS previous_active
  FROM sakila.customer
)
SELECT
  customer_id,
  last_update,
  CASE
    WHEN previous_active = 1 AND active = 1 THEN 'Retained'
    ELSE 'Not Retained'
  END AS retention_status
FROM CustomerRetention;

-- EXTRA --
-- . Analyze Seasonal Rental Trends:
-- Objective: Identify trends in rental frequency based on months.
SELECT
  MONTHNAME(MIN(rental_date)) AS rental_month,
  COUNT(*) AS rental_count
FROM rental
GROUP BY MONTH(rental_date)
ORDER BY MONTH(rental_date);

-- . Genre Preference Analysis:
-- .. Objective: Determine the top 5 popular film genre among high-spending customers.
WITH CustomerSpending AS (
  SELECT
    c.customer_id,
    SUM(p.amount) AS total_spent
  FROM customer c
  JOIN payment p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id
  HAVING total_spent > 0
)
SELECT
  c.name AS genre,
  COUNT(cs.customer_id) AS customer_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN CustomerSpending cs ON r.customer_id = cs.customer_id
GROUP BY c.name
ORDER BY customer_count DESC
LIMIT 5;
-- .. Objective: Determine the favorite genres of high-value customers.
WITH CustomerSpending AS (
  SELECT
    c.customer_id,
    SUM(p.amount) AS total_spent
  FROM customer c
  JOIN payment p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id
  HAVING total_spent > 0
)
SELECT
  c.name AS genre,
  COUNT(cs.customer_id) AS customer_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN CustomerSpending cs ON r.customer_id = cs.customer_id
GROUP BY c.name
ORDER BY customer_count DESC;

-- . Rental Duration Patterns:
-- Objective: Identify patterns in rental duration preferences among customers.
WITH RentalPatterns AS (
  SELECT
    c.customer_id,
    AVG(DATEDIFF(return_date, rental_date)) AS average_rental_duration
  FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
  WHERE return_date IS NOT NULL
  GROUP BY c.customer_id
)
SELECT
  customer_id,
  average_rental_duration
FROM RentalPatterns
ORDER BY average_rental_duration DESC;

-- . Movie Recommendation
-- Objective: Write a query that will recommend a movie by looking at the customers favorite genre and recommending the most rented film in that genre. 
WITH CustomerFavoriteGenre AS (
  SELECT
    c.customer_id,
    cg.name AS favorite_genre,
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY COUNT(*) DESC) AS row_num
  FROM customer c
  JOIN rental r ON c.customer_id = r.customer_id
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film f ON i.film_id = f.film_id
  JOIN film_category fc ON f.film_id = fc.film_id
  JOIN category cg ON fc.category_id = cg.category_id
  GROUP BY c.customer_id, cg.name
)
SELECT
  cfg.customer_id,
  cfg.favorite_genre,
  f.title AS most_rented_movie
FROM CustomerFavoriteGenre cfg
JOIN film_category fc ON cfg.favorite_genre = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.customer_id = cfg.customer_id AND cfg.row_num = 1
ORDER BY cfg.customer_id;

-- . Identify movies that needs more copies:
-- Objective: Find movies that have had all their copies rented at least once and count how many times it happened.
WITH MovieRentals AS (
  SELECT
    i.film_id,
    COUNT(DISTINCT r.rental_id) AS rental_count
  FROM inventory i
  LEFT JOIN rental r ON i.inventory_id = r.inventory_id
  GROUP BY i.film_id
),
MovieCopies AS (
  SELECT
    i.film_id,
    COUNT(DISTINCT i.inventory_id) AS copy_count
  FROM inventory i
  GROUP BY i.film_id
)
SELECT
  mc.film_id,
  COUNT(*) AS fully_rented_count
FROM MovieRentals mr
JOIN MovieCopies mc ON mr.film_id = mc.film_id
WHERE mr.rental_count >= mc.copy_count
GROUP BY mc.film_id
ORDER BY fully_rented_count DESC;
