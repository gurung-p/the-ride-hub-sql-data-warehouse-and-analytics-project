/*
===============================================================================
DDL Script: Gold Layer - Create Customer Dimension View 
===============================================================================

This script creates Customer Dimension view for the Gold layer in the data warehouse, 
which holds the final dimension and fact tables in a Star Schema structure.

Each view performs transformations and combines data from the Silver layer 
to produce a clean, enriched, and business-ready dataset.

Usage: The view can be queried directly for analytics and reporting, making data 
exploration smooth and efficient
===============================================================================
*/


/*Left join all silver layer 'customer' tables
- silver.crm_cust_info 
- silver.erp_cust_az12
- silver.erp_loc_a101 */

SELECT 
	ci.cst_id,
    	ci.cst_key,
    	ci.cst_firstname,
    	ci.cst_lastname,
    	ci.cst_marital_status,
    	ci.cst_gndr,
    	ci.cst_create_date,
    	ca.bdate,
    	ca.gen,
    	cl.cntry
 FROM silver.crm_cust_info AS ci
 LEFT JOIN silver.erp_cust_az12 AS ca
 ON ci.cst_key = ca.cid
 LEFT JOIN silver.erp_loc_a101 AS cl
 ON ci.cst_key = cl.cid


 -- POST JOIN - Check for any duplicates
 SELECT cst_id, count (*) FROM (
 SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	cl.cntry
FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 AS cl
	ON ci.cst_key = cl.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1

  -- Data Integration

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid
ORDER BY 1, 2

-- Fix Data Integration

SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master source for gender
	 ELSE COALESCE(ca.gen, 'n/a')
END AS NEW_GEN
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid
ORDER BY 1, 2

-- Cleansed Data & renamed coulumns into meaningful names & logical group/order

SELECT 
	ci.cst_id AS customer_id,
    	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
    	ci.cst_lastname AS last_name,
	cl.cntry AS country,
    	ci.cst_marital_status AS martial_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master source for gender
	ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
    	ci.cst_create_date AS create_date
 FROM silver.crm_cust_info AS ci
 LEFT JOIN silver.erp_cust_az12 AS ca
 ON ci.cst_key = ca.cid
 LEFT JOIN silver.erp_loc_a101 AS cl
 ON ci.cst_key = cl.cid

 -- Generate surrogate key for customer dimension

SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
   	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
   	ci.cst_lastname AS last_name,
	cl.cntry AS country,
    	ci.cst_marital_status AS martial_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master source for gender
	ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
    	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid


-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
    	ci.cst_lastname AS last_name,
	cl.cntry AS country,
    	ci.cst_marital_status AS martial_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master source for gender
	ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS birth_date,
    	ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS cl
ON ci.cst_key = cl.cid

-- POST VIEW CREATION - Quality Check

SELECT * FROM gold.dim_customers

SELECT DISTINCT gender FROM gold.dim_customers
