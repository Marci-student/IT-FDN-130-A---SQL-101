--*************************************************************************--
-- Title: Assignment06
-- Author: Marci DeLeon
-- Desc: This file demonstrates how to use Views
-- Change Log: 11/20/2021, Marci DeLeon, Completed qs 1-9.  Worked on Q10, but needs more.
--		11/21/2021, Marci DeLeon, Fixed 3-9 to use views and concanate names.
									--Finished Q10 and cleaned everything up.
-- 2021-11-21,MarciDeLeon,Created File
--**************************************************************************
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MarciDeLeon')
	 Begin 
	  Alter Database [Assignment06DB_MarciDeLeon] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MarciDeLeon;
	 End
	Create Database Assignment06DB_MarciDeLeon;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MarciDeLeon;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
/* Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*/
-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--Here's the view for the Category table.  I am grateful that the code at the bottom calls this
--vCategories, because that's what I would want to call it.
CREATE VIEW
	vCategories
--And we also need to SchemaBind to prevent table mucking about!  Which we do here.
WITH SCHEMABINDING
	AS
	--Here we indent, to show the select statement together
		SELECT 
			Categories.CategoryID, 
			Categories.CategoryName
			FROM
				dbo.Categories;
go
--Now, to make sure there's no mucking about with tables, we add Deny and Allow
DENY
	SELECT ON
		Categories
	TO PUBLIC;
GRANT
	SELECT ON
		vCategories
	TO PUBLIC;
go
--And, to cap it all off, let's look at our view to make sure it's good.
SELECT
	*
	FROM
		vCategories;
go

--And that's it, because as a basic view, we don't really want to do much more.
--I am literally going to just copy this code for the next three views.
--Product View!
CREATE VIEW
	vProducts
WITH SCHEMABINDING
	AS
		SELECT 
			Products.ProductID, 
			Products.ProductName,
			Products.CategoryID,
			Products.UnitPrice
			FROM
				dbo.Products;
go

DENY
	SELECT ON
		Products
	TO PUBLIC;
GRANT
	SELECT ON
		vProducts
	TO PUBLIC;
go

SELECT
	*
	FROM
		vProducts;
go

--Inventory View!
CREATE VIEW
	vInventories
WITH SCHEMABINDING
	AS
		SELECT 
			Inventories.InventoryID,
			Inventories.InventoryDate,
			Inventories.EmployeeID,
			Inventories.ProductID,
			Inventories.Count
			FROM
				dbo.Inventories;
go

DENY
	SELECT ON
		Inventories
	TO PUBLIC;
GRANT
	SELECT ON
		vInventories
	TO PUBLIC;
go

SELECT
	*
	FROM
		vInventories;
go
--Last but not least, Employee View!
CREATE VIEW
	vEmployees
WITH SCHEMABINDING
	AS
		SELECT 
			Employees.EmployeeID,
			Employees.EmployeeFirstName,
			Employees.EmployeeLastName,
			Employees.ManagerID
			FROM
				dbo.Employees;
go

DENY
	SELECT ON
		Employees
	TO PUBLIC;
GRANT
	SELECT ON
		vEmployees
	TO PUBLIC;
go

SELECT
	*
	FROM
		vEmployees;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Heh.  Well, I thought that was a basic part of the code, kind of like SchemaBinding, so I 
--included it in the code in question 1.  I still feel like that's a really good habit to 
--be in (as I am a workplace that is really into keeping everything), so I'm not going to 
--change my answer to Q1.  However, this is the code you're looking for.  I'm going to comment
--it out, because it's already in there, but here it is, from the views above.

/*DENY
	SELECT ON
		Categories
	TO PUBLIC;
GRANT
	SELECT ON
		vCategories
	TO PUBLIC;
go

DENY
	SELECT ON
		Products
	TO PUBLIC;
GRANT
	SELECT ON
		vProducts
	TO PUBLIC;
go

DENY
	SELECT ON
		Inventories
	TO PUBLIC;
GRANT
	SELECT ON
		vInventories
	TO PUBLIC;
go

DENY
	SELECT ON
		Employees
	TO PUBLIC;
GRANT
	SELECT ON
		vEmployees
	TO PUBLIC;
go
*/


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

