-- ============================================================
--  SALES DATA CLEANING — MySQL Scripts (In Order)
--  Table: sales1
-- ============================================================


-- ============================================================
-- STEP 0: BACKUP — Before touching anything
-- ============================================================

-- CREATE TABLE sales1_backup AS SELECT * FROM sales1;


-- ============================================================
-- STEP 1: DROP EXACT DUPLICATE ROWS  (373 duplicates)
-- ============================================================

-- ============================================================
-- FIX: Added a temporary id column first, then deleted duplicates
-- ============================================================

-- Step 1a: Add auto-increment id column to sales1
-- ALTER TABLE sales1 ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

-- Step 1b: Now running the duplicate delete


-- DELETE s1
-- FROM sales1 s1
-- INNER JOIN sales1 s2
--   ON  s1.`Customer Name` = s2.`Customer Name`
--   AND s1.Gender           = s2.Gender
--   AND s1.Age              = s2.Age
--   AND s1.`Phone Number`   = s2.`Phone Number`
--   AND s1.Sales_Rep        <=> s2.Sales_Rep
--   AND s1.Region           = s2.Region
--   AND s1.Unit_Sold        = s2.Unit_Sold
--   AND s1.Product_Category = s2.Product_Category
--   AND s1.Unit_cost        = s2.Unit_cost
--   AND s1.Unit_Price       = s2.Unit_Price
--   AND s1.Customer_Type    = s2.Customer_Type
--   AND s1.discount         = s2.discount
--   AND s1.Location         = s2.Location
--   AND s1.id               > s2.id;

-- Step 1c: Verify how many rows remain
-- SELECT COUNT(*) AS rows_after_dedup FROM sales1;

-- Step 1d: Drop the id column 
-- ALTER TABLE sales1 DROP COLUMN id;



-- ============================================================
-- STEP 2: STANDARDIZE Sale_ID
--         Remove 'ID-' prefix and whitespace, cast to integer
-- ============================================================

-- ALTER TABLE sales1 ADD COLUMN Sale_ID_clean INT;

-- UPDATE sales1
-- SET Sale_ID_clean = CAST(
--     TRIM(REPLACE(Sale_ID, 'ID-', ''))
--     AS UNSIGNED
-- );

-- Verify
-- SELECT COUNT(*) AS nulls FROM sales1 WHERE Sale_ID_clean IS NULL;

-- ALTER TABLE sales1 DROP COLUMN Sale_ID;
-- ALTER TABLE sales1 RENAME COLUMN Sale_ID_clean TO Sale_ID;


-- ============================================================
-- STEP 3: CLEAN Unit_cost  (remove $ and commas, cast to DECIMAL)
-- ============================================================

-- ALTER TABLE sales1 ADD COLUMN Unit_cost_clean DECIMAL(12,6);

-- UPDATE sales1
-- SET Unit_cost_clean = CAST(
--     REPLACE(REPLACE(TRIM(Unit_cost), '$', ''), ',', '')
--     AS DECIMAL(12,6)
-- );

-- Verify
-- SELECT COUNT(*) AS failed FROM sales1 WHERE Unit_cost_clean IS NULL;

-- ALTER TABLE sales1 DROP COLUMN Unit_cost;
-- ALTER TABLE sales1 RENAME COLUMN Unit_cost_clean TO Unit_cost;

-- Round Unit_cost to 0 decimal places
-- UPDATE sales1
-- SET Unit_cost = ROUND(Unit_cost, 0);
-- ============================================================
-- STEP 4: CLEAN Unit_Price  (remove $ and commas, cast to DECIMAL)
-- ============================================================

-- ALTER TABLE sales1 ADD COLUMN Unit_Price_clean DECIMAL(12,2);

-- UPDATE sales1
-- SET Unit_Price_clean = CAST(
--     REPLACE(REPLACE(TRIM(Unit_Price), '$', ''), ',', '')
--     AS DECIMAL(12,2)
-- );

