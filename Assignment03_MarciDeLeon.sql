--*************************************************************************--
-- Title: Assignment03 
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: MDeLeon
-- Change Log: When,Who,What
--10/28/21, Marci DeLeon, Created Database and answered questions 1-4 with annotations.
--10/30/21, Marci DeLeon, answered questions 5 and 6, worked on question 7, am stuck on the subquery.
--10/31/21, Marci DeLeon, finished questions 7-10.  Also cleaned up code and checked.
-- 10/31/21,Marci DeLeon,Completed File
--**************************************************************************--

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment03DB_MarciDeLeon')
  Begin
  	Use [master];
	  Alter Database Assignment03DB_MarciDeLeon Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment03DB_MarciDeLeon;
  End
go
Create Database Assignment03DB_MarciDeLeon;
go
Use Assignment03DB_MarciDeLeon
go

--[ Create the Tables ]--
--********************************************************************--
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL
,[ProductName] [nvarchar](100) NOT NULL
,[ProductCurrentPrice] [money] NOT NULL
,[CategoryID] [int] NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[InventoryCount] [int] NULL
,[ProductID] [int] NOT NULL
);
go

--[ Add Addtional Constaints ]--
--********************************************************************--
ALTER TABLE dbo.Categories
	ADD CONSTRAINT pkCategories PRIMARY KEY CLUSTERED (CategoryID);
go
ALTER TABLE dbo.Categories 
	ADD CONSTRAINT uCategoryName UNIQUE NonCLUSTERED (CategoryName);
go

ALTER TABLE dbo.Products
	ADD CONSTRAINT pkProducts PRIMARY KEY CLUSTERED (ProductID);
go
ALTER TABLE dbo.Products
	ADD CONSTRAINT uProductName UNIQUE NonCLUSTERED (ProductName);
go
ALTER TABLE dbo.Products  
	ADD CONSTRAINT fkProductsCategories  
		FOREIGN KEY (CategoryID)
		REFERENCES dbo.Categories (CategoryID);
go
ALTER TABLE dbo.Products  
	ADD CONSTRAINT pkProductsProductCurrentPriceZeroOrMore CHECK (ProductCurrentPrice > 0);
go

ALTER TABLE dbo.Inventories
	ADD CONSTRAINT pkInventories PRIMARY KEY CLUSTERED (InventoryID);
go
ALTER TABLE dbo.Inventories  
	ADD CONSTRAINT fkInventoriesProducts
		FOREIGN KEY (ProductID)
		REFERENCES dbo.Products (ProductID);
go
ALTER TABLE dbo.Inventories 
	ADD CONSTRAINT ckInventoriesInventoryCountMoreThanZero CHECK (InventoryCount >= 0);
go
ALTER TABLE dbo.Inventories  
	ADD	CONSTRAINT dfInventoriesCountIsZero DEFAULT (0)
	FOR [InventoryCount];
go

--[ Create the Views ]--
--********************************************************************--
Create View vCategories
As
  Select[CategoryID],[CategoryName] 
  From Categories;
;
go

Create View vProducts
As
  Select [ProductID],[ProductName],[CategoryID],[ProductCurrentPrice] 
  From Products;
;
go

Create View vInventories
As
  Select [InventoryID],[InventoryDate],[ProductID],[InventoryCount] 
  From Inventories
;
go

--[Insert Test Data ]--
--********************************************************************--
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, ProductCurrentPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Inventories
(InventoryDate, ProductID, [InventoryCount])
Select '20200101' as InventoryDate, ProductID, UnitsInStock
From Northwind.dbo.Products
UNION
Select '20200201' as InventoryDate, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNION
Select '20200302' as InventoryDate, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show all of the data in the Categories, Products, and Inventories Tables
--10/31/21 - I have left this in as this is above the TODO, and felt that I ought to leave the stuff here alone. 
--If I should have pulled this out of being run, please let me know when this is graded.
Select * from vCategories;
go
Select * from vProducts;
go
Select * from vInventories;
go

/********************************* TODO: Questions and Answers *********************************/

/********************************* Questions and Answers *********************************/

-- Question 1 (5% pts): How can you show the Category ID and Category Name for 'Seafood'?


-- First, select from the correct table
SELECT 
	* 
