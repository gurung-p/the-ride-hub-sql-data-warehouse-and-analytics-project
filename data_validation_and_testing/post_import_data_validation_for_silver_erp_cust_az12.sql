/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, and 
standardization across silver.erp_cust_az12 table following data import from 
bronze.erp_cust_az12 table.

Investigate and resolve any discrepancies found during the checks.
===================================================================================
*/


-- Identity out of range birth dates
-- Check for birthday in future

SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()


-- Data standardization & consistency

SELECT DISTINCT
gen
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12