-- Verify
-- SELECT COUNT(*) AS failed FROM sales1 WHERE Unit_Price_clean IS NULL;

-- ALTER TABLE sales1 DROP COLUMN Unit_Price;
-- ALTER TABLE sales1 RENAME COLUMN Unit_Price_clean TO Unit_Price;

-- Round Unit_Price to 0 decimal places
-- UPDATE sales1
-- SET Unit_Price = ROUND(Unit_Price, 0);
-- ============================================================
-- STEP 5: FILL MISSING Sales_Rep  (134 nulls → 'Unknown')
-- ============================================================

-- UPDATE sales1
-- SET Sales_Rep = 'Unknown'
-- WHERE Sales_Rep IS NULL OR TRIM(Sales_Rep) = '';

-- Strip whitespace from all rep names
-- UPDATE sales1
-- SET Sales_Rep = TRIM(Sales_Rep);


-- ============================================================
-- STEP 6: STANDARDIZE Gender  (M → Male, F → Female)
-- ============================================================

-- UPDATE sales1
-- SET Gender = CASE
--     WHEN TRIM(Gender) = 'M' THEN 'Male'
--     WHEN TRIM(Gender) = 'F' THEN 'Female'
--     ELSE TRIM(Gender)
-- END;

-- Verify 
-- SELECT Gender, COUNT(*) AS cnt FROM sales1 GROUP BY Gender;


-- ============================================================
-- STEP 7: NORMALIZE Region
--         Strip spaces + remove ' Region' suffix
-- ============================================================

-- UPDATE sales1
-- SET Region = TRIM(REPLACE(Region, ' Region', ''));

-- Verify 
-- SELECT Region, COUNT(*) AS cnt FROM sales1 GROUP BY Region ORDER BY cnt DESC;


-- ============================================================
-- STEP 8: CLEAN Customer Name  (strip whitespace + title case)
-- ============================================================

-- UPDATE sales1
-- SET `Customer Name` = CONCAT(
--     UPPER(LEFT(TRIM(`Customer Name`), 1)),
--     LOWER(SUBSTRING(TRIM(`Customer Name`), 2))
-- );


-- ============================================================
-- STEP 10: NORMALIZE Phone Number — digits only
-- ============================================================

-- UPDATE sales1
-- SET `Phone Number` = REGEXP_REPLACE(`Phone Number`, '[^0-9]', '');

-- Verify
-- SELECT `Phone Number`, COUNT(*) AS cnt
-- FROM sales1
-- WHERE `Phone Number` REGEXP '[^0-9]'
-- GROUP BY `Phone Number`;





-- ============================================================
--  TABLE NAME : sale_channel
-- ============================================================


-- ============================================================
-- STEP 0: BACKUP
-- ============================================================

-- CREATE TABLE sale_channel_backup AS SELECT * FROM sale_channel;


-- ============================================================
-- STEP 1: FIX Sale_ID
--         513 rows have 'ID-' prefix
--         487 rows have leading/trailing spaces
-- ============================================================

-- ALTER TABLE sale_channel ADD COLUMN Sale_ID_clean INT;

-- UPDATE sale_channel
-- SET Sale_ID_clean = CAST(
--     TRIM(REPLACE(Sale_ID, 'ID-', ''))
--     AS UNSIGNED
-- );

-- Verify no nulls
-- SELECT COUNT(*) AS nulls FROM sale_channel WHERE Sale_ID_clean IS NULL;

-- ALTER TABLE sale_channel DROP COLUMN Sale_ID;
-- ALTER TABLE sale_channel RENAME COLUMN Sale_ID_clean TO Sale_ID;




-- ============================================================
-- STEP 3: RENAME column 'Sale Timmings' → 'Sale_Timings'
--         (typo fix: double 'm', and add underscore)
-- ============================================================

-- ALTER TABLE sale_channel
-- RENAME COLUMN `Sale Timmings` TO Sale_Timings;


