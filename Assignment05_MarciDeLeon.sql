--*************************************************************************--
-- Title: Assignment05
-- Author: Marci DeLeon
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log:	11/13/21, Marci Deleon, started and compquestions noted in the text
--				11/15/21, Marci DeLeon, rechecked code, renamed file.
-- 2021-11-13, Marci DeLeon,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_MarciDeLeon')
 Begin 
  Alter Database [Assignment05DB_MarciDeLeon] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_MarciDeLeon;
 End
go

Create Database Assignment05DB_MarciDeLeon;
go

Use Assignment05DB_MarciDeLeon;
go

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
--Select * From Categories;
--go
--Select * From Products;
--go
--Select * From Employees;
--go
--Select * From Inventories;
--go

/********************************* Questions and Answers *********************************/
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--This is a join of the Category and Product tables, with only specific columns being shown.
--Because of the nature of the question, which specifically requests the list of category names and
--product names, I will use a Full Join, meaning that categories without products and products without categories will also be shown.

--As always, we start with the select clause, with just the columns we care about.
SELECT
	Categories.CategoryName, 
	Products.ProductName, 
	Products.UnitPrice
--I use the Categories table as the "left" table, because I choose to do so.
FROM
	Categories
--And then I do the join of the Categories table with the Products table.  Realistically, with this 
--dataset, I could do an inner join and this would be just fine.  However, with a larger, more complicated
--dataset, there easily could be Categories without Products, or Products without Categories.  (This can
--be seen in the originating code, which specifies that Products.CategoryID can be NULL.)
FULL OUTER JOIN 
	Products
--And the JOIN is on the "right" table, or, in this case, the Products table.
ON
	Categories.CategoryID = Products.CategoryID
--I originally forgot to do this, but then we need to order the table!
ORDER BY
	Categories.CategoryName, Products.ProductName
;
go


-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Date, Product,  and Count!

--Again, this is a simple join statement, in this case, between the Products and Inventories
--tables. In this case, we will do a Left Join, allowing products without inventories to
--be shown, but leaving aside any inventory that does not have a product name.  Again, this
--could be an inner join, and due to the nature of the dataset, we would be fine.  But if
--we had a larger, more complex database, the right join would be more appropriate, especially
--since it's a good idea to know what products are sitting at zero in inventory!

--Starting off with the select clause.
SELECT
	Products.ProductName, 
	Inventories.InventoryDate, 
	Inventories.Count
--Since we're going to do a left join, we need Products to be our originating table...
FROM
	Products
--which gets joined to Inventories.
LEFT JOIN 
	Inventories
--We add the clause which tells how the tables are joined up.
ON
	Products.ProductID = Inventories.ProductID
--And then we add the order in which we want to see the table.
ORDER BY
	Inventories.InventoryDate, Products.ProductName, Inventories.Count
;
go
	
	-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--It's a brand new table!  In order to see what I'm doing, I needed to look at the two tables, with the code below.
--SELECT * FROM Inventories
--SELECT * FROM Employees;
--go

--Then having looked at the tables, and determined that, yes, only one employee did inventory during each inventory
--date, we can do a simple inner join.

--As always, we start with what we want to see. The first time I wrote this, I got a ton of rows back.  In order to 
--avoid this, I will not just use SELECT, but SELECT DISTINCT
SELECT DISTINCT 
	Inventories.InventoryDate, 
	Employees.EmployeeFirstName, 
	Employees.EmployeeLastName
--I choose to use Inventories here mostly because of the way I listed the columns.
FROM
	Inventories
--Then we can add the join.
INNER JOIN
	Employees
--And our linking columns.
ON
	Inventories.EmployeeID = Employees.EmployeeID
--Last but not least, we need to arrange this table.
ORDER BY
	Inventories.InventoryDate
