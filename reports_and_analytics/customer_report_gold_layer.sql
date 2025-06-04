/*
=====================================================
Customer Report
=====================================================
Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details. 
2. Aggregates customer-level metrics:
	- Total orders
	- Total sales
	- Total quantity purchased
	- Total products
	- Lifespan (in months)
3. Segments customers into categories (VIP, Regular, New) and age groups. 
4. Calculates valuable KPIs:
	- Recency (months since last order)
	- Average order value
	- Average monthly spend
5. Create View for Report

*/

---------------Steps---------------

-- 1. Base query: retrieve core columns from the tables
CREATE VIEW gold.report_customers AS

WITH base_query AS (
SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(year, c.birth_date, GETDATE()) AS age
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key = c.customer_key
WHERE order_date IS NOT NULL)

-- 2. Aggregation customer-level matrics via CTE/subquery
, customer_aggregation AS (
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)

-- 3. Segment customers into categories (VIP, Regular, New) and age groups. 
-- 4. Calculate valuable KPIs:
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE 
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
		WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
		WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
		ELSE '50 and above'
	END AS age_group,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	last_order_date,
	-- calculate recency - months since last order)
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- calculate average order value
	CASE
		WHEN total_sales = 0 THEN 0
		ELSE total_sales / total_orders 
		END AS average_order_value,
	-- calculate average monthly spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS average_monthly_spend
FROM customer_aggregation