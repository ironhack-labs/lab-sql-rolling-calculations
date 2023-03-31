# Instructions
# 1.Get number of monthly active customers.
Use sakila;

 create or replace view monthly_customer as
 Select distinct
	distinct customer_id as active_customer,
    date_format(convert(rental_date,date),'%Y-%M-%D') as Activity_date
FROM sakila.rental



