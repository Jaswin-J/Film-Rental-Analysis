-- 6.	Find the longest movie duration from the list of films that have not been rented by any customer. (3 Marks)

select * from film f join inventory i using(film_id) join rental r using(inventory_id) 
where i.inventory_id not in (select r.inventory_id from rental r);


select * from film where film_id =
(select film_id from inventory where inventory_id not in (select inventory_id from rental));


select tc.* , c.column_name from table_constraints tc join columns c using(table_name)  where 
tc.table_name 
like "%rental%" and CONSTRAINT_TYPE like "%FOREIGN KEY%" ;