FROM
	vCategories
--Then specify the broad limits, i.e., ID 8
WHERE
	CategoryName = 'Seafood';
go

-- Question 2 (5% pts): How can you show the Product ID, Product Name, and Product Price 
-- of all Products with the Seafood's Category Id? With the results ordered By the Products Price
-- highest to the lowest!

--First, we select the appropriate columns
SELECT 
	ProductID, 
	ProductName, 
	ProductCurrentPrice 
FROM 
	vProducts
--Then we go through the where statement, noticing that the CategoryID isn't one of the viewed columns.
WHERE 
	CategoryID = 8
-- And then we sort.  The first time I ran it, it ordered from smallest to largest.  The simplest fix seemed to be to just sort by descending.
ORDER BY 
	ProductCurrentPrice DESC;
go

-- Question 3 (5% pts):  How can you show the Product ID, Product Name, and Product Price 
-- Ordered By the Products Price highest to the lowest?
-- With only the products that have a price Greater than $100! 

--First, the columns we care about
SELECT 
	ProductID, 
	ProductName, 
	ProductCurrentPrice 
FROM 
	vProducts
--Then we put in the major filter
WHERE 
	ProductCurrentPrice > 100
-- Then our sorting statement. 
ORDER BY 
	ProductCurrentPrice DESC;
go

-- Question 4 (10% pts): How can you show the CATEGORY NAME, product name, and Product Price 
-- from both Categories and Products? Order the results by Category Name 
-- and then Product Name, in alphabetical order!
-- (Hint: Join Products to Category)

--First, we select our first columns
SELECT 
	vCategories.CategoryName, 
	ProductName, 
	ProductCurrentPrice 
FROM 
	vProducts
--Then we need to join the other table.  (I did it this way to have less to type.)
INNER JOIN
	vCategories 
ON 
	vCategories.CategoryID = vProducts.CategoryID
-- Then we have our sortings, which will be in alphabetical order without us having to do anything, though we could add ASC.
ORDER BY
	CategoryName, 
	ProductName;
go

-- Question 5 (5% pts): How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs! 

--First, we select the colums to be shown, which will not be the same as what we sort or group by.  
SELECT 
	vProducts.ProductID, 
	vInventories.InventoryCount 
FROM 
	vInventories
--Then, since we're pulling from two different tables, we need to join them.
INNER JOIN 
	vProducts 
ON 
	vProducts.ProductID = vInventories.ProductID
--Now, we do our first-pass filter that gets us just the January stuff
WHERE 
	Month(InventoryDate) = 01
--Technically, we don't need to order this further, as the way the table is made up automatically gets us this 
--numbering, but because this is a class...
ORDER BY 
	ProductID;
go


-- Question 6 (10% pts): How can you show the Category Name, Product Name, and Product Price 
-- from both Categories and Products. Order the results by price highest to lowest?
-- Show only the products that have a PRICE FROM $10 TO $20! 

--First, we select those columns that we're planning on showing.
SELECT 
	vCategories.CategoryName, 
	vProducts.ProductName, 
	vProducts.ProductCurrentPrice 
FROM vCategories
--And then we do a full join to show everything that's in both tabs.
FULL JOIN 
	vProducts 
ON 
	vCategories.CategoryID = vProducts.CategoryID
--Now comes the first pass filter of the current price between $10-$20
WHERE 
	ProductCurrentPrice Between 10 And 20
--And then we sort by said prices. Since ascending is lowest to highest, we flip it.
ORDER BY 
	vProducts.ProductCurrentPrice DESC;
go


-- Question 7 (10% pts) How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs
-- and where the Product IDs are only in the seafood category!
-- (Hint: Use a subquery to get the list of productIds with a category ID of 8)

--First, we select the columns to be shown, which will not be the same as what we sort or group by.
--(And since we did a lot of the work for this in Q5, we will use that code in this query.)
SELECT 
	vProducts.ProductID, 
	vInventories.InventoryCount 
FROM 
	vInventories
--Then, since we're pulling from two different tables, we need to join them.
INNER JOIN 
	vProducts 
ON 
	vProducts.ProductID = vInventories.ProductID
--Now, we do our first-pass filter that gets us just the January stuff
WHERE 
	Month(InventoryDate) = '01'
