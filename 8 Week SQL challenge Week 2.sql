SELECT *
  FROM DannySQLChallenge2..customer_orders

  SELECT *
  FROM DannySQLChallenge2..pizza_names

SELECT *
  FROM DannySQLChallenge2..pizza_toppings

SELECT *
  FROM DannySQLChallenge2..pizza_recipes

SELECT *
  FROM DannySQLChallenge2..runner_orders

SELECT *
  FROM DannySQLChallenge2..runners

-- Need to tidy some of the NULL values and change to blanks or 0s

UPDATE DannySQLChallenge2..customer_orders
  SET extras = ''
 WHERE extras IS NULL

 UPDATE DannySQLChallenge2..customer_orders
  SET exclusions = ''
 WHERE exclusions LIKE 'null'

  UPDATE DannySQLChallenge2..customer_orders
  SET extras = ''
 WHERE extras LIKE 'null'

 UPDATE DannySQLChallenge2..runner_orders
   SET cancellation = ''
 WHERE cancellation IS NULL

  UPDATE DannySQLChallenge2..runner_orders
   SET cancellation = ''
 WHERE cancellation LIKE 'null'

 DROP TABLE IF EXISTS dannySQLchallenge2..runner_order_new
 CREATE TABLE dannySQLchallenge2..runner_order_new
 (order_id INT,
  runner_id INT,
  pickup_time DATETIME,
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(50)
)

INSERT INTO dannySQLchallenge2..runner_order_new
SELECT order_id, runner_id,
  CASE 
    WHEN pickup_time LIKE 'null' THEN ' '
    ELSE pickup_time 
    END AS pickup_time,
  CASE 
    WHEN distance LIKE 'null' THEN ' '
    WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
    ELSE distance END AS distance,
  CASE 
    WHEN duration LIKE 'null' THEN ' ' 
    WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
    ELSE duration END AS duration,
  CASE 
    WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ''
    ELSE cancellation END AS cancellation
FROM DannySQLChallenge2..runner_orders

-- Rerun tables to check all is ok now!

SELECT *
  FROM DannySQLChallenge2..customer_orders

  SELECT *
  FROM DannySQLChallenge2..pizza_names

SELECT *
  FROM DannySQLChallenge2..pizza_toppings

SELECT *
  FROM DannySQLChallenge2..pizza_recipes

SELECT *
  FROM DannySQLChallenge2..runner_order_new

SELECT *
  FROM DannySQLChallenge2..runners
-- Part 1 Pizza Metrics:
-- How many pizzas were ordered?
-- How many unique customer orders were made?
-- How many successful orders were delivered by each runner?
-- How many of each type of pizza was delivered?
-- How many Vegetarian and Meatlovers were ordered by each customer?
-- What was the maximum number of pizzas delivered in a single order?
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?

-- 1.  How many pizzas were ordered?

SELECT COUNT(pizza_id) AS total_pizzas_ordered
  FROM DannySQLChallenge2..customer_orders

-- 2.  How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_orders
  FROM DannySQLChallenge2..customer_orders

-- 3.  How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(runner_id) AS successful_orders
  FROM DannySQLChallenge2..runner_order_new
 WHERE  distance <> ''
 GROUP BY runner_id
 
-- 4.  How many of each type of pizza was delivered?

SELECT pn.pizza_name, COUNT(co.pizza_id) AS pizza_order_count
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..pizza_names AS pn ON pn.pizza_id = co.pizza_id
GROUP BY pn.pizza_id, pn.pizza_name

-- getting errors with datatype so will convert these to varchar

ALTER TABLE DannySQLChallenge2..pizza_names
ALTER COLUMN pizza_name VARCHAR(50)

-- Will now try rerunning the query

SELECT pn.pizza_name, COUNT(co.pizza_id) AS pizza_order_count
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..pizza_names AS pn ON pn.pizza_id = co.pizza_id
GROUP BY pn.pizza_id, pn.pizza_name

-- 5.  How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pn.pizza_name, COUNT(co.pizza_id) AS pizza_order_count
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..pizza_names AS pn ON pn.pizza_id = co.pizza_id
GROUP BY customer_id, pn.pizza_id, pn.pizza_name;

