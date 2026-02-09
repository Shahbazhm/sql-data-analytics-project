/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

/*
=================================================================
--Aggregate the data progressively over time
--Helps to understand whether the business is growing or declining
=================================================================
*/

-->>(Cumulative Measure divided by Date Dimension)
-->>(Solution: Windows Aggregate Functions)

--Calculate the total sales per month
--and the Running Total of sales overtime

--Monthly sales

SELECT
DATETRUNC(Month, order_date) AS order_date, 
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(Month, order_date)
ORDER BY DATETRUNC(Month, order_date) ASC;

--Running total adding Aggregate Window Function


SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales --Adding each row value to the sum of all the previous rows' values.
FROM (															  --Default Window Frame: Between unbounded preceding and current row
	SELECT
		DATETRUNC(Month, order_date) AS order_date, 
		SUM(sales_amount) AS total_sales
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL 
		GROUP BY DATETRUNC(Month, order_date)
	)t; 
	
--Limiting running total window calculation to a year. 
--Creating Partitions

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(PARTITION BY Year(order_date) ORDER BY order_date) AS running_total_sales 
FROM (															  
	SELECT
		DATETRUNC(Month, order_date) AS order_date, 
		SUM(sales_amount) AS total_sales
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL 
		GROUP BY DATETRUNC(Month, order_date)
	)t; 

--Changing granularity to Year

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales 
FROM (															  
	SELECT
		DATETRUNC(Year, order_date) AS order_date, 
		SUM(sales_amount) AS total_sales
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL 
		GROUP BY DATETRUNC(Year, order_date)
	)t;

--Adding Moving Average calculation

SELECT
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
avg_price,
AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM (															  
	SELECT
		DATETRUNC(Year, order_date) AS order_date, 
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
		FROM gold.fact_sales
		WHERE order_date IS NOT NULL 
		GROUP BY DATETRUNC(Year, order_date)
	)t;
