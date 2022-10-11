-- Case Study 1: The taste of success

SELECT *
  FROM DannySQLChallenge1..members;

  SELECT *
  FROM DannySQLChallenge1..menu;

  SELECT *
  FROM DannySQLChallenge1..sales;

-- 1. Total spent per customer

SELECT customer_id, SUM(price) AS total_sales
  FROM DannySQLChallenge1..sales AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
GROUP BY customer_id

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS visits
  FROM DannySQLChallenge1..sales AS s
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?

WITH food_ordering AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY customer_ID ORDER BY order_date) AS rank
  FROM DannySQLChallenge1..sales AS s
)

SELECT customer_id, product_name
  FROM food_ordering AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
WHERE rank = 1
GROUP BY customer_id, product_name



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT TOP 1 COUNT(s.product_id) AS item_sales, m.product_name
  FROM DannySQLChallenge1..sales AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY item_sales DESC

-- 5. Which item was the most popular for each customer?
WITH cust_menu_item_rank
AS
(
SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS sales, RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rank
  FROM DannySQLChallenge1..sales AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
 GROUP BY s.customer_id, s.product_id, product_name
 )

 SELECT customer_id, product_name, sales
   FROM cust_menu_item_rank
  WHERE rank = 1

-- 6. Which item was purchased first by the customer after they became a member?
WITH join_order
AS
(
SELECT s.customer_id, order_date, join_date, s.product_id, product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM DannySQLChallenge1.. sales AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
  JOIN DannySQLChallenge1..members AS mr ON s.customer_id = mr.customer_id
 WHERE order_date>=join_date
 )

 SELECT customer_id, product_name
   FROM join_order
  WHERE rank = 1

-- 7. Which item was purchased just before the customer became a member?

 WITH join_order
AS
(
SELECT s.customer_id, order_date, join_date, s.product_id, product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
  FROM DannySQLChallenge1.. sales AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
  JOIN DannySQLChallenge1..members AS mr ON s.customer_id = mr.customer_id
 WHERE order_date<join_date
 )

 SELECT customer_id, product_name
   FROM join_order
  WHERE rank = 1

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.customer_id) AS total_bought, SUM(price) AS total_sales
  FROM DannySQLChallenge1..sales AS s
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
  JOIN DannySQLChallenge1..members AS mr ON s.customer_id = mr.customer_id
   WHERE s.order_date < mr.join_date
GROUP BY s.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points
AS(
SELECT *,
	  CASE 
		  WHEN LOWER(product_name) LIKE '%sushi%'
		  THEN price * 20
		  ELSE price * 10
		  END AS points
FROM DannySQLChallenge1..menu
)

SELECT s.customer_id, SUM(points) AS total_points
  FROM DannySQLChallenge1..sales AS s
  JOIN points AS m on s.product_id = m.product_id
GROUP BY s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- add 6 days as the join date counts as first day, create this as a CTE so can work out the loyatly period from this join
WITH loyalty_dates AS
(
SELECT *, DATEADD(DAY,6,join_date) AS loyalty_period, EOMONTH('2021-01-31') AS end_date
  FROM DannySQLChallenge1..members
),
jan_sales
AS
(
SELECT ld.customer_id,
	   CASE
			   WHEN LOWER(product_name) LIKE 'sushi' THEN 2*10*price
			   WHEN order_date BETWEEN join_date AND loyalty_period THEN 2*10*price
			   ELSE 10*price
			   END
			   AS points
  FROM loyalty_dates AS ld
  JOIN DannySQLChallenge1..sales AS s ON ld.customer_id = s.customer_id
  JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
 WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
)

SELECT customer_id, SUM(points) AS jan_points
  FROM jan_sales
GROUP BY customer_id;

-- Bonus questions, join all data with customer_id, order_date, product_name, price, member (Y/N)
SELECT s.customer_id, order_date, product_name, price,
	   CASE
			WHEN order_date > join_date THEN 'Y'
			ELSE 'N'
			END
			AS member
  FROM DannySQLChallenge1..sales AS s
 LEFT JOIN DannySQLChallenge1..menu AS m ON s.product_id = m.product_id
 LEFT JOIN DannySQLChallenge1..members AS mb ON mb.customer_id = s.customer_id

