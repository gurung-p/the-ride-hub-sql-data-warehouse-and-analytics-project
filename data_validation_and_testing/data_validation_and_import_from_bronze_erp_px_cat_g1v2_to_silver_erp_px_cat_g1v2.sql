/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, 
and standardization across bronze.erp_px_cat_g1v2 table.
   
Once the data is cleansed, it is imported to silver.erp_px_cat_g1v2 table.
===================================================================================
*/


-- Check data quality

SELECT * FROM bronze.erp_px_cat_g1v2

SELECT * FROM silver.crm_prd_info

-- Check for unwanted spaces

SELECT * FROM bronze.erp_px_cat_g1v2
where cat != TRIM(cat) 
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)


-- Data standardization & consistency

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2


-- Fix data quality
-- Insert into 'silver.erp_px_cat_g1v2' table

INSERT INTO SILVER.erp_px_cat_g1v2 (id, cat, subcat,maintenance)

SELECT 
	REPLACE (id, '_', '-') as id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2

