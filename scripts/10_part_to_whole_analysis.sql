/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

/*
=================================================================
--Analyze how an individual part is performing compared to the overall
--allowing us to undrstand which category has the greatest on the business
=================================================================
*/

-->>(Measure / Total Measure) * 100

-- Which categories contribute the most to overall sales?
SELECT 
	p.category,
	f.sales_amount
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key

SELECT 
	p.category,
	SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.category;

--Calculating overall sales using window function in a CTE. 

WITH category_sales AS (
	SELECT 
		p.category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.category
)
SELECT 
	category,
	total_sales,
SUM(total_sales) OVER() AS overall_sales
FROM category_sales;

--Calculating part-to-whole (percentage)

WITH category_sales AS (
	SELECT 
		p.category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.category
)
SELECT 
	category,
	total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

/*
IMPORTANT NOTES: 

-That is how we analyze the performance of the part of a business compared to overall.
-Different dimensions and measures can be utilized to build many different insights using the same methods.
-Using the window functions, we compare the part value with the whole value. 
*/