--And since we also want the Category Name to be Seafood, and we don't want to wimp out and just do
--vProducts.CategoryID = 8, we create the following subquery
AND 
	vProducts.CategoryID = 
		(Select CategoryID
		From vCategories
		Where CategoryName = 'Seafood')
--And then we sort our results.
ORDER BY 
	ProductID;
go


-- Question 8 (10% pts) How can you show the PRODUCT NAME and Number of Products in Inventory
-- for January? Order the results by the Product Names
-- and where the ProductID as only the ones in the seafood category!
-- (Hint: Use a Join between Inventories and Products to get the Name)
-- TODO: Add Your Code Here

--As always, we start with the columns we want to show.
SELECT 
	vProducts.ProductName, 
	vInventories.InventoryCount
FROM 
	vProducts
--And since we're pulling from two different tables, we join them
INNER JOIN 
	vInventories 
ON 
	vInventories.ProductID = vProducts.ProductID
--Then, since we only want January products, we add in our first half of the WHERE statement
WHERE 
	Month(InventoryDate) = 01
--But we also need that seafood filter, so we'll pull that from question 7
AND 
	vProducts.CategoryID = 
		(Select CategoryID
		From vCategories
		Where CategoryName = 'Seafood')
--And, in the end, we sort by the product name.
ORDER BY 
	ProductName;
go 


-- Question 9 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names! 

--Okay, after much trial and error, here we are.
--The first part of our statement, we choose the columns we want to see.  This is where aggregations
--need to go, so we have the AVG here.  I've also renamed that column so that it's clear that this
--isn't the same thing as the Inventory Count.
SELECT
	vProducts.ProductName,
	AVG(InventoryCount) AS 'AvgInvCount'
-- I'm using FROM the Products table because that's what's first in our list of columns.
FROM 
	vProducts
--But we also need the Inventory table, so we venn-diagram it here with an inner join.
INNER JOIN
	vInventories
ON
	vInventories.ProductID = vProducts.ProductID
--Figuring out how to do this was difficult; I kept trying subqueries and different stuff.  But, after
--visualizing it in a different way, I realized that it was just a simple WHERE statement and that I was
--trying to make things more complicated than they needed to be.
WHERE 
	(Month(InventoryDate) = 01 OR Month(InventoryDate) = 02)
--And we need to add in that Seafood code as well. (Copied from Q7.)
AND
	vProducts.CategoryID = 
		(Select CategoryID
		From vCategories
		Where CategoryName = 'Seafood')
--This is here because without having the Product Name in a GROUP BY or Aggregate statement, the code wouldn't
--run.  It doesn't really change anything, so it's okay
GROUP BY
	ProductName
--And then we want to sort the whole table by 
ORDER BY
	ProductName;
go

-- Question 10 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was 
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names! 
-- Restrict the results to rows with a Average COUNT OF 100 OR HIGHER!

--The vast majority of this work is the same as in Q9, so we will reuse that code.
--The first part of our statement, we choose the columns we want to see.  This is where aggregations
--need to go, so we have the AVG here.  I've also renamed that column so that it's clear that this
--isn't the same thing as the Inventory Count.
SELECT
	vProducts.ProductName,
	AVG(InventoryCount) AS 'AvgInvCount'
-- I'm using FROM the Products table because that's what's first in our list of columns.
FROM 
	vProducts
--But we also need the Inventory table, so we venn-diagram it here with an inner join.
Inner Join
	vInventories
ON
	vInventories.ProductID = vProducts.ProductID
--We need our Jan/Feb filter...
WHERE 
	(Month(InventoryDate) = 01 OR Month(InventoryDate) = 02)
--...And we need to add in that Seafood code as well. (Copied from Q7.)
AND
	vProducts.CategoryID = 
		(Select CategoryID
		From vCategories
		Where CategoryName = 'Seafood')
--This is here because without having the Product Name in a GROUP BY or Aggregate statement, the code wouldn't
--run.  It doesn't really change anything, so it's okay.
GROUP BY
	ProductName
--This is the big change from Q9; we use our second-pass filter here to filter after the averages have been calculated
HAVING
	Avg(InventoryCount) >= 100
--And then we want to sort the whole table by 
ORDER BY
	ProductName;
go



/***************************************************************************************/



