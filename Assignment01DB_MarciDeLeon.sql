----------------------------------------------------------------------
-- Title: Assignment01
-- Desc: Creating a normalized database from sample data
-- Author: Marci DeLeon
-- ChangeLog: 
	/*(10/16/21, MDeLeon revised this code per assignment prarameters)
	(10/18/21, MDeLeon annotated this code, added GO statements, and rechecked)
*/
-- 9/21/2021,RRoot,Created Script
-- TODO: <October 16, 2021>,<Marci DeLeon>,Completed Script
----------------------------------------------------------------------

--[ Create the Database ]--
-- This section was used directly from RRoot's created script, with the name of the database changed.  All else is kept.
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment01DB_MarciDeLeon')
  Begin
  	Use [master];
	  Alter Database Assignment01DB_MarciDeLeon Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment01DB_MarciDeLeon;
  End
go
Create Database Assignment01DB_MarciDeLeon;
go
Use Assignment01DB_MarciDeLeon;
go

--[ Create the Tables ]--
--********************************************************************--

-- TODO: Create Multiple tables to hold the following data --

/*  Products,Price,Units,Customer,Address,Date
    Apples,$0.89,12,Bob Smith,123 Main Bellevue Wa,5/5/2006 
    Milk,$1.59,2,Bob Smith,123 Main Bellevue Wa,5/5/2006 
    Bread,$2.28,1,Bob Smith,123 Main Bellevue Wa,5/5/2006
*/

-- Create Table Example(Col1 int, Col2 nvarchar(100));
-- This section creates the tables.  
/* There are three tables: Product, Customer, and Order.
Product describes the product with the Product Name (ProdName) and Price per unit of product (UnitPrice).  
	UnitPrice is a number with up to four places before the decimal and two places after.
	Both ProdName and UnitPrice must be provided.
	The Primary Key is ProdID, which is an integer value given and iterated by the database.

Customer decribes the purchaser, with the customer's first name (CustomerFN), last name (CustomerLN), street address (CustAddress), city (CustCity), and state (CustState).
	All fields are Varchar to 100, and only the CustomerFN must be provided.
	The Primary Key is CustomerID, which is an integer value given and iterated by the database.

Sale describes the specific sale, with the quantity of products purchased per unit (ProdQuant) and sale date (SaleDate).
	ProdQuant is an integer value which must be provided.
	SaleDate is a yyyy/mm/dd date which must be provided.
	The Primary Key is SaleID, which is an integer value given and iterated by the database.
	Sale also has two Foreign Keys: ProdID from Products and CustomerID from Customer
*/

go
CREATE Table 
	Product (
		ProdID int NOT NULL PRIMARY KEY IDENTITY(1,1),  
		ProdName nVarchar(100) NOT NULL, 
		UnitPrice decimal(6,2) 
		);
go

CREATE Table 
	Customer (
		CustomerID int NOT NULL PRIMARY KEY IDENTITY(1,1),
		CustomerFN nVarchar(100) NOT NULL,
		CustomerLN nVarchar(100), 
		CustAddress nVarchar(100),
		CustCity nVarchar(100), 
		CustState nVarchar(100) 
		);
go

CREATE Table 
	Sale (
		SaleID int NOT NULL PRIMARY KEY IDENTITY(1,1), 
		ProdID int FOREIGN KEY REFERENCES Product(ProdID),
		CustomerID int FOREIGN KEY REFERENCES Customer(CustomerID),
		ProdQuant int, 
		PurchaseDate date NOT NULL,
		);
go

-- TODO: Insert the provided data to test your design -- 

/*  Products,Price,Units,Customer,Address,Date
    Apples,$0.89,12,Bob Smith,123 Main Bellevue Wa,5/5/2006 
    Milk,$1.59,2,Bob Smith,123 Main Bellevue Wa,5/5/2006 
    Bread,$2.28,1,Bob Smith,123 Main Bellevue Wa,5/5/2006
*/


-- Insert Into Example(Col1, Col2) Values (1,'Test');
-- This section puts the above values into the tables. This is done in Product -> Customer -> Sale order so that the two foreign keys are available for the Sale table. --
go

INSERT INTO Product (ProdName, UnitPrice)
	VALUES ('Apples', 0.89);
go
INSERT INTO Product (ProdName, UnitPrice)
	VALUES ('Milk', 1.59); 
go
INSERT INTO Product (ProdName, UnitPrice)
	VALUES ('Bread', 2.28); 
go

INSERT INTO Customer(CustomerFN, CustomerLN, CustAddress, CustCity, CustState)
	VALUES ('Bob', 'Smith', '123 Main', 'Bellevue', 'WA'); 
go

INSERT INTO Sale (ProdID, CustomerID, ProdQuant, PurchaseDate)
	VALUES (1, 1, 12, '2006-05-05');
go
INSERT INTO Sale (ProdID, CustomerID, ProdQuant, PurchaseDate)
	VALUES (2, 1, 2, '2006-05-05');
go
INSERT INTO Sale (ProdID, CustomerID, ProdQuant, PurchaseDate)
	VALUES (3, 1, 1, '2006-05-05');
go


-- This is here for testing purposes. --

Select * from Product;
Select * from Customer;
Select * from Sale; 
go

USE MASTER;
go


--[ Review the design ]--
--********************************************************************--
-- Note: This is advanced code and it is NOT expected that you should be able to read it yet. 
-- However, you will be able to by the end of the course! :-)
-- Meta Data Query:
With 
TablesAndColumns As (
Select  
  [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
, [IS_NULLABLE]=[IS_NULLABLE]
, [DATA_TYPE] = Case [DATA_TYPE]
                When 'varchar' Then  [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'nvarchar' Then [DATA_TYPE] + '(' + IIf(DATA_TYPE = 'int','', IsNull(Cast(CHARACTER_MAXIMUM_LENGTH as varchar(10)), '')) + ')'
                When 'money' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'decimal' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                When 'float' Then [DATA_TYPE] + '(' + Cast(NUMERIC_PRECISION as varchar(10)) + ',' + Cast(NUMERIC_SCALE as varchar(10)) + ')'
                Else [DATA_TYPE]
                End                          
, [TABLE_NAME]
, [COLUMN_NAME]
, [ORDINAL_POSITION]
, [COLUMN_DEFAULT]
From Information_Schema.columns 
),
Constraints As (
Select 
 [SourceObjectName] = TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.' + COLUMN_NAME
,[CONSTRAINT_NAME]
From [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE]
), 
IdentityColumns As (
Select 
 [ObjectName] = object_name(c.[object_id]) 
,[ColumnName] = c.[name]
,[IsIdentity] = IIF(is_identity = 1, 'Identity', Null)
From sys.columns as c Join Sys.tables as t on c.object_id = t.object_id
) 
Select 
  TablesAndColumns.[SourceObjectName]
, [IsNullable] = [Is_Nullable]
, [DataType] = [Data_Type] 
, [ConstraintName] = IsNull([CONSTRAINT_NAME], 'NA')
, [COLUMN_DEFAULT] = IsNull(IIF([IsIdentity] Is Not Null, 'Identity', [COLUMN_DEFAULT]), 'NA')
--, [ORDINAL_POSITION]
From TablesAndColumns 
Full Join Constraints On TablesAndColumns.[SourceObjectName]= Constraints.[SourceObjectName]
Full Join IdentityColumns On TablesAndColumns.COLUMN_NAME = IdentityColumns.[ColumnName]
Where [TABLE_NAME] Not In (Select [TABLE_NAME] From [INFORMATION_SCHEMA].[VIEWS])
Order By [TABLE_NAME],[ORDINAL_POSITION]

