-- ============================================================
--  Real_State_DB  |  Power BI Views
--  Run this script in SSMS against Real_State_DB
-- ============================================================

USE Real_State_DB;
GO

-- ============================================================
--  SECTION 1 : OVERVIEW
-- ============================================================

-- 1. Revenue Per Year
IF OBJECT_ID('dbo.vw_Revenue_Per_Year', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Revenue_Per_Year;
GO
CREATE VIEW dbo.vw_Revenue_Per_Year AS
SELECT
    YEAR(o.Booking_Date)               AS Years,
    SUM(CONVERT(BIGINT, u.Unit_Price)) AS Total_Rev_over_years
FROM Orders AS o
LEFT JOIN Units AS u ON o.Order_ID = u.Order_ID
GROUP BY YEAR(o.Booking_Date);
GO

-- ============================================================
--  SECTION 2 : ORDERS
-- ============================================================

-- 2. Orders Summary (duration + total orders)
IF OBJECT_ID('dbo.vw_Orders_Summary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Orders_Summary;
GO
CREATE VIEW dbo.vw_Orders_Summary AS
SELECT
    COUNT(Order_ID)  AS Total_Orders,
    AVG(Duration)    AS Avg_Duration
FROM Orders;
GO

-- 3. Main Category Distribution
IF OBJECT_ID('dbo.vw_Main_Category', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Main_Category;
GO
CREATE VIEW dbo.vw_Main_Category AS
SELECT
    Main_Category,
    COUNT(Main_Category) AS Count_of_Main_Category
FROM Orders
GROUP BY Main_Category;
GO

-- 4. Sub Category Revenue & Order Distribution
IF OBJECT_ID('dbo.vw_Sub_Category', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Sub_Category;
GO
CREATE VIEW dbo.vw_Sub_Category AS
SELECT
    o.Sub_Category_Unit_Type,
    SUM(CONVERT(BIGINT, u.Unit_Price)) AS Revenue_per_Sub_Category,
    COUNT(u.Order_ID)                  AS Order_Distribution
FROM Orders AS o
LEFT JOIN Units AS u ON o.Unit_ID = u.Unit_ID
GROUP BY o.Sub_Category_Unit_Type;
GO

-- 5. Most Popular Property Types (Final Category)
IF OBJECT_ID('dbo.vw_Property_Types', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Property_Types;
GO
CREATE VIEW dbo.vw_Property_Types AS
SELECT
    o.Final_Category,
    COUNT(u.Order_ID)                  AS Order_Distribution,
    SUM(CONVERT(BIGINT, u.Unit_Price)) AS Revenue_by_Category
FROM Units AS u
LEFT JOIN Orders AS o ON o.Order_ID = u.Order_ID
GROUP BY o.Final_Category;
GO

-- 6. Monthly Booking Trends
IF OBJECT_ID('dbo.vw_Monthly_Trends', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Monthly_Trends;
GO
CREATE VIEW dbo.vw_Monthly_Trends AS
SELECT
    YEAR(Booking_Date)  AS Years,
    MONTH(Booking_Date) AS Months,
    COUNT(Order_ID)     AS Orders_Around_Months
FROM Orders
GROUP BY YEAR(Booking_Date), MONTH(Booking_Date);
GO

-- ============================================================
--  SECTION 3 : UNITS
-- ============================================================

-- 7. Units Overview (totals + price stats)
IF OBJECT_ID('dbo.vw_Units_Overview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Units_Overview;
GO
CREATE VIEW dbo.vw_Units_Overview AS
SELECT
    COUNT(Unit_ID)         AS Total_Units_Sold,
    MIN(Unit_Price)        AS Min_Unit_Price,
    MAX(Unit_Price)        AS Max_Unit_Price,
    AVG(Price_Per_Meter)   AS AVG_Meter_Price
FROM Units;
GO

-- 8. Project-Level Revenue Report
IF OBJECT_ID('dbo.vw_Project_Revenue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Project_Revenue;
GO
CREATE VIEW dbo.vw_Project_Revenue AS
SELECT
    Project,
    SUM(CONVERT(BIGINT, Unit_Price))   AS Total_Revenues,
    AVG(CONVERT(BIGINT, Price_Per_Meter)) AS AVG_Meter_Price,
    COUNT(Unit_ID)                     AS Units_Sold
FROM Units
GROUP BY Project;
GO

-- ============================================================
--  SECTION 4 : SALES EMPLOYEES
-- ============================================================

-- 9. Sales Employee Overview
IF OBJECT_ID('dbo.vw_Sales_Overview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Sales_Overview;
GO
CREATE VIEW dbo.vw_Sales_Overview AS
SELECT
    SUM(Commission_Amount)                AS Commission_Spent,
    COUNT(DISTINCT Sales_Emp_ID)          AS Employees_Exist,
    SUM(CONVERT(BIGINT, Sales_Amount))    AS Total_Sales,
    AVG(Installment_Plan)                 AS Avg_Installment_Plan
FROM Sales_Emp;
GO

-- 10. Sales Rep Performance by Branch
IF OBJECT_ID('dbo.vw_Sales_By_Branch', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Sales_By_Branch;
GO
CREATE VIEW dbo.vw_Sales_By_Branch AS
SELECT
    Sales_Rep_Branch,
    COUNT(*)                                   AS Units_Distribution_by_Branch,
    SUM(CONVERT(BIGINT, Sales_Amount))         AS Total_Sales_by_Branch,
    SUM(CONVERT(BIGINT, Commission_Amount))    AS Total_Commission_by_Branch
FROM Sales_Emp
GROUP BY Sales_Rep_Branch;
GO

-- 11. Top 3 Branches by Sales (Ranked)
IF OBJECT_ID('dbo.vw_Top3_Branches_Ranked', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Top3_Branches_Ranked;
GO
CREATE VIEW dbo.vw_Top3_Branches_Ranked AS
WITH CTE AS (
    SELECT
        Sales_Rep_Branch,
        SUM(CONVERT(BIGINT, Sales_Amount)) AS Total_Sales
    FROM Sales_Emp
    GROUP BY Sales_Rep_Branch
),
Ranked AS (
    SELECT
        Sales_Rep_Branch,
        Total_Sales,
        RANK() OVER (ORDER BY Total_Sales DESC) AS Rnk
    FROM CTE
)
SELECT * FROM Ranked
WHERE Rnk <= 3;
GO

-- ============================================================
--  SECTION 5 : CUSTOMERS
-- ============================================================

-- 12. Customer Gender Distribution
IF OBJECT_ID('dbo.vw_Customer_Gender', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Customer_Gender;
GO
CREATE VIEW dbo.vw_Customer_Gender AS
SELECT
    Customer_Gender,
    COUNT(Customer_Gender) AS Gender_Count
FROM Customers
GROUP BY Customer_Gender;
GO

-- 13. Marital Status Distribution
IF OBJECT_ID('dbo.vw_Marital_Status', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Marital_Status;
GO
CREATE VIEW dbo.vw_Marital_Status AS
SELECT
    Marital_Status,
    COUNT(Marital_Status) AS Marital_Count
FROM Customers
GROUP BY Marital_Status;
GO

-- 14. Customer Nationality (with percentage)
IF OBJECT_ID('dbo.vw_Customer_Nationality', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Customer_Nationality;
GO
CREATE VIEW dbo.vw_Customer_Nationality AS
SELECT
    Customer_Nationality,
    COUNT(Customer_Nationality)                             AS Nationality_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Nationality_Percentage
FROM Customers
GROUP BY Customer_Nationality;
GO

-- 15. Customer Type Distribution
IF OBJECT_ID('dbo.vw_Customer_Type', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Customer_Type;
GO
CREATE VIEW dbo.vw_Customer_Type AS
SELECT
    Customer_Type,
    COUNT(Customer_Nationality) AS Count_Types
FROM Customers
GROUP BY Customer_Type;
GO

-- 16. Lead Source Distribution
IF OBJECT_ID('dbo.vw_Lead_Source', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Lead_Source;
GO
CREATE VIEW dbo.vw_Lead_Source AS
SELECT
    Lead_Source,
    COUNT(Lead_Source) AS Count_Leads
FROM Customers
GROUP BY Lead_Source;
GO

-- 17. Payment Type Distribution
IF OBJECT_ID('dbo.vw_Payment_Type', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Payment_Type;
GO
CREATE VIEW dbo.vw_Payment_Type AS
SELECT
    Payment_Type,
    COUNT(Payment_Type) AS Count_Payments
FROM Customers
GROUP BY Payment_Type;
GO

-- 18. Payment Behavior by Customer Type
IF OBJECT_ID('dbo.vw_Payment_Behavior', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Payment_Behavior;
GO
CREATE VIEW dbo.vw_Payment_Behavior AS
SELECT
    Customer_Type,
    Payment_Type,
    COUNT(Payment_Type) AS Payment_by_Type
FROM Customers
GROUP BY Customer_Type, Payment_Type;
GO

-- 19. Lead Sources by Revenue
IF OBJECT_ID('dbo.vw_Lead_Source_Revenue', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Lead_Source_Revenue;
GO
CREATE VIEW dbo.vw_Lead_Source_Revenue AS
SELECT
    c.Lead_Source,
    SUM(CONVERT(BIGINT, u.Unit_Price)) AS Revenue
FROM Customers AS c
RIGHT JOIN Units AS u ON c.Unit_ID = u.Unit_ID
GROUP BY c.Lead_Source;
GO

-- 20. Repeat Customers (bought 2+ units)
IF OBJECT_ID('dbo.vw_Repeat_Customers', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Repeat_Customers;
GO
CREATE VIEW dbo.vw_Repeat_Customers AS
SELECT
    Customer_Name,
    COUNT(Unit_ID) AS Units_Purchased
FROM Customers
GROUP BY Customer_Name
HAVING COUNT(Unit_ID) >= 2;
GO

-- 21. Age Group Segmentation
IF OBJECT_ID('dbo.vw_Age_Groups', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Age_Groups;
GO
CREATE VIEW dbo.vw_Age_Groups AS
SELECT
    COUNT(CASE WHEN Customer_Age BETWEEN 30 AND 39 THEN 1 END) AS [30-39],
    COUNT(CASE WHEN Customer_Age BETWEEN 40 AND 49 THEN 1 END) AS [40-49],
    COUNT(CASE WHEN Customer_Age >= 50              THEN 1 END) AS [50+]
FROM Customers;
GO

-- ============================================================
--  DONE — 21 views created successfully
--  Next step: Open Power BI Desktop
--             Home > Get Data > SQL Server
--             Connect to Real_State_DB
--             Select all vw_ views + raw tables
-- ============================================================
