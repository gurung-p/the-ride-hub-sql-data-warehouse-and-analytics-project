/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, 
and standardization across bronze.erp_cust_az12 table.
   
Once the data is cleansed, it is imported to silver.erp_cust_az12 table.
===================================================================================
*/



-- Identity out of range birth dates
-- Check for very old customer & birthday in future

SELECT DISTINCT
	bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data standardization & consistency

SELECT DISTINCT
gen
FROM bronze.erp_cust_az12


-------FIX & INSERT--------------------------------

-- Remove 'NAS' from cid
-- Replace birth dates in future dates with NULL
-- Replace null, spaces and abbreviated values for gender
-- Insert into 'silver.erp_cust_az12' table

INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)

SELECT 
CASE	
	WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	ELSE cid
END AS cid,
CASE
	WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END AS bdate,
CASE
	WHEN UPPER(TRIM(gen)) IN ('F' , 'FEMALE') THEN 'Female'
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12




