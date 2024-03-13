use film_rental;
show tables;

-- 1.	What is the total revenue generated from all rentals in the database? (2 Marks)

SELECT 
    SUM(amount) AS total_revenue
FROM
    payment;

-- THE TOTAL REVENUE GENERATED FROM ALL RENTALS IN THE DATABASE IS '67406.56'

-- 2.	How many rentals were made in each month_name? (2 Marks)

SELECT 
    MONTHNAME(rental_date) AS month_name,
    COUNT(*) count_of_rentals
FROM
    rental
GROUP BY 1;


-- 3.	What is the rental rate of the film with the longest title in the database? (2 Marks)

SELECT 
    rental_rate
FROM
    film
ORDER BY LENGTH(title) DESC
LIMIT 1;

-- THE RENTAL RATE OF THE FILM WITH LONGEST TITLE 'ARACHNOPHOBIA ROLLERCOASTER' IS '2.99'.

-- 4.	What is the average rental rate for films that were taken from the last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)

SELECT 
    AVG(rental_rate) AS average_rental_rate
FROM
    film f
        JOIN
    inventory i USING (film_id)
        JOIN
    rental r USING (inventory_id)
WHERE
    rental_date BETWEEN '2005-05-05 22:04:30' AND DATE_SUB('2005-05-05 22:04:30',
        INTERVAL 30 DAY);
        
 
-- THIS QUERY RETURNS THE AVERAGE RENTAL_RATE FOR THE FILMS TAKEN BETWEEN '2005-04-05 22:04:30' AND '2005-05-05 22:04:30'
-- AS '2005-04-05 22:04:30' IS THE DATE WHICH IS EXACTLY 30 DAYS BEFORE '2005-05-05 22:04:30'.HOWEVER THE OUTPUT IS A 
-- NULL TABLE SINCE THE RENTAL_DATES START FROM "2005-05-24 22:53:30". 

-- IF WE WANT TO FIND THE AVERAGE RENTAL_RATE FOR THE FILMS TAKEN BETWEEN THE INTERVAL OF '2005-05-05 22:04:30' AND 
-- 30 DAYS AFTER '2005-05-05 22:04:30', THE QUERY IS AS FOLLOWS.THE OUTPUT FOR THE LATTER QUERY IS $2.931176.

SELECT 
    AVG(rental_rate) AS average_rental_rate
FROM
    film f
        JOIN
    inventory i USING (film_id)
        JOIN
    rental r USING (inventory_id)
WHERE
    rental_date BETWEEN '2005-05-05 22:04:30' AND DATE_ADD('2005-05-05 22:04:30',
        INTERVAL 30 DAY);
        

-- 5.	What is the most popular category of films in terms of the number of rentals? (3 Marks)

SELECT 
    name AS category
FROM
    category c
        JOIN
    film_category fc USING (category_id)
        JOIN
    film f USING (film_id)
        JOIN
    inventory i USING (film_id)
        JOIN
    rental r USING (inventory_id)
GROUP BY 1
ORDER BY COUNT(r.rental_id) DESC
LIMIT 1;
 

-- THE MOST POPULAR CATEGORY OF FILMS IN TERMS OF THE NUMBER OF RENTALS IS "SPORTS"

                
-- 6.	Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks)


-- SELECT 
--     length MOVIE_DURATION
-- FROM
--     film
-- WHERE
--     film_id = (SELECT 
--             film_id
--         FROM
--             inventory
--         WHERE
--             inventory_id NOT IN (SELECT 
--                     inventory_id
--                 FROM
--                     rental));


                    
SELECT 
    *
FROM
    film
        LEFT JOIN
    inventory USING (film_id)
        LEFT JOIN
    rental USING (inventory_id)
WHERE
    rental_id IS NULL
ORDER BY length DESC
LIMIT 1;

-- For verification

select * from rental where inventory_id = (select inventory_id from inventory where film_id=198);


-- THE LONGEST MOVIE DURATION FROM THE LIST OF FILMS THAT HAVE NOT BEEN RENTED BY ANY CUSTOMER IS 184.

-- 7.	What is the average rental rate for films, broken down by category? (3 Marks)

 SELECT 
    c.name, AVG(f.rental_rate) AS average_rental_rate
FROM
    category c
        JOIN
    film_category fc USING (category_id)
        JOIN
    film f USING (film_id)
GROUP BY 1; 

-- 8.	What is the total revenue generated from rentals for each actor in the database? (3 Marks)

SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    SUM(p.amount) revenue
FROM
    actor a
        JOIN
    film_actor fa USING (actor_id)
        JOIN
    film f USING (film_id)
        JOIN
    inventory i USING (film_id)
        JOIN
    rental r USING (inventory_id)
        JOIN
    payment p USING (rental_id)
GROUP BY a.actor_id
ORDER BY 2;  


-- 9.	Show all the actresses who worked in a film having a "Wrestler" in the description. (3 Marks)

SELECT DISTINCT
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name
FROM
    actor a
        JOIN
    film_actor fa USING (actor_id)
        JOIN
    film f USING (film_id)