--Now that we have a select statement, and that select statement is working, we will turn
--it into a view.
CREATE VIEW
--Here I use what I think it's called at the bottom.
	vProductsByCategories
	--Since Schema Binding is a good idea, I will put it in here.
	WITH SCHEMABINDING
	AS
--First, we create the select statement.  (This comment will wind up in the middle, but it's 
--the first thing to do. 
	SELECT
		vCategories.CategoryName,
		vProducts.ProductName,
		vProducts.UnitPrice
		FROM
--And here we start with the Product table, since there are two from that and one from Categories.
--I am using the two-part names here for the Schema Binding.
			dbo.vProducts
		INNER JOIN 
			dbo.vCategories
			ON
				vProducts.CategoryID = vCategories.CategoryID;
go
--I am very intentionally not putting an ORDER BY statement here.  As I have not been told
--to muck around with ORDER BYs where its not best practice, I am choosing to use best practice
--and ORDER the view after creation, not before.
--Also, because there is no table with this view's name, I don't really need to have permissions
--here.

--Now that the view has been created, I will look at it, and *here* is where I will order it.

SELECT 
	*
	FROM
		vProductsByCategories
		ORDER BY
			CategoryName,
			ProductName;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

--So we start with our starting place for creating views.
CREATE VIEW
	vInventoriesByProductsByDates
	WITH SCHEMABINDING
	AS
--Again, I create the select statement first, and will add the view code around it.
--As this is the code I made last week, I will nnot annotate save for changes.
		SELECT
			vProducts.ProductName, 
			vInventories.InventoryDate, 
			vInventories.Count
			FROM
				dbo.vProducts
			LEFT JOIN 
				dbo.vInventories
				ON
					vProducts.ProductID = vInventories.ProductID;
--Last week, I would have had an ORDER BY clause here.  This week, I am waiting.
go

--Now, we look at our view, and order it.
SELECT
	*
	FROM
		vInventoriesByProductsByDates
		ORDER BY
			ProductName,
			InventoryDate,
			Count;
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth


--And once the select statement is made, we create the view.
CREATE VIEW
	vInventoriesByEmployeesByDates
	WITH SCHEMABINDING
	AS
--The select statement that makes the view...
		SELECT DISTINCT 
			vInventories.InventoryDate, 
			vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName AS EmployeeName
--I need to add the two part names here.
			FROM
				dbo.vInventories
			INNER JOIN
				dbo.vEmployees
				ON
					vInventories.EmployeeID = vEmployees.EmployeeID;
go
--We end the view creation here, then see how it looks.
SELECT
	*
	FROM
		vInventoriesByEmployeesByDates
		ORDER BY
			InventoryDate;
go

-- Question 6 (10% pts): How can you create a view showing a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


--After we have a good select statement, let's turn this into a view.
CREATE VIEW
	vInventoriesByProductsByCategories
	WITH SCHEMABINDING
	AS
--Again, the code is taken from last week, so I will only annotate what is changed.
		SELECT
			vCategories.CategoryName,
			vProducts.ProductName,
			vInventories.InventoryDate,
			vInventories.Count
		FROM
--Adding in the two-part names.
			dbo.vProducts
--Now, the first join.
		INNER JOIN
			dbo.vCategories
			ON 
				vProducts.CategoryID = vCategories.CategoryID
		INNER JOIN
			dbo.vInventories
			ON
				vProducts.ProductID = vInventories.ProductID;
--And here we drop the ORDER BY to pick it up again when we do the actual
--looking at the view.
go

--Now to look and order.
SELECT
	*
	FROM
		vInventoriesByProductsByCategories
		ORDER BY
			CategoryName, 
			ProductName, 
			InventoryDate, 
			Count;
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan
CREATE VIEW
	vInventoriesByProductsByEmployees
	WITH SCHEMABINDING
	AS
--The select statement is taken from last week's code.
		SELECT
			vCategories.CategoryName,
			vProducts.ProductName,
			vInventories.InventoryDate,
			vInventories.Count,
			vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName AS EmployeeFullName
		FROM
--Let's add in the two-part names
			dbo.vCategories
		FULL JOIN
			dbo.vProducts
			ON 
				vCategories.CategoryID = vProducts.CategoryID
		FULL JOIN
			dbo.vInventories
			ON
				vProducts.ProductID = vInventories.ProductID
		INNER JOIN
			dbo.vEmployees
			ON
				vInventories.EmployeeID = vEmployees.EmployeeID;
go

--Then we look and order.
SELECT
	*
	FROM
		vInventoriesByProductsByEmployees
		ORDER BY
		InventoryDate,
		CategoryName,
		ProductName,
		EmployeeFullName;
go
		
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

CREATE VIEW
	vInventoriesForChaiAndChangByEmployees
	WITH SCHEMABINDING
	AS
--Select statement is taken from last week.  Annotations are for new stuff.
		SELECT
			vCategories.CategoryName,
			vProducts.ProductName,
			vInventories.InventoryDate,
			vInventories.Count,
			vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName AS EmployeeFullName
			FROM
				dbo.vCategories
			FULL JOIN
				dbo.vProducts
				ON 
					vCategories.CategoryID = vProducts.CategoryID
			FULL JOIN
				dbo.vInventories
				ON
					vProducts.ProductID = vInventories.ProductID
			INNER JOIN
				dbo.vEmployees
				ON
					vInventories.EmployeeID = vEmployees.EmployeeID
			WHERE
				vProducts.ProductName = 'Chai' 
				OR vProducts.ProductName = 'Chang';
go

SELECT
	*
		FROM
			vInventoriesForChaiAndChangByEmployees
			ORDER BY
				InventoryDate,
				ProductName;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are the rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

CREATE VIEW
	vEmployeesByManager
	WITH SCHEMABINDING
	AS
--The select statement is pulled from last week, sans order by clause.
		SELECT
			Man.EmployeeFirstName + ' ' + Man.EmployeeLastName AS Manager,
			Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName AS Employee
			FROM
				dbo.vEmployees AS Emp
			INNER JOIN
				dbo.vEmployees AS Man 
				ON
					Emp.ManagerID = Man.EmployeeID;
go

--Look and sort.
SELECT
	*
	FROM
		vEmployeesByManager
		ORDER BY
			Manager;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


CREATE VIEW
	vInventoriesByProductsByCategoriesByEmployees
	WITH SCHEMABINDING
		AS
--So here I have a select statement that has everything
			SELECT
				vCategories.CategoryID,
				vCategories.CategoryName,
				vProducts.ProductID,
				vProducts.ProductName,
				vProducts.UnitPrice,
				vInventories.InventoryID,
				vInventories.InventoryDate,
				vInventories.Count,
--I was having some trouble here using vEmployee, until I realized I should be using Emp.
				Emp.EmployeeID,
				Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName AS Employee,
				Man.EmployeeFirstName + ' ' + Man.EmployeeLastName AS Manager
--I was having an absolutely terrrible time trying to do the self join if I started with
--Categories as view 1, so I'm starting with the Employee view as view 1
				FROM
					dbo.vEmployees AS Emp
				INNER JOIN
					dbo.vEmployees AS Man 
					ON
						Emp.ManagerID = Man.EmployeeID
--Here I'm going to use inner joins to keep things moving quickly, but there's definitely
--an argument to be made for using full joins.
				INNER JOIN
					dbo.vInventories
					ON
						dbo.vInventories.EmployeeID = dbo.vInventories.EmployeeID
				INNER JOIN
					dbo.vProducts
					ON
						dbo.vInventories.ProductID = dbo.vProducts.ProductID
				INNER JOIN
					dbo.vCategories
					ON
						dbo.vProducts.CategoryID = dbo.vCategories.CategoryID;
go

SELECT
	*
	FROM
		vInventoriesByProductsByCategoriesByEmployees;
go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees];
go

/***************************************************************************************/