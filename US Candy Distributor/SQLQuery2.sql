select * from Factories

select count(distinct zip) from uszips

select * from Sales

select * from Products

-- Renaming columns in the Sales and Products tables
EXEC sp_rename 'Sales.Order ID', 'Order_ID', 'COLUMN';
EXEC sp_rename 'Sales.Order Date', 'Order_Date', 'COLUMN';
EXEC sp_rename 'Sales.Ship Date', 'Ship_Date', 'COLUMN';
EXEC sp_rename 'Sales.Ship Mode', 'Ship_Mode', 'COLUMN';
EXEC sp_rename 'Sales.Customer ID', 'Customer_ID', 'COLUMN';
EXEC sp_rename 'Sales.Product ID', 'Product_ID', 'COLUMN';
EXEC sp_rename 'Sales.Postal Code', 'Postal_Code', 'COLUMN';
EXEC sp_rename 'Sales.Gross Profit', 'Gross_Profit', 'COLUMN';
EXEC sp_rename 'Sales.Product Name', 'Product_Name', 'COLUMN';
EXEC sp_rename 'Sales.Country/Region', 'Country', 'COLUMN';


EXEC sp_rename 'Products.Product Name', 'Product_Name', 'COLUMN';
EXEC sp_rename 'Products.Unit Price', 'Unit_Price', 'COLUMN';
EXEC sp_rename 'Products.Product ID', 'Product_ID', 'COLUMN';
EXEC sp_rename 'Products.Unit Cost', 'Unit_Cost', 'COLUMN';


-- Adding a foreign key constraint between Sales and Products tables
ALTER TABLE Sales
ADD CONSTRAINT fk_product_sales
FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID);


-- Adding a foreign key constraint between Products and Factories tables
ALTER TABLE Products
ADD CONSTRAINT fk_factory_product
FOREIGN KEY (Factory) REFERENCES Factories(Factory);

-- Adding a foreign key constraint between Products and Targets tables
Alter Table Products
Add Constraint fk_product_target
FOREIGN KEY (Division) REFERENCES Targets(Division);

-- Adding a foreign key constraint between Sales and Targets tables
Alter Table Sales
Add Constraint fk_sales_target
FOREIGN KEY (Division) REFERENCES Targets(Division);





select  count(distinct Product_ID) from Sales 

select  count(distinct Order_ID) from Sales

-------------------------------------------------------------
-- Normalization in Sales Table (Customer_ID,Countery,City,State,Postal_Code,Region)
------------------------------------------------------------

select * from Sales


alter table Sales
drop column Product_Name

select count(*) from Sales


select count(distinct Customer_ID) from Sales

-- Creating a new Customer table
Create Table Customer (
Customer_ID int Not null ,
Countery varchar(50) ,
City varchar(50),
State varchar(50),
Postal_Code varchar(50),
Region varchar(50)

);

-- Populating Customer table with distinct customer data from Sales table
INSERT INTO Customer (Customer_ID, Countery,City,State,Postal_Code,Region)
SELECT DISTINCT s.Customer_ID, s.Country,s.City,s.[State/Province],s.Postal_Code,s.Region
FROM Sales s
WHERE s.Customer_ID IS NOT NULL;


select count(distinct Customer_ID) from Customer


-- Removing duplicate customers from the Customer table
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY Customer_ID) AS rn
    FROM Customer
)
DELETE FROM CTE WHERE rn > 1;

select count(*) from Customer

select * from Customer

-- Adding primary key to the Customer table
alter table Customer
add constraint pk_customer Primary Key (Customer_ID)

-- Updating the data type of Customer_ID in the Sales table to match the Customer table
ALTER TABLE Sales
ALTER COLUMN Customer_ID int;

-- Adding foreign key constraint between Sales and Customer tables
Alter Table Sales
Add Constraint fk_sales_coustomer
FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID);

-- Dropping the redundant customer-related columns from the Sales table
alter table Sales
drop column Country,City,[State/Province],Postal_Code,Region

 --Dropping the redundant Row ID column from the Sales table
alter table Sales
drop Column [Row ID]

select * from Sales




-- Adding new columns for year, month, and day extracted from the Order_Date column
ALTER TABLE Sales
ADD Order_Year INT, 
    Order_Month INT, 
    Order_Day INT;
---- Populating the new year, month, and day columns
UPDATE Sales
SET Order_Year = YEAR(Order_Date),
    Order_Month = MONTH(Order_Date),
    Order_Day = DAY(Order_Date);

-- Change the data type of the Order_Day column to varchar(50)
ALTER TABLE Sales
ALTER COLUMN Order_Day varChar(50);

-- Change the data type of the Order_Month column to varchar(50)
ALTER TABLE Sales
ALTER COLUMN Order_Month varChar(50);


select * from Sales

-- Update the Order_Day column with the full name of the day (e.g., "Friday")
Update Sales 
set Order_Day= FORMAT(Order_Date, 'dddd');

-- Update the Order_Month column with the abbreviated name of the month (e.g., "Jan")
Update Sales 
set Order_Month= FORMAT(Order_Date, 'MMM');

-----finish sales -----
-----------------------------------------

select * from uszips

---- Dropping unnecessary columns from the uszips table
alter table uszips 
drop column zcta,parent_zcta

alter table uszips 
drop column imprecise,military


--------------------------------
select * from Factories

---------------------------
-------Query-----------------------------


 select * from Sales

 select sum(Sales) as [Total Sales] from Sales

 select Order_Year, sum(Sales) as [Total Sales] from Sales
 group by Order_Year
 order by Order_Year


 --  Total Sales by Factory:
SELECT f.Factory, SUM(s.Sales) AS Total_Sales FROM Sales s
JOIN Products p ON s.Product_ID=p.Product_ID
JOIN Factories f ON p.Factory = f.Factory
GROUP BY f.Factory
ORDER BY Total_Sales DESC;

-- Total Sales ,Total Units,Total Cost,Total Profit  by Product
SELECT p.Product_Name, SUM(s.Units) AS Total_Units_Sold, SUM(s.Sales) AS Total_Sales,
sum(s.Cost) as Total_Cost, sum(s.Gross_Profit) as Total_Profit
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY Total_Units_Sold DESC;


--Total Sales by Division
select s.Division ,sum(s.Sales) from Sales s
group by s.Division


-- Factories with Highest Sales Growth (Month-to-Month Comparison)
SELECT f.Factory, 
       DATEPART(MONTH, s.Order_Date) AS SaleMonth, 
       SUM(s.Sales) AS Total_Sales
FROM Sales s
join Products p on p.Product_ID=s.Product_ID
JOIN Factories f ON p.Factory = f.Factory
GROUP BY f.Factory, DATEPART(MONTH, s.Order_Date)
ORDER BY f.Factory, SaleMonth;











 




