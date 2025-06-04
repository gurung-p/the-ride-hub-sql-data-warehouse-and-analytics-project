/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, and 
standardization across silver.crm_prd_info table following data import from 
bronze.crm_prd_info table.

Investigate and resolve any discrepancies found during the checks.
===================================================================================
*/


-- Check for nulls and duplicates in primary key
-- Expecation: No result, i.e. COUNT not greater than 1
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
having COUNT(*) > 1 OR prd_id IS NULL


-- Check for unwanted 'spaces'
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for nulls or negative numbers
SELECT prd_id, prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL


-- Data standardization & consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for any invalid DATE order
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

