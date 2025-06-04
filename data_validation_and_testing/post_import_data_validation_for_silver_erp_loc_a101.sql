/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, and 
standardization across silver.erp_loc_a101 table following data import from 
bronze.erp_loc_a101

Investigate and resolve any discrepancies found during the checks.
===================================================================================
*/


-- Data standardization & consistency

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
order by cntry

SELECT * FROM silver.erp_loc_a101