-- ============================================================
-- STEP 4: STANDARDIZE Sale_Timings to TIME format
--         Currently stored as VARCHAR '10:55'
--         Convert to proper TIME type
-- ============================================================

-- ALTER TABLE sale_channel ADD COLUMN Sale_Timings_clean TIME;

-- UPDATE sale_channel
-- SET Sale_Timings_clean = STR_TO_DATE(Sale_Timings, '%H:%i');

-- Verify no nulls
-- SELECT COUNT(*) AS invalid_times
-- FROM sale_channel
-- WHERE Sale_Timings_clean IS NULL;

-- ALTER TABLE sale_channel DROP COLUMN Sale_Timings;
-- ALTER TABLE sale_channel RENAME COLUMN Sale_Timings_clean TO Sale_Timings;


-- STEP 1: Check current column type
-- DESCRIBE sale_channel;

-- STEP 2: Add a proper DATE column
-- ALTER TABLE sale_channel ADD COLUMN Sale_Date_clean DATE;

-- STEP 3: Convert the serial number to proper DATE
-- UPDATE sale_channel
-- SET Sale_Date_clean = DATE_ADD('1899-12-30', INTERVAL Sale_Date DAY);

-- STEP 4: Verify conversion looks correct
-- SELECT Sale_Date, Sale_Date_clean FROM sale_channel LIMIT 10;

-- STEP 5: drop old and rename
-- ALTER TABLE sale_channel DROP COLUMN Sale_Date;
-- ALTER TABLE sale_channel RENAME COLUMN Sale_Date_clean TO Sale_Date;

-- STEP 6: final output
-- SELECT Sale_ID, Sale_Date FROM sale_channel LIMIT 10;




-- ============================================================
--  TABLE NAME  : Region_Sales_Rep -- CLEANED 
-- ============================================================

-- ============================================================
--  TABLE NAME : Sales_Rep_Shifts 
-- ============================================================


-- STEP 0: Backup
-- CREATE TABLE sales_rep_shifts_backup AS SELECT * FROM sales_rep_shifts;


-- STEP 1: Rename 'Sales Representative' → Sales_Rep
-- ALTER TABLE sales_rep_shifts
-- RENAME COLUMN `Sales Representative` TO Sales_Rep;


-- STEP 2: Add clean TIME columns
-- ALTER TABLE sales_rep_shifts ADD COLUMN Start_Time_clean TIME;
-- ALTER TABLE sales_rep_shifts ADD COLUMN End_Time_clean   TIME;


-- STEP 3: Convert decimal → proper TIME
-- UPDATE sales_rep_shifts
-- SET Start_Time_clean = SEC_TO_TIME(ROUND(`Start Time` * 86400)),
--     End_Time_clean   = SEC_TO_TIME(ROUND(`End Time`   * 86400));

-- STEP 4: Verify 
-- SELECT Sales_Rep, Shift,
--        `Start Time`, Start_Time_clean,
--        `End Time`,   End_Time_clean
-- FROM sales_rep_shifts;

-- STEP 5: Droping old columns
-- ALTER TABLE sales_rep_shifts DROP COLUMN `Start Time`;
-- ALTER TABLE sales_rep_shifts DROP COLUMN `End Time`;

-- STEP 6: Rename clean columns
-- ALTER TABLE sales_rep_shifts RENAME COLUMN Start_Time_clean TO Start_Time;
-- ALTER TABLE sales_rep_shifts RENAME COLUMN End_Time_clean   TO End_Time;

-- FINAL: Verify
-- SELECT * FROM sales_rep_shifts;



-- ============================================================
--  TABLE NAME : Incentive Criteria
-- ============================================================


-- STEP 0: Backup
-- CREATE TABLE incentive_criteria_backup AS SELECT * FROM `incentive criteria`;

-- STEP 1: Rename all columns to proper names
-- ALTER TABLE `incentive criteria`
-- RENAME COLUMN `Product Category`    TO Product_Category,
-- RENAME COLUMN `Sales`               TO Sales_Range,
-- RENAME COLUMN `Incentive Received`  TO Junior,
-- RENAME COLUMN `MyUnknownColumn`     TO Mid_level,
-- RENAME COLUMN `MyUnknownColumn_[0]` TO Senior;

