/*
===================================================================================
Data Validation 
===================================================================================
This script performs various quality checks for data consistency, accuracy, and 
standardization across silver.crm_cust_info table following data import from 
bronze.crm_cust_info table

Investigate and resolve any discrepancies found during the checks.
===================================================================================
*/


-- Check for nulls and duplicates in primary key
-- Expecation: No result, i.e. COUNT not greater than 1

SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
having COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted 'spaces'

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)


-- Data standardization & consistency

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT * FROM silver.crm_cust_info

