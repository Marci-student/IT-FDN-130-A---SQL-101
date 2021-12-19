--*************************************************************************--
-- Title: Assignment04
-- Author: Marci DeLeon
-- Desc: This file demonstrates how to process data in a database
-- Change Log: 11/6/21, Marci DeLeon, Answered questions 1-4
--	11/7/21, Marci DeLeon, Answered question 5 and rechecked/cleaned up code.
-- 2021-11-06,Marci DeLeon,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_MarciDeLeon')
 Begin 
  Alter Database [Assignment04DB_MarciDeLeon] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_MarciDeLeon;
 End
go

Create Database Assignment04DB_MarciDeLeon;
go

Use Assignment04DB_MarciDeLeon;
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
,[UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
go


-- Show the Current data in the Categories, Products, and Inventories Tables
/*Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go
*/


/********************************* TASKS *********************************/

-- Add the following data to this database.
-- All answers must include the Begin Tran, Commit Tran, and Rollback Tran transaction statements. 
-- All answers must include the Try/Catch blocks around your transaction processing code.
-- Display the Error message if the catch block is invoked.

/* Add the following data to this database:
Beverages	Chai	18.00	2017-01-01	61
Beverages	Chang	19.00	2017-01-01	87
Condiments	Aniseed Syrup	10.00	2017-01-01	19
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-01-01	81
Beverages	Chai	18.00	2017-02-01	13
Beverages	Chang	19.00	2017-02-01	2
Condiments	Aniseed Syrup	10.00	2017-02-01	1
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-02-01	79
Beverages	Chai	18.00	2017-03-02	18
Beverages	Chang	19.00	2017-03-02	12
Condiments	Aniseed Syrup	10.00	2017-03-02	84
Condiments	Chef Anton's Cajun Seasoning	22.00	2017-03-02	72
*/

-- Task 1 (20 pts): Add data to the Categories table

--First, the first part of the Try-Catch Block
BEGIN TRY
--Now we need to begin the transaction
BEGIN TRAN
--Then the actual insertion of data.  I will be putting all the values into one statement, because it seems simpler.
INSERT INTO Categories (CategoryName)
VALUES ('Beverages'),
	('Condiments')
-- Now that we have what our transaction should be, we'll do it.
COMMIT TRAN
--Now we end the try
END TRY
--And add the second half of the Try-Catch Block
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'Bad data entry.  Check inputs.'
	PRINT ERROR_MESSAGE()
END CATCH;
go

-- Task 2 (20 pts): Add data to the Products table

--First, the first part of the Try-Catch Block
BEGIN TRY
--Now we need to begin the transaction
BEGIN TRAN
--Then the actual insertion of data. 
INSERT INTO Products (ProductName, UnitPrice, CategoryID)
VALUES ('Chai', 18.00, 1),
	('Chang' , 19.00, 1),
	('Aniseed Syrup', 10.00, 2),
	('Chef Anton''s Cajun Seasoning', 22.00, 2);
-- Now that we have what our transaction should be, we'll do it.
COMMIT TRAN
--Now we end the try
END TRY
--And add the second half of the Try-Catch Block
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'Bad data entry.  Check inputs.'
	PRINT ERROR_MESSAGE()
END CATCH;
go

-- Task 3 (20 pts): Add data to the Inventories table

--First, the first part of the Try-Catch Block
BEGIN TRY
--Now we need to begin the transaction
BEGIN TRAN
--Then the actual insertion of data. 
INSERT INTO Inventories (ProductID, InventoryDate, Count)
VALUES (1, '2017-01-01', 61),
	(2, '2017-01-01', 87),
	(3, '2017-01-01', 19),
	(4, '2017-01-01', 81),
	(1, '2017-02-01', 13),
	(2, '2017-02-01', 2),
	(3, '2017-02-01', 1),
	(4, '2017-02-01', 79),
	(1, '2017-03-02', 18),
	(2, '2017-03-02', 12),
	(3, '2017-03-02', 84),
	(4, '2017-03-02', 72);
-- Now that we have what our transaction should be, we'll do it.
COMMIT TRAN
--Now we end the try
END TRY
--And add the second half of the Try-Catch Block
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'Bad data entry.  Check inputs.'
	PRINT ERROR_MESSAGE()
END CATCH;
go


-- Task 4 (10 pts): Write code to update the Category "Beverages" to "Drinks"

--Now we're updating the data, so we're going to modify the inner statement, the one that's not doing error checking.
--First, the first part of the Try-Catch Block
BEGIN TRY
--Now we need to begin the transaction
BEGIN TRAN
--Then the actual insertion of data.
UPDATE Categories
	SET CategoryName = 'Drinks'
	WHERE CategoryID = 1
-- Now that we have what our transaction should be, we'll do it.
COMMIT TRAN
--Now we end the try
END TRY
--And add the second half of the Try-Catch Block
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'Bad data entry.  Check inputs.'
	PRINT ERROR_MESSAGE()
END CATCH;
go

-- Task 5 (30 pts): Write code to delete all Condiments data from the database (in all three tables!)  

--Now we're going to delete data, so we're going to modify the inner statement, the one that's not doing error checking.
--First, the first part of the Try-Catch Block
BEGIN TRY
--Now we need to begin the transaction
BEGIN TRAN
--Then the actual deletion of data.  Because we have some foreign keys, and we can't be having with orphan data, 
--we're going to start with the "outermost" table and work our way in.
DELETE FROM Inventories
WHERE ProductID = 3
	OR ProductID = 4
--Then delete data from the next table "in"
DELETE FROM Products
WHERE CategoryID = 2
-- And then we can finally delete all the Condiments data
DELETE FROM Categories
WHERE CategoryName = 'Condiments'
-- Now that we have all three parts of our transaction
COMMIT TRAN
--Now we end the try
END TRY
--And add the second half of the Try-Catch Block.  Note the new error message.
BEGIN CATCH
	ROLLBACK TRAN
	PRINT 'Inappropriate deletion.  Check inputs.'
	PRINT ERROR_MESSAGE()
END CATCH;
go


/***************************************************************************************/