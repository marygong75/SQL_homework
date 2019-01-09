-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;
SELECT *FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
ALTER TABLE actor ADD COLUMN Actor_name VARCHAR(100);
UPDATE actor SET Actor_name = CONCAT(first_name, ' ', last_name);

CREATE TRIGGER insert_trigger
BEFORE INSERT ON actor
FOR EACH ROW
SET new.Actor_name = CONCAT(first_name, ' ', last_name);

CREATE TRIGGER update_trigger
BEFORE INSERT ON actor
FOR EACH ROW
SET new.Actor_name = CONCAT(first_name, ' ', last_name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT *FROM actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT *FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *FROM actor WHERE last_name LIKE '%LI%';
-- CHANGE ORDER OF ROWS

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT *FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN descriptions BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN descriptions;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as lastname_count
FROM actor
GROUP BY last_name
ORDER BY lastname_count DESC
LIMIT 1000;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as lastname_count
FROM actor
GROUP BY last_name
HAVING lastname_count > 1
ORDER BY lastname_count DESC
LIMIT 1000;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

UPDATE actor
SET first_name = "HARPO"
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE address_id (
	id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(100),
    address_id SMALLINT UNSIGNED NOT NULL,
    Primary Key (id),
    Foreign Key (address_id) REFERENCES address(address_id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.staff_id, staff.first_name, staff.last_name, staff.address_id, address.address, address.district, address.postal_code
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id
ORDER BY staff.staff_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount)
FROM payment
	JOIN staff
		ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.film_id, film.title, film_actor.actor_id
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT inventory_id, film_id, store_id
FROM inventory
WHERE film_id = 439;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount)
FROM customer
	JOIN payment
		ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT *FROM film WHERE title LIKE 'K%' or title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id
		FROM film
		WHERE title = ('Alone Trip')
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.customer_id, customer.email, customer.address_id, city.city_id, city.country_id, country.country
FROM customer
	JOIN address
		ON address.address_id = customer.address_id
	JOIN city
		ON city.city_id = address.city_id
	JOIN country
		ON country.country_id = city.country_id
WHERE country.country_id = 20;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
        FROM category
        WHERE name = ('Family')
	)
);

-- 7e. Display the most frequently rented movies in descending order.
SELECT *FROM film WHERE rental_duration > 1
ORDER BY rental_duration DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id, SUM(amount)
FROM payment
GROUP BY staff_id, staff_id
ORDER BY staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
	JOIN address
		ON address.address_id = store.address_id
	JOIN city
		ON city.city_id = address.city_id
	JOIN country
		ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.category_id, category.name, sum(payment.amount)
FROM category
	JOIN film_category
		ON film_category.category_id = category.category_id
	JOIN inventory
		ON inventory.film_id = film_category.film_id
	JOIN rental
		ON rental.inventory_id = inventory.inventory_id
	JOIN payment
		ON payment.rental_id = rental.rental_id
GROUP BY category.category_id
ORDER BY sum(payment.amount) DESC
LIMIT 5;



-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE TABLE top_five_genres AS
SELECT category.category_id, category.name, sum(payment.amount)
FROM category
	JOIN film_category
		ON film_category.category_id = category.category_id
	JOIN inventory
		ON inventory.film_id = film_category.film_id
	JOIN rental
		ON rental.inventory_id = inventory.inventory_id
	JOIN payment
		ON payment.rental_id = rental.rental_id
GROUP BY category.category_id
ORDER BY sum(payment.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT *FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP TABLE top_five_genres;

