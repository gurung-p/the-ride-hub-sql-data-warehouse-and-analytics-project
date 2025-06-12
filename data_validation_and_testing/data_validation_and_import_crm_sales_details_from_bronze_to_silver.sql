/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, 
and standardization across bronze.crm_sales_details table.
   
Once the data is cleansed, it is imported to silver.crm_sales_details table.
===================================================================================
*/


-- Data quality check

SELECT 
	sls_ord_num,
	sls_prd_key,
    	sls_cust_id,
    	sls_order_dt,
   	 sls_ship_dt,
    	sls_due_dt,
    	sls_sales,
    	sls_quantity,
    	sls_price
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

SELECT 
	sls_ord_num,
	sls_prd_key,
    	sls_cust_id,
    	sls_order_dt,
    	sls_ship_dt,
    	sls_due_dt,
    	sls_sales,
    	sls_quantity,
    	sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT 
	sls_ord_num,
	sls_prd_key,
    	sls_cust_id,
    	sls_order_dt,
    	sls_ship_dt,
    	sls_due_dt,
    	sls_sales,
    	sls_quantity,
   	 sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Check for invalid dates
SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0


SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

SELECT 
NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8 
OR sls_ship_dt > 20500101
OR sls_ship_dt< 19000101

SELECT 
NULLIF(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
OR LEN(sls_due_dt) != 8 
OR sls_due_dt > 20500101
OR sls_due_dt< 19000101

-- Check for invalid date order
-- i.e order date not latest than ship or due date
SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt 

-- Check data consistency between sales, quantity & price
-- sales = quantity x price
-- Values must not be null, zero or negative

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_sales
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

--------FIX-------------------------------------------------
-- Check data consistency between sales, quantity & price
-- sales = quantity x price
-- Values must not be null, zero or negative

SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS ols_sls_price,

-- Sort SALES quality issue
CASE
	WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

-- Sort PRICE quality issue
CASE
	WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_sales
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


-- Insert cleansed data from Bronze to Silver Layer

-- Fix 0 as null and convert to DATE format
-- Fix sales & price data quality issue i.e negative, 0, Nulls, incorrect calc
-- INSERT clean data into Silver table 'silver.crm_sales_details'

INSERT INTO silver.crm_sales_details (
	sls_ord_num,
	sls_prd_key,
    	sls_cust_id,
    	sls_order_dt,
    	sls_ship_dt,
    	sls_due_dt,
    	sls_sales,
    	sls_quantity,
    	sls_price
)

SELECT 
	sls_ord_num,
	sls_prd_key,
   	sls_cust_id,
CASE
	WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE
	WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,
CASE
	WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,
CASE
	WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
    sls_quantity,
CASE
	WHEN sls_price IS NULL OR sls_price <= 0
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details





