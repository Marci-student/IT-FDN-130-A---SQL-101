--*************************************************************************--
-- Title: Assignment08
-- Author: Marci DeLeon
-- Desc: This file demonstrates how to use Stored Procedures
-- Change Log:	12-06-21, MDeLeon, began work
--				12-07-21, MDeLeon, continued work on Q1
-- 2017-01-01, MDeLeon, Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment08DB_MarciDeLeon')
	 Begin 
	  Alter Database [Assignment08DB_MarciDeLeon] set Single_user With Rollback Immediate;
	  Drop Database Assignment08DB_MarciDeLeon;
	 End
	Create Database Assignment08DB_MarciDeLeon;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment08DB_MarciDeLeon;

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
-- NOTE: We are starting without data this time!

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
  Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] From dbo.Inventories;
go

/********************************* Questions and Answers *********************************/
/* NOTE:Use the following template to create your stored procedures and plan on this taking ~2-3 hours

Create Procedure <pTrnTableName>
 (<@P1 int = 0>)
 -- Author: <YourNameHere>
 -- Desc: Processes <Desc text>
 -- Change Log: When,Who,What
 -- <2017-01-01>,<Your Name Here>,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	-- Transaction Code --
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
*/

-- Question 1 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Categories table?

--Create Procedure pInsCategories

-- First, I copy the code template and start to fill it in.
--I also found that I needed to drop the procedure a few 
--times, for practice, hence the code here.  I will delete
--it in the rest of the assignment, but am leaving it here,
--commented out, so that you are aware that I am aware of 
--needing to make changes.
--DROP Procedure pInsCategories;

--Additionally, after completing this assignment, I found
--I have almost no commentary in my code, because the
--complicated stuff is all in the template and doesn't
--need to be changed, while the procedures themselves are 
--extremely simple and don't have much to comment upon.
--(Which is not to say that they have to be complex -- 
--the things people want most to be automated is the
--scutwork.)

--Here's our initial creation statement
Create Procedure pInsCategories
--The CategoryID is an Identity, so I will not be inserting that 
--information.
 (@CategoryName nVarChar(100)
  )
--Here's my change description.
 -- Author: Marci DeLeon
 -- Desc: Processes Inserts data into the Categories table
 -- Change Log: 12-06-21, MDeLeon, created code
 -- 12-06-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
--Here's the start of my Try-Catch block
  Begin Try
   Begin Transaction 
--This is the procedure that's being stored.
	INSERT INTO Categories (CategoryName)
	VALUES	(@CategoryName)
--Then we commit the transaction.
   Commit Transaction
--As long as everything works, our RC is now +1.
   Set @RC = +1
  End Try
--And here's the catch of the Try-Catch block.
  Begin Catch
   Rollback Transaction
--For the most part, I'm not adding a personalized error
--message here, but a few of the Sprocs do have an 
--additional error message here.
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--In order to test this code out, I used the following code.
--EXEC pInsCategories
--	@CategoryName = 'Spaghetti';
--	go
--SELECT * FROM vCategories;
--go

