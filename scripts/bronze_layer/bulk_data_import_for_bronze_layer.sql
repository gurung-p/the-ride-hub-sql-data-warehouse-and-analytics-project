/*
===============================================================================
Script: Bulk import data for Bronze Layer
===============================================================================
This script bulk imports data from CRM & ERP csv files to Bronze Layer tables, 
clearing existing data in the tables if they already exist.
===============================================================================
*/


TRUNCATE TABLE bronze.crm_cust_info; -- EMPTY table / refresh table
BULK INSERT bronze.crm_cust_info
FROM 'C:\sql_data_warehouse_project\datasets\source_crm\cust_info.csv'
WITH (
	FIRSTROW = 2,           -- SKIP first row i.e. column header
	FIELDTERMINATOR = ',',  -- Values are separated by comma on source file
	TABLOCK                 -- Lock entire table during data loading
);


TRUNCATE TABLE bronze.crm_prd_info; 
BULK INSERT bronze.crm_prd_info
FROM 'C:\sql_data_warehouse_project\datasets\source_crm\prd_info.csv'
WITH (
	FIRSTROW = 2,           
	FIELDTERMINATOR = ',',  
	TABLOCK                 
);


TRUNCATE TABLE bronze.crm_sales_details; 
BULK INSERT bronze.crm_sales_details
FROM 'C:\sql_data_warehouse_project\datasets\source_crm\sales_details.csv'
WITH (
	FIRSTROW = 2,           
	FIELDTERMINATOR = ',',  
	TABLOCK                 
);


TRUNCATE TABLE bronze.erp_cust_az12; 
BULK INSERT bronze.erp_cust_az12
FROM 'C:\sql_data_warehouse_project\datasets\source_erp\CUST_AZ12.csv'
WITH (
	FIRSTROW = 2,           
	FIELDTERMINATOR = ',',  
	TABLOCK                 
);


TRUNCATE TABLE bronze.erp_loc_a101; 
BULK INSERT bronze.erp_loc_a101
FROM 'C:\sql_data_warehouse_project\datasets\source_erp\LOC_A101.csv'
WITH (
	FIRSTROW = 2,           
	FIELDTERMINATOR = ',',  
	TABLOCK                 
);


TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\sql_data_warehouse_project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
	FIRSTROW = 2,           
	FIELDTERMINATOR = ',',  
	TABLOCK                 
);
