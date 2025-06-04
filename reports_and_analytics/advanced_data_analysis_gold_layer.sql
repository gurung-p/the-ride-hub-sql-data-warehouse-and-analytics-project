
-- ========================================================
-- Advanced Data Analysis
-- ========================================================

-- Analyse sales performance overtime by year
SELECT 
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) 
ORDER BY YEAR(order_date) 

-- Analyse sales performance overtime by year with DATETRUNC
SELECT 
	DATETRUNC(year, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
ORDER BY DATETRUNC(year, order_date)


-- Analyse sales performance overtime by month
SELECT 
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date) 
ORDER BY MONTH(order_date) 

-- Analyse sales performance overtime by month with DATETRUNC
SELECT 
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date) 


-- Analyse sales performance overtime by month & year
SELECT 
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date) 
ORDER BY YEAR(order_date), MONTH(order_date) 


-- Calculate total sales per month & running total of sales over time
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
SELECT
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t


-- Calculate monthly running total of sales with limit per year
-- so that it starts fresh every year
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM (
SELECT
	DATETRUNC(month, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t


-- Calculate running total of sales yearly
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
SELECT
	DATETRUNC(year, order_date) AS order_date,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t


-- Calculate running total of sales yearly
-- Calculate moving average price yearly
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM (
SELECT
	DATETRUNC(year, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t


-- Analyze the yearly performance of products by comparing their sales
-- for average sales product performance & previous year's sale
WITH yearly_product_sales AS (
SELECT 
	YEAR(s.order_date) AS order_year,
	p.product_name,
	SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products as P
ON p.product_key = s.product_key
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(s.order_date), p.product_name
)
SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS avg_difference,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Average'
	END As average_change,
	-- Year-over-year analysis
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_yr_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_yr_sales_difference,
	CASE
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increased'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreased'
		ELSE 'No Change'
		END AS previous_yr_change
FROM yearly_product_sales
ORDER BY product_name, order_year


-- Which categories contribute the most to the overall sales
WITH category_sales AS (
SELECT 
	p.category,
	SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
GROUP BY p.category
)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER () * 100, 2), '%') AS percentage_of_total
FROM category_sales


-- Segment products into cost range
-- Count how many products fall into each segment
WITH product_segment AS (
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
		 ELSE 'Above 1000'
	END AS cost_range
FROM gold.dim_products)

SELECT 
	cost_range,
	COUNT(product_key) AS total_products
	FROM product_segment
	GROUP BY cost_range
	ORDER BY total_products DESC


/*Group customers into three segments based on their spending behaviour:
1. VIP - customers with at least 12 months of history & spending more than $5000
2. Regular - customers with at least 12 months of history but spending $5000 or less
3. New - customers with lifespan less than 12 month
Find total number of customers by each group */

WITH customer_spending AS (
SELECT
	c.customer_key,
	SUM(s.sales_amount) AS total_spending,
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan 
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers FROM (
	SELECT
		customer_key,
		total_spending, 
		lifespan,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC

