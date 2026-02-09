/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/*
=================================================================
--Comparing the current value to a target value
--Helps measure success and compare performance
=================================================================
*/

-->>(Current Measure - Target Measure)
-->>(Windows Aggregate Functions, Windows Value Functions)

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

--yearly: order date
--dimension: products
--measure: sales

SELECT 
f.order_date,
p.product_name,
f.sales_amount
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key;

--solving the yearly performance of the products

SELECT 
Year(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY Year(f.order_date), p.product_name

--moving on to calculate average sales
--building a CTE 

WITH yearly_product_sales AS (

SELECT 
Year(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY Year(f.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales --Avg sales for each product using windows aggregate function.
FROM yearly_product_sales
ORDER BY product_name, order_year;

--Next average sales performance

WITH yearly_product_sales AS (

SELECT 
Year(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY Year(f.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales, --Avg sales for each product using windows aggregate function. No sorting is required as we are using the average. 
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
	ELSE 'Avg'
END AS avg_change,

--Year-over-year Analysis (Long-term Trend Analysis)

LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS py_sales, --sorting required for previous year comparison.
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) AS diff_py, 
CASE
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
	ELSE 'No Change'
END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;

/*
--Month Granularity

WITH monthly_product_sales AS (

SELECT
year(f.order_date) AS order_year,
month(f.order_date) AS order_month,
p.product_name,
SUM(f.sales_amount) AS current_sales 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL AND year(f.order_date) = 2013
GROUP BY year(f.order_date), month(f.order_date), p.product_name
)

SELECT
order_year
order_month,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales, --Avg sales for each product using windows aggregate function. No sorting is required as we are using the average. 
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
CASE
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
	ELSE 'Avg'
END AS avg_change,

--month-over-month Analysis (Short-term Seasonal Analysis)

LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_month ASC) AS py_sales, --sorting required for previous month comparison.
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_month ASC) AS diff_py, 
CASE
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_month ASC) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_month ASC) < 0 THEN 'Decrease'
	ELSE 'No Change'
END AS py_change
FROM monthly_product_sales
ORDER BY product_name, order_month;
*/

/*
IMPORTANT NOTES: 

-That is how we analyze the performance of the business by comparing the current measure with the target measure.
-Different dimensions and measures can be utilized to build many different insights using the same methods.
-Using the window functions, we compare the current value with another value. 
*/
