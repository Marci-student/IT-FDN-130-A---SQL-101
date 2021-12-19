--*************************************************************************--
-- Title: Assignment07
-- Author: Marci DeLeon
-- Desc: This file demonstrates how to use Functions
-- Change Log:	11/27/21, Marci DeLeon, Answered Qs 1-6
--				11/28/21, Marci DeLeon, Answered Qs 7&8, cleaned up code.
-- 2017-11-28, Marci DeLeon, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_MarciDeLeon')
	 Begin 
	  Alter Database [Assignment07DB_MarciDeLeon] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_MarciDeLeon;
	 End
	Create Database Assignment07DB_MarciDeLeon;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_MarciDeLeon;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- Part 1: Let's show the list.
--SELECT
--	ProductName,
--	UnitPrice
--	FROM
--		vProducts;
--go

---- Part 2: Now we'll format that Unit Price.
--SELECT
--	ProductName,
--	FORMAT(
--		vProducts.UnitPrice, 'C')
--	FROM
--		vProducts;
--go

--Part 3: And then we order it!
--Note: When I was doing this work, the sections above were all active.
--Since I felt that you didn't need to slog through ten million tables
--just to grade this, I have commented all of the primary work out.  
--Feel free to comment it back in if you want to see if the interstitial
--steps work.
SELECT
	ProductName,
	FORMAT(
		UnitPrice, 'C')
	FROM
		vProducts
		ORDER BY
			ProductName
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

--Part 1: Create the initial table.
--SELECT
--	CategoryName,
--	ProductName,
--	UnitPrice
--	FROM
--		vCategories
--	INNER JOIN
--		vProducts 
--			ON
--				vCategories.CategoryID = vProducts.CategoryID;
--go

----Part 2: Formatting that UnitPrice, using the same code as in Q1.
--SELECT
--	CategoryName,
--	ProductName,
--	FORMAT(
--		UnitPrice, 'C')
--	FROM
--		vCategories
--	INNER JOIN
--		vProducts 
--			ON
--				vCategories.CategoryID = vProducts.CategoryID;
--go

--Part 3: And then we order it all.  Also, when I fiurst ran it,
--I realized that the Price column didn't have a name, so I gave
--it one.
SELECT
	CategoryName,
	ProductName,
	FORMAT(
		UnitPrice, 'C') 
			AS
				'UnitPrice'
	FROM
		vCategories
	INNER JOIN
		vProducts 
			ON
				vCategories.CategoryID = vProducts.CategoryID
		ORDER BY
			CategoryName,
			ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

----Part 1: Create the basic table
--SELECT
--	ProductName,
--	InventoryDate,
--	Count
--	FROM
--		vProducts
--	INNER JOIN
--		vInventories
--		ON
--			vProducts.ProductID = vInventories.ProductID;
--go

----Part 2a: So, that gets us the basic table.  Now I'm going to ignore
----the code above entirely and try to pull out that month and year.
--SELECT
--	DATENAME(month,InventoryDate),
--	YEAR(InventoryDate)
--	FROM
--		vInventories;
--go

----Part 2b: Now that I have the month and year in separate columns,
----I'll merge them together. This will require turning both of them
----into VarChars. I also need a title for this column, so I'll do
----that here.
--SELECT
--	CONCAT(
--		DATENAME(month,InventoryDate),
--		', ',
--		CAST(
--			YEAR(InventoryDate) AS nvarchar))
--		AS
--			'InventoryDate'
--	FROM
--		vInventories;
--go

----Part 3: Now that I have that figured out, I'll put it into the
----appropriate spot in Part 1's code.
--SELECT
--	ProductName,
--	CONCAT(
--		DATENAME(month,InventoryDate),
--		', ',
--		CAST(
--			YEAR(InventoryDate) AS nvarchar))
--		AS
--			'InventoryDate',
--	Count
--	FROM
--		vProducts
--	INNER JOIN
--		vInventories
--		ON
--			vProducts.ProductID = vInventories.ProductID;
--go

