/*
===============================================================================
DDL Script: Gold Layer - Create Product Dimension View 
===============================================================================

This script creates Product Dimension view for the Gold layer in the data warehouse, 
which holds the final dimension and fact tables in a Star Schema structure.

Each view performs transformations and combines data from the Silver layer 
to produce a clean, enriched, and business-ready dataset.

Usage: The view can be queried directly for analytics and reporting, making data 
exploration smooth and efficient
===============================================================================
*/



/* Left join all silver layer products table
 - silver.crm_prd_info
 - silver.erp_px_cat_g1v2 */

SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out historic data

-- Check quality joined tables for any duplicates

SELECT prd_key, COUNT(*) FROM (
SELECT
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out historic data
)t GROUP BY prd_key
HAVING COUNT(*) > 1


-- Sort columns into logical order & give meaningful names

SELECT
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out historic data



-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

-- Generate surrogate key for products dimension
-- Create view

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Filter out historic data


-- POST VIEW CREATION - Quality check

SELECT * FROM gold.dim_products

SELECT product_id, COUNT (*) FROM gold.dim_products
group by product_id 
having COUNT(*) > 1