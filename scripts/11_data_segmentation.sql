/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*
=================================================================
--Group the data based on a specific range
--Helps understand the correlation between two measures
=================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
--Creating cost ranges

SELECT
product_key,
product_name,
cost,
CASE
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-100'
	ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products;

--Segmenting products into cost ranges using CTE

WITH product_segments AS (

SELECT
product_key,
product_name,
cost,
CASE
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-100'
	ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products
)
SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products;

/*
Important Notes:
If there are not enough dimensions to create insights, one of the measures can be converted to a dimension using
CASE WHEN and other measures can be aggregated based on this new dimension.
So we are deriving new informations and by following this concept, measures and dimensions endless amount of
reports can be generated even if the size of business or the data set is small.
*/

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
	
And find the total number of customers by each group.
*/
SELECT
c.customer_key,
f.sales_amount,
f.order_date
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key;

--Calculating the spending lifespan and sales amount aggregation.
--Deriving new measure from date dimension

SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key;

--Creating segments based on the intermediate results. Using CTE to get the final result.
--Converting the new measure into a dimension help finalize the results.

WITH customer_spending AS 
(
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_key,
total_spending,
lifespan,
CASE
	WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment
FROM customer_spending;

--Finding the total number of customers in based on the new dimension created with CASE WHEN 


WITH customer_spending AS 
(
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
CASE
	WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment,
COUNT(customer_key) AS total_customers
FROM customer_spending
GROUP BY CASE
	WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
END;

--To avoid repetion in the query. Introduce CTE or Subquery.
--Subquery used here:

WITH customer_spending AS 
(
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM
(
	SELECT
	customer_key,
	CASE
		WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment
	FROM customer_spending
	)t 
GROUP BY customer_segment
ORDER BY total_customers DESC;

/* Using CTE 

WITH customer_spending AS 
(
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
),

customer_count AS
(
SELECT
customer_key,
CASE
	WHEN lifespan >= 12 and total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 and total_spending <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment
FROM customer_spending
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM customer_count
GROUP BY customer_segment
ORDER BY total_customers DESC;

*/
