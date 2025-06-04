# The Ride Hub - Data Warehouse & Analytics Project

## Project Background

Established in 2010, The Ride Hub has been a cornerstone of the cycling community, providing top-quality bicycles, accessories, and clothing to riders of all levels. Whether it’s high-performance bikes, essential accessories, or stylish and functional apparel, the shop prides itself on delivering quality, innovation, and reliability. The business uses different operational systems for Customer Relationship Management (CRM) and Enterprise Resource Planning (ERP). To create a unified view of the business, provide a single source of truth for reporting and analysis, data will be integrated and organized within a data warehouse. 

This project showcases a complete data warehousing and analytics solution, from constructing a data warehouse to deriving actionable insights. It emphasizes industry best practices in data engineering and analytics, transforming raw data into valuable insights that support informed, data-driven decisions.

---

## Project Objectives

1. **Data Architecture**: Setting up a modern data warehouse using Medallion Architecture, organizing data into Bronze, Silver, and Gold layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse for seamless integration.
3. **Data Modeling**: Developing fact and dimension tables to make analytical queries faster and efficient.
4. **Analytics & Reporting**: Building SQL-based reports that turn raw data into valuable insights.
5. **Analytics Dashboard**: Building an interactive data visualization dashboard in Power BI to display, track, and analyse key performance indicators (KPIs) and metrics.

---

## Project Requirements
### 1. Build Data Warehouse (Data Engineering)

Build a modern data warehouse with SQL Server to bring sales data together, making analytics and smarter decision-making easier.

- **Data Sources**: Import sales data from ERP and CRM systems, provided in CSV format.
- **Data Quality**: Perform cleansing and address data quality issues before analysis to ensure accuracy.
- **Integration**: Merge both datasets into a single, intuitive data model optimized for analytical queries.
- **Scope**: Focus exclusively on the most recent dataset, historical data storage is not required.
- **Documentation**: Provide clear documentation of the data model to support business users and analytics teams.

### 2. Business Intelligence: Analytics & Reporting (Data Analysis)

Develop SQL-driven analytics and data visualization using Power BI to uncover valuable insights. These insights provide stakeholders the key business metrics they need to make smart, strategic decisions.  

- **Sales Trends**
- **Product Performance**
- **Customer Behavior**

---

## Data Architecture & Data Flow Diagram

The data architecture for this project is built on **Medallion Architecture**, using **Bronze**, **Silver** and **Gold** layers:

1. **Bronze Layer**: Holds raw data exactly as it comes from source systems. CSV files are loaded into the SQL Server database.
2. **Silver Layer**: Cleans, standardizes, and normalizes the data to get it ready for analysis.
3. **Gold Layer**: Stores business-ready data, structured in a star schema for reporting and analytics.

The SQL queries for creating database called **DataWarehouse** and schemas for **Bronze**, **Silver** and **Gold** can be found [here](scripts/database_and_schemas/create_database_and_schemas.sql)

![image alt](images/High_Level_Architecture.png)

![image alt](images/Data_Flow_Diagram.png)

- The SQL queries to create tables and import data in the **Bronze Layer** from **CRM & ERP csv** can be found [here](scripts/bronze_layer)
- The SQL queries to create tables and import data in the **Silver Layer** from **Bronze Layer** can be found [here](scripts/silver_layer)
- The SQL queries to create dimension and fact view in the **Gold Layer** for **Customers**, **Products** and **Sales** can be found [here](scripts/gold_layer)
- The SQL queries used for **Data Validation & Testing** across the layers can be found [here](data_validation_and_testing)
  
---

## Data Structure & Data Type

The Ride Hub's database structure consists of three tables: **Sales**, **Customers** and **Products**. 

At the business level, the Gold Layer organizes data for effective analysis and reporting, featuring dimension tables and fact tables that define key business metrics.

![image alt](images/Entity_Relationship_Diagram.png)

![image alt](images/Data_Type.PNG)

---

## Analytics & Reporting 

This report provides an analysis of customer, product and sales data for The Ride Hub, focusing on key insights regarding customer demographics, sales and product performance including profitability. The analysis highlights significant trends over the years, customer distribution across various regions, and product performance metrics. Visualizations accompany the report to enhance understanding.

The SQL queries used to create **Reports and Analytics** can be found [here](reports_and_analytics)

Insights and recommendations are provided on the following key areas:

- **Sales Trends**
- **Product Performance**
- **Customer Behavior**

## **Sales Trends**

### Sales Trend Over Time

The sales overview dashboard presents a comprehensive look at a company’s performance over several years, focusing on key metrics including total sales, total costs, total profit, and total orders. There is a clear upward trend in sales and profit from 2010 to 2013, indicating strong business growth during that period. Total sales have shown an upward trend, from $6.20 million in 2010 to $20.74 million in 2013. Profit also increased significantly during this period from $2.46 million in 2010 to $8.28 million in 2013. A noticeable drop in sales is observed in 2014, as the business year has just begun and in progress. 

![image alt](images/total_sales_vs_profit_by_year.PNG)


### Total Saales by Category

Sales have been categorized into three main groups: bikes, clothing, and accessories. The majority of sales come from bikes, contributing significantly to the profit margins. The sales for Bikes in 2010 was $6.20 million Bikes and accessories appear to be the leading categories, with the latter experiencing consistent sales. Clothing had very little sales in 2012 but the sales is improving since. The data suggests strong demand for bikes particularly peaking in 2012 accounting for $18.58 million in sales. The Bikes category is dominant in sales, showcasing the need for continued investment in this segment.