-- STEP 2: Delete the bad header row
-- DELETE FROM `incentive criteria`
-- WHERE Junior = 'junior';

-- Verify 
-- SELECT * FROM `incentive criteria` LIMIT 5;

-- STEP 3: Add id column for forward-fill
-- ALTER TABLE `incentive criteria`
-- ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- STEP 4: Forward-fill Product_Category nulls
-- SET @cat := NULL;

-- UPDATE `incentive criteria`
-- SET Product_Category = CASE
--     WHEN Product_Category IS NOT NULL AND TRIM(Product_Category) != ''
--         THEN (@cat := Product_Category)
--     ELSE @cat
-- END
-- ORDER BY id;

-- STEP 5: Fix Product_Category casing
-- UPDATE `incentive criteria`
-- SET Product_Category = CASE
--     WHEN LOWER(TRIM(Product_Category)) = 'electronic' THEN 'Electronics'
--     WHEN LOWER(TRIM(Product_Category)) = 'food'       THEN 'Food'
--     WHEN LOWER(TRIM(Product_Category)) = 'clothes'    THEN 'Clothes'
--     WHEN LOWER(TRIM(Product_Category)) = 'furniture'  THEN 'Furniture'
--     ELSE Product_Category
-- END;

-- STEP 6: Check the null Sales_Range row
-- SELECT * FROM `incentive criteria` WHERE Sales_Range IS NULL;

-- FINAL: Verify 
-- SELECT * FROM `incentive criteria` ORDER BY id;



-- ============================================================
--  TABLE NAME : Salary_Structure 
-- ============================================================


-- STEP 0: Backup
-- CREATE TABLE salary_structure_backup AS SELECT * FROM `salary structure`;

-- STEP 2: Rename columns to proper names
-- ALTER TABLE `salary structure`
-- RENAME COLUMN `Employee ID`    TO Employee_ID,
-- RENAME COLUMN `Name`           TO Employee_Name,
-- RENAME COLUMN `Base Salary (?)` TO Base_Salary;

-- STEP 3: Delete the fake header row
-- (the row where Employee_ID = 'Employee ID')
-- DELETE FROM `salary structure`
-- WHERE Employee_ID = 'Employee ID';

-- STEP 4: Delete the total row at the bottom
-- (no Employee_ID but has salary sum 6050000)
-- DELETE FROM `salary structure`
-- WHERE Employee_ID IS NULL
-- OR TRIM(Employee_ID) = '';

-- STEP 5: Standardize Employee_ID → all UPPERCASE
-- Emp101 → EMP101, Emp102 → EMP102
-- UPDATE `salary structure`
-- SET Employee_ID = UPPER(Employee_ID);

-- STEP 6: Fix Base_Salary column type → INT
-- ALTER TABLE `salary structure`
-- MODIFY COLUMN Base_Salary INT;

-- FINAL: Verify
-- SELECT * FROM `salary structure` ORDER BY Employee_ID;

-- Null check
-- SELECT
--     SUM(CASE WHEN Employee_ID   IS NULL THEN 1 ELSE 0 END) AS null_emp_id,
--     SUM(CASE WHEN Employee_Name IS NULL THEN 1 ELSE 0 END) AS null_name,
--     SUM(CASE WHEN Base_Salary   IS NULL THEN 1 ELSE 0 END) AS null_salary
-- FROM `salary structure`;



-- ============================================================
--  TABLE NAME : Employee_Info
-- ============================================================

-- STEP 0: Backup
-- CREATE TABLE employee_info_backup AS SELECT * FROM employee_info;

-- STEP 2: Rename columns → proper naming convention
-- ALTER TABLE employee_info
-- RENAME COLUMN `Employee ID`     TO Employee_ID,
-- RENAME COLUMN `Employee Name`   TO Employee_Name,
-- RENAME COLUMN `Job title`       TO Job_Title,
-- RENAME COLUMN `Date of Joining` TO Date_of_Joining;