--Create Procedure pUpdCategories
Create Procedure pUpdateCategories
	(@CategoryID int,
	@CategoryName nVarChar(100)
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Category table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 2021-12-07, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Categories
		SET CategoryName = @CategoryName
		WHERE CategoryID = @CategoryID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Category ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--EXEC pUpdateCategories
--	@CategoryID = 1,
--	@CategoryName = 'Pasta'
--	;
--SELECT * FROM vCategories;
--go

--Create Procedure pDelCategories
Create Procedure pDelCategories
 (@CategoryID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in table Categories
 -- Change Log: 12-07-21, MDeLeon, created Sproc
 -- 2021-12-07, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Categories
	WHERE CategoryID = @CategoryID
	;
	IF (@@ROWCOUNT > 1) 
		RAISERROR  ('Do not delete more than one row at a time.',15,1)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--EXEC pDelCategories
--	@CategoryID = 1
--	;
--go
--SELECT * FROM vCategories;
--go

-- Question 2 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Products table?
--Create Procedure pInsProducts
--SELECT * FROM vProducts;

Create Procedure pInsProducts
 (@ProductName nVarChar (100),
 @CategoryID int,
 @UnitPrice money
  )
 -- Author: Marci DeLeon
 -- Desc: Processes Inserts data into the Products table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 12-07-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Products 
		(ProductName,
		CategoryID,
		UnitPrice
		)
	VALUES	
		(@ProductName,
		@CategoryID,
		@UnitPrice
		)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Procedure pUpdProducts
Create Procedure pUpdateProducts
	(@ProductID int,
	@ProductName nVarChar(100),
	@CategoryID int,
	@UnitPrice money
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Product table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 2021-12-07, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Products
		SET
			ProductName = @ProductName,
			CategoryID = @CategoryID,
			UnitPrice = @UnitPrice
		WHERE ProductID = @ProductID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Product ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Procedure pDelProducts
Create Procedure pDelProducts
 (@ProductID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Products table
 -- Change Log: 12-07-21, MDeLeon, created Sproc
 -- 2021-12-07, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Products
	WHERE ProductID = @ProductID
	;
	IF (@@ROWCOUNT > 1) 
		RAISERROR  ('Do not delete more than one row at a time.',15,1)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go



-- Question 3 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Employees table?
--Create Procedure pInsEmployees
--SELECT * FROM vEmployees;


Create Procedure pInsEmployees
 (@EmployeeFirstName nVarChar(100),
 @EmployeeLastName nVarChar(100),
 @ManagerID int
  )
 -- Author: Marci DeLeon
 -- Desc: Processes Inserts data into the Employees table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 12-07-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Employees 
		(EmployeeFirstName,
		EmployeeLastName,
		ManagerID
		)
	VALUES	
		(@EmployeeFirstName,
		@EmployeeLastName,
		@ManagerID
		)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Procedure pUpdEmployees
Create Procedure pUpdEmployees
	(@EmployeeID int,
	@EmployeeFirstName nVarChar(100),
	@EmployeeLastName nVarChar(100),
	@ManagerID int
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Employee table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 2021-12-07, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Employees
		SET
			EmployeeFirstName = @EmployeeFirstName,
			EmployeeLastName = @EmployeeLastName,
			ManagerID = @ManagerID
		WHERE EmployeeID = @EmployeeID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Employee ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Procedure pDelEmployees
Create Procedure pDelEmployees
 (@EmployeeID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Employees table
 -- Change Log: 12-07-21, MDeLeon, created Sproc
 -- 2021-12-07, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Employees
	WHERE EmployeeID = @EmployeeID
	;
	IF (@@ROWCOUNT > 1) 
		RAISERROR  ('Do not delete more than one row at a time.',15,1)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

-- Question 4 (20 pts): How can you create Insert, Update, and Delete Transactions Store Procedures  
-- for the Inventories table?
--Create Procedure pInsInventories
--SELECT * FROM vInventories;

Create Procedure pInsInventories
 (@InventoryDate date,
 @EmployeeID int,
 @ProductID int,
 @Count int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Inserts data into the Inventories table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 12-07-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Inventories 
		(InventoryDate,
		EmployeeID,
		ProductID,
		Count
		)
	VALUES	
		(@InventoryDate,
		@EmployeeID,
		@ProductID,
		@Count
		)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print 'Did you use the right Employee ID or Product ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go


--Create Procedure pUpdInventories
Create Procedure pUpdInventories
	(@InventoryID int,
	@InventoryDate date,
	@EmployeeID int,
	@ProductID int,
	@Count int
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Inventories table
 -- Change Log: 12-07-21, MDeLeon, created code
 -- 2021-12-07, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Inventories
		SET
			InventoryDate = @InventoryDate,
			EmployeeID = @EmployeeID,
			ProductID = @ProductID,
			Count = @Count
		WHERE InventoryID = @InventoryID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Inventory ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Procedure pDelInventories
Create Procedure pDelInventories
 (@InventoryID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Inventories table
 -- Change Log: 12-07-21, MDeLeon, created Sproc
 -- 2021-12-07, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Inventories
	WHERE InventoryID = @InventoryID
	;
	IF (@@ROWCOUNT > 1) 
		RAISERROR  ('Do not delete more than one row at a time.',15,1)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

-- Question 5 (20 pts): How can you Execute each of your Insert, Update, and Delete stored procedures? 
-- Include custom messages to indicate the status of each sproc's execution.

-- Here is template to help you get started:
/*
Declare @Status int;
Exec @Status = <SprocName>
                @ParameterName = 'A'
Select Case @Status
  When +1 Then '<TableName> Insert was successful!'
  When -1 Then '<TableName> Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From <ViewName> Where ColID = 1;
go
*/

--For this question, I am using the template provided and checking to make
--sure things run okay.  There's not much to say, because it's all very
--similar code

--< Test Insert Sprocs >--
-- Test [dbo].[pInsCategories]
Declare @Status int;
Exec @Status = pInsCategories
                @CategoryName = 'Pasta'
Select Case @Status
  When +1 Then 'Categories Insert was successful!'
  When -1 Then 'Categories Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCategories;
go


-- Test [dbo].[pInsProducts]
Declare @Status int;
Exec @Status = pInsProducts
				@ProductName = 'Barelli Spaghetti',
				@CategoryID = 1,
				@UnitPrice = 2.99
Select Case @Status
  When +1 Then 'Products Insert was successful!'
  When -1 Then 'Products Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vProducts;
go

-- Test [dbo].[pInsEmployees]
Declare @Status int;
Exec @Status = pInsEmployees
				@EmployeeFirstName = 'Anne',
				@EmployeeLastName = 'Frost',
				@ManagerID = 1;
Select Case @Status
  When +1 Then 'Employee Insert was successful!'
  When -1 Then 'Employee Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vEmployees;
go


-- Test [dbo].[pInsInventories]
Declare @Status int;
Exec @Status = pInsInventories
				@InventoryDate = '2021-03-20',
				@EmployeeID = 1,
				@ProductID = 1,
				@Count = 52
Select Case @Status
  When +1 Then 'Inventory Insert was successful!'
  When -1 Then 'Inventory Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vInventories;
go


--< Test Update Sprocs >--
-- Test Update [dbo].[pUpdCategories]
Declare @Status int;
Exec @Status = pUpdateCategories
				@CategoryID = 1,
				@CategoryName = 'Dry Pasta';
Select Case @Status
  When +1 Then 'Category Update was successful!'
  When -1 Then 'Category Update failed! Common Issues: Incorrect Category ID'
  End as [Status];
Select * From vCategories;
go


-- Test [dbo].[pUpdProducts]
Declare @Status int;
Exec @Status = pUpdateProducts
				@ProductID = 1,
				@ProductName = 'Tonio''s Spaghetti',
				@CategoryID = 1,
				@UnitPrice = 1.99;
Select Case @Status
  When +1 Then 'Product Update was successful!'
  When -1 Then 'Product Update failed! Common Issues: Incorrect Product ID'
  End as [Status];
Select * From vProducts;
go

-- Test [dbo].[pUpdEmployees]
Declare @Status int;
Exec @Status = pUpdEmployees
				@EmployeeID = 1,
				@EmployeeFirstName = 'Caitlyn',
				@EmployeeLastName = 'Lee',
				@ManagerID = 1
Select Case @Status
  When +1 Then 'Employee Update was successful!'
  When -1 Then 'Employee Update failed! Common Issues: Manager ID not in system.'
  End as [Status];
Select * From vEmployees;
go

-- Test [dbo].[pUpdInventories]
Declare @Status int;
Exec @Status = pUpdInventories
				@InventoryID = 1,
				@InventoryDate = '4/20/2021',
				@EmployeeID = 1,
				@ProductID = 1,
				@Count = 42;
Select Case @Status
  When +1 Then 'Inventory Update was successful!'
  When -1 Then 'Inventory Update failed! Common Issues: Duplicate data.'
  End as [Status];
Select * From vInventories;
go

--< Test Delete Sprocs >--
-- Test [dbo].[pDelInventories]
Declare @Status int;
Exec @Status = pDelInventories
                @InventoryID = 1;
Select Case @Status
  When +1 Then 'Inventory Deletion was successful!'
  When -1 Then 'Inventory Deletion failed! Did you provide the right Inventory ID?'
  End as [Status];
Select * From vInventories;
go

-- Test [dbo].[pDelEmployees]
Declare @Status int;
Exec @Status = pDelEmployees
                @EmployeeID = 1;
Select Case @Status
  When +1 Then 'Employee Deletion was successful!'
  When -1 Then 'Employee Deletion failed! Did you remember to delete the child data first? Check the Inventory table.'
  End as [Status];
Select * From vEmployees;
go

-- Test [dbo].[pDelProducts]
Declare @Status int;
Exec @Status = pDelProducts
                @ProductID = 1;
Select Case @Status
  When +1 Then 'Product Deletion was successful!'
  When -1 Then 'Product Deletion failed! Did you remember to delete the child data first? Check the Inventory table.'
  End as [Status];
Select * From vProducts;
go

-- Test [dbo].[pDelCategories]
Declare @Status int;
Exec @Status = pDelCategories
                @CategoryID = 1
Select Case @Status
  When +1 Then 'Category Deletion was successful!'
  When -1 Then 'Category Deletion failed! Did you remember to delete the child data first? Check the Products table.'
  End as [Status];
Select * From vCategories;
go


--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  

/***************************************************************************************/