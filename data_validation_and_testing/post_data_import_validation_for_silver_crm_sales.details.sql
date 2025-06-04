/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, and 
standardization across silver.crm_sales_details table following data import from 
bronze.crm_sales_details table.

Investigate and resolve any discrepancies found during the checks.
===================================================================================
*/


-- Check for invalid date order i.e. order date not latest than ship or due date

SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt 


-- Check data consistency between sales, quantity & price
-- sales = quantity x price
-- Values must not be null, zero or negative

SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_sales
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT * FROM silver.crm_sales_details


