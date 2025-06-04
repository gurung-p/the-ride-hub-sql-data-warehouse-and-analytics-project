/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, 
and standardization across bronze.crm_prd_info table.
   
Once the data is cleansed, it is imported to silver.crm_prd_info table.
===================================================================================
*/


-- Check for nulls and duplicates in primary key
-- Expecation: No result, i.e. COUNT not greater than 1
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
having COUNT(*) > 1 OR prd_id IS NULL


-- Check for unwanted 'spaces'
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)


-- Check for nulls or negative numbers
SELECT prd_id, prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL


-- Data standardization & consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for any invalid DATE order
SELECT * FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- Insert cleansed data from Bronze to Silver Layer

INSERT INTO silver.crm_prd_info (
	prd_id,		
	cat_id,		
	prd_key,		
	prd_nm,		
	prd_cost,		
	prd_line,		
	prd_start_dt,	
	prd_end_dt
)

SELECT 
	prd_id,
	SUBSTRING(prd_key, 1, 5) AS cat_id, -- start extraction from left i.e. 1, up to 5 char
	SUBSTRING (prd_key, 7, LEN(prd_key)) AS prd_key, -- start extraction from left i.e. 7, include everything
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost, -- replace null value with 0 
CASE	
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END AS prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt, -- CONVERT from DATETIME TO DATE, as time had no value, all zeros
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info


