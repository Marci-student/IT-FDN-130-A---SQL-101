--*************************************************************************--
-- Title: Assignment02 
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: RRoot
-- Change Log:	10/21/2021, Marci DeLeon, Created Database and Tables; Altered Tables as appropriate.
--				10/23/21, Marci DeLeon, Created Views and inserted data; Checked code with Review.
--				When,Who,What
-- 9/21/2021,RRoot,Created File
-- TODO:10-23-21, Marci DeLeon,Completed File
--**************************************************************************--

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment02DB_MarciDeLeon')
  Begin
  	Use [master];
	  Alter Database Assignment02DB_MarciDeLeon Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment02DB_MarciDeLeon;
  End
go
Create Database Assignment02DB_MarciDeLeon;
go
Use Assignment02DB_MarciDeLeon;
go

--[ Create the Tables ]--
--********************************************************************--
-- TODO: Create table for Categories
-- TODO: Create table for Products
-- TODO: Create table for Inventories

Create Table Categories (
	CategoryID int NOT NULL,
	CategoryName nVarchar(100) NOT NULL
	);

Create Table Products (
	ProductID int NOT NULL,
	ProductName nVarchar(100) NOT NULL,
	ProductCurrentPrice money NOT NULL,
	CategoryID int
	);

Create Table Inventories (
	InventoryID int NOT NULL,
	InventoryDate date NOT NULL,
	InventoryCount int,
	ProductID int NOT NULL
	);
Go

Select * From Categories;
Select * From Products;
Select * From Inventories;
Go

--[ Add Addtional Constaints ]--
--********************************************************************--
-- TODO: Add Constraints for Categories (Primary Key, Unique)
-- TODO: Add Constraints for Products (Primary Key, Unique, Foreign Key, Check)
-- TODO: Add Constraints for Inventories (Primary Key, Foreign Key, Check, Default)

Alter Table Categories 
	Add Primary Key (CategoryID),
	Unique (CategoryName)
	;

Alter Table Products
	Add Primary Key (ProductID),
	Unique (ProductName),
	Check (ProductCurrentPrice > 0),
	Foreign Key (CategoryID) References Categories(CategoryID)
	;

Alter Table Inventories
	Add Primary Key (InventoryID),
	Check (InventoryCount >= 0),
	Default 0 For InventoryCount,
	Foreign Key (ProductID) References Products(ProductID)
	;
Go

--[ Create the Views ]--
--********************************************************************--
-- TODO: Create View for Categories (Primary Key, Unique)
-- TODO: Create View for Products (Primary Key, Unique, Foreign Key, Check)
-- TODO: Create View for Inventories (Primary Key, Foreign Key, Check, Default)

Create View [CatView] AS
	Select CategoryID, CategoryName
	From Categories
	Where CategoryID > 0
	;
Go
Create View [ProdView] AS 
	Select ProductID, ProductName, ProductCurrentPrice, CategoryID
	From Products
	Where ProductID > 0
	;
Go
Create View [InView] AS
	Select InventoryID, InventoryDate, InventoryCount, ProductID
	From Inventories
	Where InventoryID > 0
	;
Go


--[Insert Test Data ]--
--********************************************************************--

-- TODO: Add data to Categories
/*
CategoryID	CategoryName
1	CatA
2	CatB
*/
Insert Into Categories (CategoryID, CategoryName)
	Values (1, 'CatA')
	;
Insert Into Categories (CategoryID, CategoryName)
	Values (2, 'CatB')
	;
go
-- TODO: Add data to Products
/*
ProductID	ProductName	CategoryID	UnitPrice
1	Prod1	1	9.99
2	Prod2	1	19.99
3	Prod3	2	14.99
*/
Insert Into Products (ProductID, ProductName, CategoryID, ProductCurrentPrice)
	Values (1, 'Prod1', 1, 9.99)
	;
Insert Into Products (ProductID, ProductName, CategoryID, ProductCurrentPrice)
	Values (2, 'Prod2', 1, 19.99)
	;
Insert Into Products (ProductID, ProductName, CategoryID, ProductCurrentPrice)
	Values (3, 'Prod3', 2, 14.99)
	;	
go

-- TODO: Add data to Inventories
/*
InventoryID	InventoryDate	ProductID	InventoryCount
1	1	2020-01-01	1	100
2	2	2020-01-01	2	50
3	3	2020-01-01	3	34
4	4	2020-02-01	1	100
5	5	2020-02-01	2	50
6	6	2020-02-01	3	34
*/
Insert Into Inventories (InventoryID, InventoryDate, ProductID, InventoryCount)
	Values (1, '2020-01-01', 1, 100)
	;
Insert Into Inventories (InventoryID, InventoryDate, ProductID, InventoryCount)
	Values (2, '2020-01-01', 2, 50)
	;
Insert Into Inventories (InventoryID, InventoryDate, ProductID, InventoryCount)
	Values (3, '2020-01-01', 3, 34)
	;
Insert Into Inventories (InventoryID, InventoryDate, ProductID, InventoryCount)
	Values (4, '2020-02-01', 1, 100)
	;
Insert Into Inventories (InventoryID, InventoryDate, ProductID, InventoryCount)
	Values (5, '2020-02-01', 2, 50)
	;
Insert Into Inventories (InventoryID, InventoryDate, ProductID, InventoryCount)
	Values (6, '2020-02-01', 3, 34)
	;
go
-
--[ Review the design ]--
--********************************************************************--
-- Note: This is advanced code and it is not expected that you should be able to read it yet. 
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



-- Important: The correct design should match this output when my meta data query runs
/*
SourceObjectName	IsNullable	DataType	ConstraintName	COLUMN_DEFAULT
Assignment02DB_RRoot.dbo.Categories.CategoryID	NO	int	pkCategories	Identity
Assignment02DB_RRoot.dbo.Categories.CategoryID	NO	int	pkCategories	NA
Assignment02DB_RRoot.dbo.Categories.CategoryName	NO	nvarchar(100)	uCategoryName	NA
Assignment02DB_RRoot.dbo.Inventories.InventoryID	NO	int	pkInventories	Identity
Assignment02DB_RRoot.dbo.Inventories.InventoryDate	NO	date	ckInventoriesInventoryDateTodayOrEarlier	NA
Assignment02DB_RRoot.dbo.Inventories.ProductID	NO	int	fkInventoriesProducts	Identity
Assignment02DB_RRoot.dbo.Inventories.ProductID	NO	int	fkInventoriesProducts	NA
Assignment02DB_RRoot.dbo.Inventories.Count	NO	int	NA	((0))
Assignment02DB_RRoot.dbo.Products.ProductID	NO	int	pkProducts	Identity
Assignment02DB_RRoot.dbo.Products.ProductID	NO	int	pkProducts	NA
Assignment02DB_RRoot.dbo.Products.ProductName	NO	nvarchar(100)	uProductName	NA
Assignment02DB_RRoot.dbo.Products.CategoryID	YES	int	fkProductsCategories	Identity
Assignment02DB_RRoot.dbo.Products.CategoryID	YES	int	fkProductsCategories	NA
Assignment02DB_RRoot.dbo.Products.UnitPrice	NO	money(19,4)	pkProductsUnitPriceZeroOrMore	NA
*/