-- STEP 3: Standardize Employee_ID → all UPPERCASE
-- UPDATE employee_info
-- SET Employee_ID = UPPER(Employee_ID);

-- Verify it matches salary structure
-- SELECT e.Employee_ID, s.Employee_ID AS salary_emp_id
-- FROM employee_info e
-- LEFT JOIN `salary structure` s ON e.Employee_ID = s.Employee_ID
-- WHERE s.Employee_ID IS NULL;
-- Should return 0 rows

-- STEP 4: Expand Gender M/F → Male/Female
-- UPDATE employee_info
-- SET Gender = CASE
--     WHEN TRIM(Gender) = 'M' THEN 'Male'
--     WHEN TRIM(Gender) = 'F' THEN 'Female'
--     ELSE Gender
-- END;

-- STEP 5: Fix trailing space in Job_Title
-- UPDATE employee_info
-- SET Job_Title = TRIM(Job_Title);

-- STEP 6: Convert Date_of_Joining from serial INT → proper DATE
-- ALTER TABLE employee_info ADD COLUMN Date_of_Joining_clean DATE;

-- UPDATE employee_info
-- SET Date_of_Joining_clean = DATE_ADD('1899-12-30', INTERVAL Date_of_Joining DAY);

-- Verify conversion looks correct
-- SELECT Employee_ID, Employee_Name, Date_of_Joining, Date_of_Joining_clean
-- FROM employee_info;

-- Once verified drop old and rename
-- ALTER TABLE employee_info DROP COLUMN Date_of_Joining;
-- ALTER TABLE employee_info RENAME COLUMN Date_of_Joining_clean TO Date_of_Joining;

-- FINAL: Verification
-- SELECT * FROM employee_info ORDER BY Employee_ID;

-- SELECT COUNT(*) AS total_rows FROM employee_info;

-- Null check
-- SELECT
--     SUM(CASE WHEN Employee_ID     IS NULL THEN 1 ELSE 0 END) AS null_emp_id,
--     SUM(CASE WHEN Employee_Name   IS NULL THEN 1 ELSE 0 END) AS null_name,
--     SUM(CASE WHEN Gender          IS NULL THEN 1 ELSE 0 END) AS null_gender,
--     SUM(CASE WHEN Job_Title       IS NULL THEN 1 ELSE 0 END) AS null_jobtitle,
--     SUM(CASE WHEN Date_of_Joining IS NULL THEN 1 ELSE 0 END) AS null_doj
-- FROM employee_info;


-- ============================================================
--  TABLE NAME : Customer_Satisfaction
-- ============================================================

-- STEP 0: Backup
-- CREATE TABLE customer_satisfaction_backup AS SELECT * FROM customer_satisfaction;

-- STEP 1: Rename column → proper naming convention
-- ALTER TABLE customer_satisfaction
-- RENAME COLUMN `customer satisfaction` TO Customer_Satisfaction;

-- STEP 2: Fix Sale_ID from text → INT
-- ALTER TABLE customer_satisfaction ADD COLUMN Sale_ID_clean INT;

-- UPDATE customer_satisfaction
-- SET Sale_ID_clean = CAST(TRIM(Sale_ID) AS UNSIGNED);

-- Verify no nulls
-- SELECT COUNT(*) AS nulls FROM customer_satisfaction WHERE Sale_ID_clean IS NULL;

-- ALTER TABLE customer_satisfaction DROP COLUMN Sale_ID;
-- ALTER TABLE customer_satisfaction RENAME COLUMN Sale_ID_clean TO Sale_ID;

-- STEP 3: Verify all satisfaction values are valid
-- SELECT Customer_Satisfaction, COUNT(*) AS cnt
-- FROM customer_satisfaction
-- GROUP BY Customer_Satisfaction
-- ORDER BY cnt DESC;