--Part 4: And then we order it! (Just putting "Inventory
--Date" in the ORDER BY statement ordered it by the
--concatenated version; using the two-part name seems to
--have allowed the ordering to go correctly.
SELECT
	ProductName,
	CONCAT(
		DATENAME(month,InventoryDate),
		', ',
		CAST(
			YEAR(InventoryDate) AS nvarchar))
		AS
			'InventoryDate',
	Count
	FROM
		vProducts
	INNER JOIN
		vInventories
		ON
			vProducts.ProductID = vInventories.ProductID
		ORDER BY
			ProductName,
			vInventories.InventoryDate
go


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--Part 1: Given that the view we're creating looks exactly like what we created
--in Q3, I'll be using that same code, but putting the CREATE VIEW statement
--around it.  I will keep the ORDER BY in there, so that will require some 
--fussing.

CREATE VIEW
	vProductInventories
	AS
		SELECT TOP 1000000000
			ProductName,
			CONCAT(
				DATENAME(month,InventoryDate),
				', ',
				CAST(
					YEAR(InventoryDate) AS nvarchar))
				AS
					'InventoryDate',
			Count
			FROM
				vProducts
			INNER JOIN
				vInventories
				ON
					vProducts.ProductID = vInventories.ProductID
				ORDER BY
					ProductName,
					vInventories.InventoryDate;
go

-- Check that it works: Select * From vProductInventories;

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

----Part 1: First, our simple table.
--SELECT
--	CategoryName,
--	InventoryDate,
--	Count
--	FROM
--		vCategories
--	INNER JOIN
--		vProducts
--		ON
--		vCategories.CategoryID = vProducts.CategoryID
--	INNER JOIN
--		vInventories
--		ON
--			vProducts.ProductID = vInventories.ProductID;
--go

----Part 2: We need to make that date format change.  Since the easiest thing
----is to just use our code from above, I'll copy it here.

--SELECT
--	CONCAT(
--		DATENAME(month,InventoryDate),
--		', ',
--		CAST(
--			YEAR(InventoryDate) AS nvarchar))
--		AS
--			'InventoryDate'
--	FROM
--		vInventories;
--go

----Part 3: Since I found it easier to code the date function separately,
----I'm going to work on just the inventory count here.

--SELECT
--	SUM(
--		vInventories.Count)
--		FROM
--			vCategories
--		INNER JOIN
--			vProducts
--			ON
--			vCategories.CategoryID = vProducts.CategoryID
--		INNER JOIN
--			vInventories
--			ON
--				vProducts.ProductID = vInventories.ProductID
--			GROUP BY
--				vCategories.CategoryName;
--go

----Part 4: That seems to have worked, so let's put parts 2 and 3 into
----part 1. Note: In order to make part 3 work by itself, I needed to 
----add all the join clauses into that select statement.  Since the 
----needed joins are already in the base statement, part 3 has been broken
----up into the select clause and the group by clause.
----Also, I need to add an ORDER BY clause and a name for the quantity
----column.
--SELECT
--	CategoryName,
--	CONCAT(
--		DATENAME(month,InventoryDate),
--		', ',
--		CAST(
--			YEAR(InventoryDate) AS nvarchar))
--		AS
--			'InventoryDate',
--	SUM(
--	vInventories.Count)
--		AS
--			'InventoryCountByCategory'
--	FROM
--		vCategories
--	INNER JOIN
--		vProducts
--		ON
--		vCategories.CategoryID = vProducts.CategoryID
--	INNER JOIN
--		vInventories
--		ON
--			vProducts.ProductID = vInventories.ProductID
--			GROUP BY
--				vCategories.CategoryName,
--				vInventories.InventoryDate
--				ORDER BY
--					vCategories.CategoryName,
--					vInventories.InventoryDate;
--go

--Part 5: Having determined that the code does what we want
--it to do, we create the view. Again, we are keeping the 
--ORDER BY clause and need to add the TOP clause.
CREATE VIEW
	vCategoryInventories
	AS
		SELECT TOP 10000000
		CategoryName,
		CONCAT(
			DATENAME(month,InventoryDate),
			', ',
			CAST(
				YEAR(InventoryDate) AS nvarchar))
			AS
				'InventoryDate',
		SUM(
		vInventories.Count)
			AS
				'InventoryCountByCategory'
		FROM
			vCategories
		INNER JOIN
			vProducts
			ON
			vCategories.CategoryID = vProducts.CategoryID
		INNER JOIN
			vInventories
			ON
				vProducts.ProductID = vInventories.ProductID
				GROUP BY
					vCategories.CategoryName,
					vInventories.InventoryDate
					ORDER BY
						vCategories.CategoryName,
						vInventories.InventoryDate;
go

-- Check that it works: Select * From vCategoryInventories;

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

--Part 1: Since I'm adding a column onto this view, my basic select 
--statement is going to be something like "SELECT * plus this new thing."
--Hence...

--SELECT
--	ProductName,
--	InventoryDate,
--	Count
--	FROM
--		vProductInventories;
--go

----Part 2: Now we need to fiddle around with a LAG function. Because
----my LAG function separates things by vInventories, I need to do some
----inner joins.  However, because vInventories.Count is NOT unique, I 
----will need to join multiple tables together.

--SELECT
--	vProductInventories.ProductName,
--	vProductInventories.InventoryDate,
--	vProductInventories.Count,
--	LAG(
--		vProductInventories.Count,1)
--		OVER(
--			PARTITION BY 
--				vProductInventories.ProductName
--			ORDER BY
--				vInventories.InventoryDate)
--		AS
--		'PreviousMonthCount'
--	FROM
--		vProductInventories
--	INNER JOIN
--		vProducts
--		ON
--		vProductInventories.ProductName = vProducts.ProductName
--	INNER JOIN
--		vInventories
--		ON
--		vProducts.ProductID = vInventories.InventoryID;
--go

----Part 3: Now that we've gotten that to work, we need to add in the
----"getting rid of null" part. That's going to surround the LAG code.

--SELECT
--	vProductInventories.ProductName,
--	vProductInventories.InventoryDate,
--	vProductInventories.Count,
--	ISNULL(
--		LAG(
--			vProductInventories.Count,1)
--			OVER(
--				PARTITION BY 
--					vProductInventories.ProductName
--				ORDER BY
--					vInventories.InventoryDate),
--		0)
--		AS
--		'PreviousMonthCount'
--	FROM
--		vProductInventories
--	INNER JOIN
--		vProducts
--		ON
--		vProductInventories.ProductName = vProducts.ProductName
--	INNER JOIN
--		vInventories
--		ON
--		vProducts.ProductID = vInventories.InventoryID;
--go

--Part 4: Huzzah!  It all works!  We create a view!
CREATE VIEW
	vProductInventoriesWithPreviousMonthCounts
	AS
		SELECT
		vProductInventories.ProductName,
		vProductInventories.InventoryDate,
		vProductInventories.Count,
		ISNULL(
			LAG(
				vProductInventories.Count,1)
				OVER(
					PARTITION BY 
						vProductInventories.ProductName
					ORDER BY
						vInventories.InventoryDate),
			0)
			AS
			'PreviousMonthCount'
		FROM
			vProductInventories
		INNER JOIN
			vProducts
			ON
			vProductInventories.ProductName = vProducts.ProductName
		INNER JOIN
			vInventories
			ON
			vProducts.ProductID = vInventories.InventoryID;
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;

--Part 1: Since we had so many problems with "*" in the last question, I will list out all the
----columns in our basic table.
--SELECT
--	ProductName,
--	InventoryDate,
--	Count,
--	PreviousMonthCount
--	FROM
--	vProductInventoriesWithPreviousMonthCounts;
--go

----Part 2: We need to create our KPI column. 

--SELECT
--	ProductName,
--	InventoryDate,
--	Count,
--	PreviousMonthCount,
--	[CountvsPreviousCountKPI] = CASE
--								WHEN PreviousMonthCount < vProductInventoriesWithPreviousMonthCounts.Count THEN 1
--								WHEN PreviousMonthCount = vProductInventoriesWithPreviousMonthCounts.Count THEN 0
--								WHEN PreviousMonthCount > vProductInventoriesWithPreviousMonthCounts.Count THEN -1
--								END
--	FROM
--	vProductInventoriesWithPreviousMonthCounts;
--go

--Part 3: The code works; let's create the view!
CREATE VIEW
	vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
		SELECT
			ProductName,
			InventoryDate,
			Count,
			PreviousMonthCount,
			[CountvsPreviousCountKPI] = CASE
										WHEN PreviousMonthCount < vProductInventoriesWithPreviousMonthCounts.Count THEN 1
										WHEN PreviousMonthCount = vProductInventoriesWithPreviousMonthCounts.Count THEN 0
										WHEN PreviousMonthCount > vProductInventoriesWithPreviousMonthCounts.Count THEN -1
										END
			FROM
			vProductInventoriesWithPreviousMonthCounts;
go

SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.

-- Part 1: We think it through.  the code we're going to use for our function is the same as the 
--code for Q7, so that's going to go into the "Begin -- End" section.
--First, we write out the basic coding for a multistatement table-valued function, and plug the 
--various bits of specific coding in.  This is commented out not because it works, but so you
--can see the scaffold I'm  building.

--CREATE FUNCTION Function_Name(@Parameter_Name Data_type, 
--                                 .... @Parameter_Name Data_type
--                             )
--RETURNS Data_Type
--AS
--   BEGIN
--      -- Function Body
      
--      RETURN Data 
--   END

--Part 2: We fill in this scaffold code with our own information.
CREATE FUNCTION
--Here we name our function
	fProductInventoriesWithPreviousMonthCountsWithKPIs	(@CvPCKPI INT)
--Now we tell the code what we want to see; in this case, a table with
--these data types.
	RETURNS
		@CntvPrevCnt TABLE(
			ProductName VarChar (100),
			InventoryDate VarChar (100),
			Count INT,
			PreviousMonthCount INT
			)
		AS
			BEGIN
				INSERT INTO
--Here we say how the table is to be populated.
					@CntvPrevCnt (
						ProductName,
						InventoryDate,
						Count,
						PreviousMonthCount
						)
				SELECT
				ProductName,
				InventoryDate,
				Count,
				PreviousMonthCount
					FROM
						vProductInventoriesWithPreviousMonthCountsWithKPIs
						WHERE
						CountvsPreviousCountKPI = @CvPCKPI
				RETURN
			END;
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/