WHERE
    f.description LIKE '%Wrestler%'
ORDER BY 1;

-- 10.	Which customers have rented the same film more than once? (3 Marks)

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    f.film_id
FROM
    customer c
        JOIN
    rental r USING (customer_id)
        JOIN
    inventory i USING (inventory_id)
        JOIN
    film f USING (film_id)
GROUP BY c.customer_id , f.film_id
HAVING COUNT(r.customer_id) > 1;

-- THE CUSTOMR_ID , CUSTOMER_NAME AND THE FILM_ID OF THE FILM THEY RENTED ARE SHOWN AS OUTPUT.


-- 11.	How many films in the comedy category have a rental rate higher than the average rental rate? (3 Marks)

SELECT 
    COUNT(f.film_id) AS film_count
FROM
    film f
WHERE
    f.film_id IN (SELECT 
            fc.film_id
        FROM
            film_category fc
        WHERE
            fc.category_id = (SELECT 
                    c.category_id
                FROM
                    category c
                WHERE
                    c.name LIKE '%comedy%'))
        AND f.rental_rate > (SELECT 
            AVG(rental_rate)
        FROM
            film);

-- THERE ARE 42 FILMS WHICH HAVE RENTAL RATE HIGHER THAN AVERAGE RENTAL RATE IN COMEDY CATEGORY.

-- 12.	Which films have been rented the most by customers living in each city? (3 Marks)

select city,title as film_title from(
    SELECT DISTINCT
        title,
        city,
        COUNT(*) AS num_of_Rentals,
        Rank() OVER (PARTITION BY city ORDER BY COUNT(r.inventory_id) DESC) AS film_rank
    FROM
        rental r
        JOIN customer c USING (customer_id)
        JOIN inventory i USING (inventory_id)
        JOIN film f USING (film_id)
        JOIN address USING (address_id)
        JOIN city USING (city_id)
    GROUP BY 1, 2) rank_table where film_rank=1;

-- 13.	What is the total amount spent by customers whose rental payments exceed $200? (3 Marks)

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS amount
FROM
    customer c
        JOIN
    payment p USING (customer_id)
GROUP BY 1
HAVING SUM(p.amount) > 200;

-- THERE ARE 2 CUSTOMERS WITH CUSTOMER_ID's 148 AND 526 WHOSE RENTAL PAYMENTS EXCEED $200 AND THEIR CUMMULATIVE
-- RENTAL AMOUNTS INDIVIDUALLY ARE $216.54 AND $221.55 RESPECTIVELY. IF WE WANT THE TOTAL AMOUNT SPENT BY THESE
-- 2 CUSTOMERS , WE CAN FIND THE RESULT USING FOLLOWING QUERY.
  

SELECT 
    SUM(amount) AS amount_spent
FROM
    (SELECT DISTINCT
        c.customer_id, SUM(p.amount) AS amount
    FROM
        customer c
    JOIN payment p USING (customer_id)
    GROUP BY 1
    HAVING SUM(p.amount) > 200) AS Total_amount;

-- THE TOTAL AMOUNT SPENT BY ALL THE CUSTOMERS WHOSE RENTAL PAYMENT EXCEED $200 IS $438.09 (i.e.,$216.54 + 221.55)


-- 14.	Display the fields which are having foreign key constraints related to the "rental" table. 
-- [Hint: using Information_schema] (2 Marks)

use information_schema;

SELECT 
    REFERENCED_COLUMN_NAME AS foreign_key_constraints
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
    TABLE_NAME = 'rental'
        AND TABLE_SCHEMA = 'film_rental'
        AND CONSTRAINT_NAME LIKE 'fk%';

-- 15.	Create a View for the total revenue generated by each staff member, broken down by store city with the country name. (4 Marks)

 CREATE VIEW total_revenue AS
    SELECT 
        st.staff_id,
        CONCAT(st.first_name, ' ', st.last_name) AS staff_name,
        c.city,
        ct.country,
        SUM(p.amount) AS revenue
    FROM
        staff st
            JOIN
        payment p USING (staff_id)
            JOIN
        store s USING (store_id)
            JOIN
        address a ON s.address_id = a.address_id
            JOIN
        city c USING (city_id)
            JOIN
        country ct USING (country_id)
    GROUP BY 1 , 3 , 4;

SELECT * FROM total_revenue;

-- 16.	Create a view based on rental information consisting of visiting_day, customer_name, the title of the film,  
-- no_of_rental_days, the amount paid by the customer along with the percentage of customer spending. (4 Marks)

create view  rental_information as
select  r.rental_date,
		dayname(r.rental_date) visiting_day,
		concat(c.first_name," ",c.last_name) as customer_name,
		f.title as film_title,
		datediff(r.return_date,r.rental_date) as no_of_rental_days,p.amount,
		(p.amount/sum(p.amount) over(partition by c.customer_id))*100 as percentage_spending
		from rental r left join customer c using(customer_id) 
		join inventory i using(inventory_id) join film f using(film_id) 
        join payment p using(rental_id);

select * from rental_information;

