# Analytica-3.0---Data-Analyst-Challenge-At-RV-University

Analytica 3.0 — Data Analyst Challenge, RV University
Solstice Retail Group (SRG) — People : Product : Process Audit

[Project Overview]:
This project was submitted for Analytica 3.0, a data analytics competition held at RV University.
The goal was to conduct a full diagnostic audit of Solstice Retail Group (SRG) — a retail company — and answer one core strategic question:

|"If Solstice Retail Group must make one major strategic change — either in PEOPLE, PRODUCT, or PROCESS — to achieve a 15% increase in Net Profit and a 1-point| |increase in Customer Satisfaction (CSAT), what should that change be?"                                                                                        |                  


[Tools Used]:
MySQL — Data cleaning and transformation
Power BI — Dashboard design, analysis, and visualization

[Dataset]:

Source: Analytica 3.0 competition dataset
File: Analytica 3.0 DataSet-1.xlsx
Tables cleaned: sales1, sale_channel, incentive_criteria, salary_structure, employee_info, customer_satisfaction, order_fulfillment_details


[Data Cleaning] (MySQL)
File: Cleaning - mysql code.sql
The raw dataset had several quality issues that were fixed using MySQL before loading into Power BI:

Removed 373 duplicate rows from the sales table
Standardized Sale_ID by stripping the ID- prefix and casting to integer
Cleaned currency columns (Unit_cost, Unit_Price) by removing $ signs and commas
Filled 134 null values in Sales_Rep with 'Unknown'
Standardized Gender values: M → Male, F → Female
Normalized Region by removing the  Region suffix
Converted Excel serial number dates to proper DATE format
Fixed column typo: Sale Timmings → Sale_Timings
Converted Promotion_Applied from boolean 0/1 to Yes/No
Standardized Employee_ID to uppercase across all tables


[Repository Files]
Analytica 3.0 DataSet-1.xlsx — Raw competition dataset
Cleaning - mysql code.sql — Full MySQL data cleaning scripts
Solstice Retail Group Dashboard.pdf — Power BI dashboard export (all pages)
Insights_and_Strategic_Verdict.pdf — Insights map and strategic recommendation

[Author]
pvnkumart-cyber
Analytica 3.0 — RV University
