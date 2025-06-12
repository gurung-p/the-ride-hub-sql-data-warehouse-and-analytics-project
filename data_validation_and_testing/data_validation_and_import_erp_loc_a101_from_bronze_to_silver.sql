/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, 
and standardization across bronze.erp_loc_a101 table.
   
Once the data is cleansed, it is imported to silver.erp_loc_a101 table.
===================================================================================
*/



-- Check data quality
-- Remove hyphen from cid

SELECT 
cid,
cntry
FROM bronze.erp_loc_a101

SELECT cst_key FROM silver.crm_cust_info 

-- Data standardization & consistency

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
order by cntry


------------FIX & INSERT-------------------------------------
-- Replace hyphen 
-- Fix empty space, null, abbreviations in country
-- Insert into 'silver.erp_loc_a101' table

INSERT INTO silver.erp_loc_a101 (cid, cntry)

SELECT 
REPLACE(cid, '-', '') AS cid,
CASE
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101