-- 1) THE RENTAL_DATE COLUMN SHOWS THE DATE IN WHICH THE CUSTOMER TOOK THE FILM FOR RENT.
-- 2) THE VISITING_DAY COLUMN SHOWS THE DAY OF THE RENTAL_DATE(i.e.,MONDAY,TUESDAY,ETC. ).
-- 3) THEN CUSTOMER FULL NAME IS SHOWN IN CUSTOMER_NAME COLUMN FOLLOWING WITH THE TITLE OF
--    THE RENTED FILM AS FILM_TITLE. 
-- 4) THE NO_OF_RENTAL_DAYS COLUMN SHOWS THE NUMBER OF DAYS FOR WHICH THE 
--    FILM WAS RENTED (i.e., DAYS BETWEEN RENTAL_DATE AND RETURN_DATE) 
-- 5) THE AMOUNT COLUMN SHOWS THE AMOUNT SPENT BY THE CUSTOMER FOR RENTING THE PARTICULAR FILM.
--    (EACH CUSTOMER WOULD RENT MORE THAN ONE FILM IN DIFFERENT DATES WITH VARYING OR SAME RENT AMOUNT)
-- 6) THE PERCENTAGE_SPENDING COLUMN SHOWS THE PERCENTAGE OF AMOUNT ON A PARTICULAR TRANSACTION OVER 
--    THE TOTAL AMOUNT SPENT BY THE CUSTOMER ON ALL OF HIS/HER TRANSACTIONS. 
--    (EXAMPLE: IF MARY SMITH SPENT AN AMOUNT OF $2.99 FOR THE MOVIE FIREBALL PHILADELPHIA ON 2005-08-22 19:41:37, 
--    IT IS 2.519380%  OF HER TOTAL AMOUNT SPENT(i.e., $118.68))


-- 17.	Display the customers who paid 50% of their total rental costs within one day. (5 Marks)

select distinct customer_id,customer_name from(
    SELECT
       p.customer_id as customer_id, concat(c.first_name," ", c.last_name) customer_name,
        r.rental_date as date_rented,
        sum(f.rental_rate) as rental_rate_film,
        SUM(p.amount) AS total_payment_amount
    FROM
        customer c
        JOIN rental r ON c.customer_id = r.customer_id
        JOIN payment p ON r.rental_id = p.rental_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
    GROUP BY 1,2,3) payment_table  where 
   (date_rented between date_rented and DATE_ADD(date_rented, INTERVAL 1 DAY)) 
	and total_payment_amount >= 0.5 * rental_rate_film;
    
    
-- 18) Display the film title and the number of times it was rented. Show 0 if a film was never rented.

SELECT 
    f.film_id, f.title, COUNT(rental_id) times_rented
FROM
    film f
        LEFT JOIN
    inventory USING (film_id)
        LEFT JOIN
    rental USING (inventory_id)
GROUP BY 1 , 2;

-- 19) Display the actor who has acted in highest number of films in "sports" category.

with temp as (
select a.actor_id , concat(a.first_name , " ",a.last_name) name,count(a.actor_id) over (partition by a.actor_id) as film_count
from actor a join film_actor fa using(actor_id) join film f using(film_id) join film_category  fc using(film_id)
join category c using(category_id) where c.name like "%sports%")
select distinct * from temp where film_count = (select max(film_count) from temp);

-- 20) Display the actors who have never done any comedy films.


SELECT 
    *
FROM
    actor
WHERE
    actor_id NOT IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film_category
                WHERE
                    category_id IN (SELECT 
                            category_id
                        FROM
                            category
                        WHERE
                            name LIKE '%comedy%')));


-- 21) Display storewise contribution to total revenue in terms of percentages.

SELECT 
    s.store_id,
    SUM(p.amount)*100 / (SELECT 
            SUM(amount)
        FROM
            payment ) total_revenue_percent
FROM
    store s
        JOIN
    inventory i USING (store_id)
        JOIN
    rental r USING (inventory_id)
        JOIN
    payment p USING (rental_id)
GROUP BY 1;

-- 22) Show top 3 dates with the highest total revenue.

SELECT 
    DATE(payment_date) date, SUM(amount) Total_amount
FROM
    payment
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- 23) Create 3 categories of films based on rental_rate low(below $1) , medium($1 to $2) and high(above $3).Display the number of films in each category 


SELECT 
    (SELECT 
            COUNT(*)
        FROM
            film
        WHERE
            rental_rate < 1) AS low,
    (SELECT 
            COUNT(*)
        FROM
            film
        WHERE
            rental_rate BETWEEN 1 AND 3) AS medium,
    (SELECT 
            COUNT(*)
        FROM
            film
        WHERE
            rental_rate > 3) AS high;
            
            
SELECT 
    CASE
        WHEN rental_rate < 1 THEN 'low'
        WHEN rental_rate >= 1 AND rental_rate <= 3 THEN 'medium'
        ELSE 'high'
    END AS rate_category,
    COUNT(*) film_count
FROM
    film
GROUP BY 1;
    
    


   
 




