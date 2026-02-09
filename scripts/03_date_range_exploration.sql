/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

--Find the date of the first and the last order (Boundaries of Dataset).

SELECT order_date FROM gold.fact_sales

SELECT 
MIN(order_date) as first_order_date,
MAX(order_date) as last_order_date 
FROM gold.fact_sales

--How many years/months of sales are available.

SELECT 
MIN(order_date) as first_order_date,
MAX(order_date) as last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) as order_range_years,
DATEDIFF(month, MIN(order_date), MAX(order_date)) as order_range_months
FROM gold.fact_sales

--Find the youngest and the oldest customers based on birthdate.

SELECT
MIN(birthdate) AS oldest_birthdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_customer,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_customer
FROM gold.dim_customers;