-- STEP 4: Check Sale_ID coverage against sales1
-- SELECT cs.Sale_ID
-- FROM customer_satisfaction cs
-- LEFT JOIN sales1 s ON cs.Sale_ID = s.Sale_ID
-- WHERE s.Sale_ID IS NULL;


-- ============================================================
--  TABLE NAME : Order_Fulfillment_Details 
-- ============================================================


-- STEP 0: Backup
-- CREATE TABLE order_fulfilment_backup AS 
-- SELECT * FROM order_fullfillment_details;


-- STEP 1: Check exact column names
-- DESCRIBE order_fullfillment_details;
-- SELECT * FROM order_fullfillment_details LIMIT 10;


-- STEP 2: Rename columns → proper naming convention
-- ALTER TABLE order_fullfillment_details
-- RENAME COLUMN `promotion Applied` TO Promotion_Applied,
-- RENAME COLUMN `Delivery Time`     TO Delivery_Time;


-- STEP 3: Fix Sale_ID — check if stored as text or INT
-- If text, convert to INT
-- ALTER TABLE order_fullfillment_details 
-- ADD COLUMN Sale_ID_clean INT;

-- UPDATE order_fullfillment_details
-- SET Sale_ID_clean = CAST(TRIM(Sale_ID) AS UNSIGNED);

-- Verify no nulls
-- SELECT COUNT(*) AS nulls 
-- FROM order_fullfillment_details 
-- WHERE Sale_ID_clean IS NULL;

-- ALTER TABLE order_fullfillment_details DROP COLUMN Sale_ID;
-- ALTER TABLE order_fullfillment_details 
-- RENAME COLUMN Sale_ID_clean TO Sale_ID;


-- STEP 4: Fill Event nulls → 'No Event'
-- UPDATE order_fullfillment_details
-- SET Event = 'No Event'
-- WHERE Event IS NULL OR TRIM(Event) = '';

-- Verify
-- SELECT Event, COUNT(*) AS cnt
-- FROM order_fullfillment_details
-- GROUP BY Event;

-- STEP 5: Fill Shipping_Method nulls → 'Unknown'
-- UPDATE order_fullfillment_details
-- SET Shipping_Method = 'Unknown'
-- WHERE Shipping_Method IS NULL OR TRIM(Shipping_Method) = '';

-- Verify
-- SELECT Shipping_Method, COUNT(*) AS cnt
-- FROM order_fullfillment_details
-- GROUP BY Shipping_Method;


-- STEP 6: Fill Delivery_Time nulls → 0
-- UPDATE order_fullfillment_details
-- SET Delivery_Time = 0
-- WHERE Delivery_Time IS NULL;

-- Verify no nulls remain
-- SELECT COUNT(*) AS nulls 
-- FROM order_fullfillment_details 
-- WHERE Delivery_Time IS NULL;


-- STEP 7: Cast Delivery_Time float → INT
-- ALTER TABLE order_fullfillment_details
-- MODIFY COLUMN Delivery_Time INT;


-- STEP 8: Convert Promotion_Applied bool → Yes/No
-- First change column type to VARCHAR
-- ALTER TABLE order_fullfillment_details
-- MODIFY COLUMN Promotion_Applied VARCHAR(3);

-- UPDATE order_fullfillment_details
-- SET Promotion_Applied = CASE
--     WHEN Promotion_Applied = '1' THEN 'Yes'
--     WHEN Promotion_Applied = '0' THEN 'No'
--     ELSE Promotion_Applied
-- END;

-- Verify
-- SELECT Promotion_Applied, COUNT(*) AS cnt
-- FROM order_fullfillment_details
-- GROUP BY Promotion_Applied;


-- STEP 9: Check Sale_ID coverage against sales1
-- SELECT o.Sale_ID
-- FROM order_fullfillment_details o
-- LEFT JOIN sales1 s ON o.Sale_ID = s.Sale_ID
-- WHERE s.Sale_ID IS NULL;