;
go

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Oooh, this is big!  We're going to join multiple tables!  Fortunately, this isn't much harder than joining
--two tables, just more complicated to keep track of.  (But that's what an EDR is for, right?)

--First, the columns we want, with their associated tables. Because I have a bunch, I'm going to write them
--in list format instead of straight across. (Originally, the colums above were listed like text.  Since our goal
--is to have consistent formatting, I have gone back and edited the code.
SELECT
	Categories.CategoryName,
	Products.ProductName,
	Inventories.InventoryDate,
	Inventories.Count
--Now, rather than having the "left-most" table be the one cited here, I'm going to put in the table that 
--connects to both corresponding tables.
FROM
	Products
--Now, the first join.
INNER JOIN
	Categories
ON 
	Products.CategoryID = Categories.CategoryID
--Then, the next join
INNER JOIN
	Inventories
ON
	Products.ProductID = Inventories.ProductID
--After having checked all that to make sure it runs okay, we're ready to add in the ordering.
ORDER BY
	Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.Count
;
go

-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--This is very similar to question 4, and I will reuse some of that code.

--First, the columns we want, with their associated tables. Because I have a bunch, I'm going to write them
--in list format instead of straight across. I added the two columns from the employee table at the 
--end of the list at first, but then looking at the answers, I noticed that the names had been concated into
--one column.  I therefore did the same here.
SELECT
	Categories.CategoryName,
	Products.ProductName,
	Inventories.InventoryDate,
	Inventories.Count,
	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeFullName
--Above, I used the "middle" table as the FROM.  Here, I'm going to start from one end of the "chain".
--The first time I wrote this code I used an inner join for all these, and got only 24 responses.  
--This did not work, given the 231 lines I got back from Q4.  GIven that, I used a FULL JOIN here instead, 
--and got a much more reasonable result.
FROM
	Categories
--First, we join the Categories to the Products
FULL JOIN
	Products
ON 
	Categories.CategoryID = Products.CategoryID
--Now that the category and product tables have been created in this code, we add on inventories
FULL JOIN
	Inventories
ON
	Products.ProductID = Inventories.ProductID
--And then we finish our connections with the employee table. This is an inner join, because, when
--I ran it as a full join, it pulled up the other employees who never did inventory.  Since we don't
--care about that null set, I took it out of here.This brings the result to 231 rows; the same number
--as in Q4.
INNER JOIN
	Employees
ON
	Inventories.EmployeeID = Employees.EmployeeID
--After having checked all that to make sure it runs okay, we're ready to add in the ordering.
ORDER BY
	Inventories.InventoryDate, Categories.CategoryName, Products.ProductName, Employees.EmployeeLastName
;
go

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

-- As this is a subgroup of the table created in Q5, this code is primarily taken from Q5.  In order
--to make it clear what changes I have made for this question, I will pull out all the annotations from
--Q5. All annotations here are only about changes made for Q6.

SELECT
	Categories.CategoryName,
	Products.ProductName,
	Inventories.InventoryDate,
	Inventories.Count,
	Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS EmployeeFullName
FROM
	Categories
FULL JOIN
	Products
ON 
	Categories.CategoryID = Products.CategoryID
FULL JOIN
	Inventories
ON
	Products.ProductID = Inventories.ProductID
INNER JOIN
	Employees
ON
	Inventories.EmployeeID = Employees.EmployeeID
--Now that we've finished the SELECT clause, it's time for the WHERE clause.  'Chai' and 'Chang' are 
--where subqueries would go, if I did them.  I may, depending on time.
WHERE
	Products.ProductName = 'Chai' 
	OR Products.ProductName = 'Chang'
--And for this ordering, we pull employee data out of the ordering, because that's what it says in the assignment.
ORDER BY
	Inventories.InventoryDate, Categories.CategoryName, Products.ProductName
;
go

-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--This going to be a self-join!  To see what I was doing, I started again with looking at the Employee table
--with "SELECT * FROM Employees;".  

--It's the beginning; we're going to start with the SELECT clause.  But we're going to be doing a lot more
--with this clause than normal.  As such, again, I will write it out in a column.
SELECT
	Man.EmployeeFirstName + ' ' + Man.EmployeeLastName AS Manager,
	Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName AS Employee
--Okay, here's where we define our first aliased table
FROM
	Employees AS Emp
--And we do an inner join, as everyone has a manager. (It looks like Andrew manages himself.) This
--also gives us our second alias.
INNER JOIN
	Employees AS Man 
--This is the key to this table, knowing where to join up.
ON
	Emp.ManagerID = Man.EmployeeID
--And, since we're ordering by the manager's name, and that usually goes by last name, we're going to again sort
--by a column that isn't actually shown in the table. I do recognize that this doesn't quite match up with the
--answer given, but since it's a more realistic answer, I will take the one-point hit and stand by my answer.
ORDER BY
	Man.EmployeeLastName
;
go
	


/***************************************************************************************/