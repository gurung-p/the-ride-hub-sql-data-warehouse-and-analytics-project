/*
===============================================================================
DDL Script: Gold Layer - Create Sales Fact View 
===============================================================================

This script creates Sales Fact view for the Gold layer in the data warehouse, 
which holds the final dimension and fact tables in a Star Schema structure.

Each view performs transformations and combines data from the Silver layer 
to produce a clean, enriched, and business-ready dataset.

Usage: The view can be queried directly for analytics and reporting, making data 
exploration smooth and efficient
===============================================================================
*/



-- LEFT JOIN "Sales" table with gold dimension for products & customers
-- Use the surrogate key column from gold dimension products & customers
-- a. product_key
-- b. customer_key

SELECT
    sd.sls_ord_num,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_sales,
    sd.sls_quantity,
    sd.sls_price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id


-- =============================================================================
-- Create Fact: gold.fact_sales
-- =============================================================================

-- Order columns in logical order with meaningful names
-- Create FACT view

CREATE VIEW gold.fact_sales AS

with CTE_calc AS(
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    SUM(sd.sls_sales) AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price,
    SUM(pr.cost * sd.sls_quantity) as total_product_cost
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_cust_id = cu.customer_id
GROUP BY 
    sd.sls_ord_num,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_quantity,
    sd.sls_price
)
SELECT 
    order_number,
    product_key,
    customer_key,
    order_date,
    shipping_date,
    due_date,
    quantity,
    price,
    sales_amount,
    total_product_cost,
    sales_amount - total_product_cost as profit
FROM CTE_calc

-- Check if all DIMENSION tables can join to FACT table

SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL 

SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL

SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL
