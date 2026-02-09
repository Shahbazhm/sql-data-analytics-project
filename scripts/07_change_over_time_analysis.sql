/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.
	- -->>(Aggregate Measure divided by Date Dimension)

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time
-- Quick Date Functions

SELECT
order_date,
sales_amount
FROM gold.fact_sales
ORDER BY order_date ASC;

--Removing NULLS

SELECT
order_date,
sales_amount
FROM gold.fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date ASC;

--Aggregating the data by the sales_amount

SELECT
order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date ASC;

--Result is a sales overtime analysis but at a Day granularity. Normally higher level aggregations are used.

--Change data granularity from Day to Year level.

SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;

--Adding more measures to data.

SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC; 

--Changes Over Years: A high-level overview insights that helps with strategic decision making.

--Drilling down data to the Month level to analyze monthly performance trends. Not including Year in the Analysis, results in the monthly aggregation including all years.

SELECT
Month(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY Month(order_date)
ORDER BY Month(order_date) ASC;

--Changes Over Months: Detailed insights to discover seasonality in the data.

--Making it more specific to a month at yearly level.

SELECT
Year(order_date) AS order_year,
Month(order_date) AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY Year(order_date), Month(order_date)
ORDER BY YEAR(order_date), Month(order_date) ASC;

--Filtering data for a specific Year/s

SELECT
Year(order_date) AS order_year,  --Output is integer with no issues in data sorting.
Month(order_date) AS order_month, -- Output is integer with no issues in data sorting. 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL and Year(order_date) = 2013 -- != 2013
GROUP BY Year(order_date), Month(order_date)
ORDER BY Year(order_date), Month(order_date) ASC;

--Using different date formatting instead of multiple date columns

SELECT
DATETRUNC(Month, order_date) AS order_date, --DATETRUNC() rounds a date or timestamp to a specified date part. Output is Date data type with no issues in sorting.
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(Month, order_date)
ORDER BY DATETRUNC(Month, order_date) ASC;

/*
SELECT
DATETRUNC(Year, order_date) AS order_date, --DATETRUNC() rounds a date or timestamp to a specified date part.
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(Year, order_date)
ORDER BY DATETRUNC(Year, order_date) ASC;
*/

--For a specific date format

SELECT
FORMAT(order_date, 'yyy-MMM') AS order_date, --FORMAT() output is string data type. Sorting data can be a problem.
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY FORMAT(order_date, 'yyy-MMM')
ORDER BY FORMAT(order_date, 'yyy-MMM') ASC;
