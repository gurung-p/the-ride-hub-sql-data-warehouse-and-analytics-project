/*
=================================================
Product Report
=================================================
Purpose:
This report consolidates key product metrics and behaviors.

Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost.
2. Aggregates product-level metrics:
	- total orders
	- total sales
	- total quantity sold
	- total customers (unique) 
	- lifespan (in months)
3. Segments products by revenue to identify High-Performers, Mid-Range or Low-Performers. 
4. Calculates valuable KPIs:
	- recency (months since last sale)
	- average order revenue (AOR)
	- average monthly revenue
*/

---------------Steps--------------------------------

-- 1. Base query: retrieve core columns from gold.fact_sales & gold.dim_products

--IF OBJECT_ID ('gold.report_products' , 'V') IS NOT NULL
--DROP VIEW gold.report_products;

CREATE VIEW gold.report_products AS

WITH base_query AS (	-- CTE
SELECT 
	s.order_number,
	s.order_date,
	s.customer_key,
	s.sales_amount,
	s.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
),

-- 2. Aggregate product-level metrics:
product_aggregations AS (	-- CTE
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	SUM(cost) AS total_cost,
	AVG(sales_amount / quantity) AS average_selling_price 
FROM base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory
)

-- 3. Segments products by revenue 
-- 4. Calculates valuable KPIs
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_customers,
	total_sales,
	total_cost,
	total_sales - total_cost AS total_profit,
	total_quantity,
	average_selling_price,
	-- Average order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS average_order_revenue,
	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS average_monthly_revenue
FROM product_aggregations