-- 6.  What was the maximum number of pizzas delivered in a single order?
WITH pizza_orders
AS(
SELECT order_id, COUNT(order_id) AS pizzas_per_order
  FROM DannySQLChallenge2..customer_orders
GROUP BY order_id
)

SELECT max(pizzas_per_order) AS max_ordered
  FROM pizza_orders
  
-- 7.  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT co.customer_id,
	   SUM(CASE WHEN co.exclusions <> '' OR co.extras <> '' THEN 1 ELSE 0 END) AS pizza_changes,
	   SUM(CASE WHEN co.exclusions = '' OR co.extras = '' THEN 1 ELSE 0 END) AS no_changes
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..runner_order_new AS ro ON ro.order_id = co.order_id
WHERE distance <> ''
GROUP BY customer_id;


-- 8.  How many pizzas were delivered that had both exclusions and extras?

SELECT co.order_id, COUNT(DISTINCT co.order_id) AS excl_extras
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..runner_order_new AS ro ON ro.order_id = co.order_id
WHERE distance <> '' AND exclusions <> '' AND extras <> ''
GROUP BY co.order_id

-- 9.  What was the total volume of pizzas ordered for each hour of the day?
-- Will include version where orders were and weren't cancelled

SELECT COUNT(co.order_id) AS pizzas_ordered, DATEPART(HOUR, order_time) AS hour
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..runner_order_new AS ro ON ro.order_id = co.order_id
  WHERE distance <> ''
 GROUP BY DATEPART(HOUR, order_time)

 SELECT COUNT(co.order_id) AS pizzas_ordered, DATEPART(HOUR, order_time) AS hour
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..runner_order_new AS ro ON ro.order_id = co.order_id
 GROUP BY DATEPART(HOUR, order_time)

-- 10. What was the volume of orders for each day of the week?
 SET datefirst 1;
 SELECT COUNT(co.order_id) AS pizzas_ordered, DATEPART(WEEKDAY, order_time) AS day_num, DATENAME(WEEKDAY, order_time) AS weekday
  FROM DannySQLChallenge2..customer_orders AS co
  JOIN DannySQLChallenge2..runner_order_new AS ro ON ro.order_id = co.order_id
 GROUP BY DATEPART(WEEKDAY, order_time), DATENAME(WEEKDAY, order_time)


-- Part B. Runner and Customer Experience
-- 1.  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- 2.  What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- 3.  Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- 4.  What was the average distance travelled for each customer?
-- 5.  What was the difference between the longest and shortest delivery times for all orders?
-- 6.  What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- 7.  What is the successful delivery percentage for each runner?

--Rerun tables for info:
SELECT *
  FROM DannySQLChallenge2..customer_orders
SELECT *
  FROM DannySQLChallenge2..pizza_names
SELECT *
  FROM DannySQLChallenge2..pizza_toppings
SELECT *
  FROM DannySQLChallenge2..pizza_recipes
SELECT *
  FROM DannySQLChallenge2..runner_order_new
SELECT *
  FROM DannySQLChallenge2..runners

-- 1.  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SET datefirst 1;
SELECT DATEPART(week,registration_date) AS start_week, COUNT(runner_id)
  FROM DannySQLChallenge2..runners
GROUP BY DATEPART(week,registration_date)

-- 2.  What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH time_taken AS
(
SELECT DISTINCT(ron.order_id),runner_id, DATEDIFF(MINUTE, order_time, pickup_time) AS pickup_time
  FROM DannySQLChallenge2..runner_order_new AS ron
  JOIN DannySQLChallenge2..customer_orders AS co ON co.order_id = ron.order_id
 WHERE cancellation = ''
)

SELECT runner_id, AVG(pickup_time) AS average_pickup
  FROM time_taken
GROUP BY runner_id

-- 3.  Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT DISTINCT(ron.order_id),runner_id, DATEDIFF(MINUTE, order_time, pickup_time) AS pickup_time/
  FROM DannySQLChallenge2..runner_order_new AS ron
  JOIN DannySQLChallenge2..customer_orders AS co ON co.order_id = ron.order_id
 WHERE cancellation = ''

-- 4.  What was the average distance travelled for each customer?

-- 5.  What was the difference between the longest and shortest delivery times for all orders?

-- 6.  What was the average speed for each runner for each delivery and do you notice any trend for these values?

-- 7.  What is the successful delivery percentage for each runner?

