--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: YourNameHere
-- Desc: This file demonstrates how to design and create
--       tables, views, and stored procedures
-- Change Log: 12/15/21, MDeLeon, created tables, did most of altering tables
--			12/16/21, MDeLeon, worked on alter table issues, created views, inserted data, created
--								some procedures
--			12/18/21, MDeLeon, finished up procedures.
-- 2017-01-01,YourNameHere,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_MarciDeLeon')
	 Begin 
	  Alter Database [ITFnd130FinalDB_MarciDeLeon] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_MarciDeLeon;
	 End
	Create Database ITFnd130FinalDB_MarciDeLeon;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_MarciDeLeon;

--As noted in the ERD and metadata, I have four tables 
--to create in this database. First, I will create them.

CREATE TABLE Courses(
	CourseID int IDENTITY(1,1) NOT NULL,
	CourseName nVarChar(100) NOT NULL,
	CourseStartDate date NULL,
	CourseEndDate date NULL,
	CourseCurrentPrice money NULL,
	ClassDays nVarChar(10) NULL,
	ClassStartTime time NULL,
	ClassEndTime time NULL
	);
go

CREATE TABLE Students(
	StudentID int IDENTITY(1,1) NOT NULL,
	StudentFirstName nVarChar(100) NOT NULL,
	StudentLastName nVarChar(100) NOT NULL,
	StudentNum nVarChar(100) NOT NULL,
	StudentEmail nVarChar(100) NULL,
	StudentPhone nVarChar(100) NULL,
	StudentStreet nVarChar(100) NOT NULL,
	StudentCity nVarChar(100) NOT NULL,
	StudentState nVarChar(100) NOT NULL,
	StudentCountry nVarChar(100) NOT NULL,
	StudentZip nVarChar(20) NULL
	);
go

CREATE TABLE Enrollment(
	EnrollmentID int IDENTITY(1,1) NOT NULL,
	CourseID int NOT NULL,
	StudentID int NOT NULL,
	EnrollmentDate date NOT NULL,
	CourseStudentPrice money NOT NULL
	);
go

--This is not how this table started out; I 
--realized my problem when I started working
--with it.

CREATE TABLE Payment(
	PaymentID int IDENTITY(1,1) NOT NULL,
	EnrollmentID int NOT NULL,
	CourseStudentPrice money NOT NULL,
	StudentPayment money NULL
	);
go

--02: We alter the tables.
--Given that this is a class, I chose to not identify
--my primary keys above, so that I may have the pleasure
--of doing so down here.  All other constraints can be
--seen on my metadata catalog. (I added a column for 
--foreign keys.)

ALTER TABLE Courses
	ADD
		PRIMARY KEY (CourseID),
		UNIQUE (CourseName)
		;
go

--I realize that I should probably have country code in
--the phone number, but I just don't want to mess with
--it right now.

ALTER TABLE Students
	ADD
		PRIMARY KEY (StudentID),
		UNIQUE (StudentNum),
		CHECK (StudentNum LIKE '%-%-%'),
		CHECK (StudentEmail LIKE '_%@__%.__%'),
		CHECK (StudentPhone LIKE '([0-9][0-9][0-9])[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
		;
go

ALTER TABLE Enrollment
	ADD
		PRIMARY KEY (EnrollmentID),
		FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
		FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
		;
go


ALTER TABLE Payment
	ADD
		PRIMARY KEY (PaymentID),
		FOREIGN KEY (EnrollmentID) REFERENCES Enrollment(EnrollmentID),
		CHECK (CourseStudentPrice >= 0),
		CHECK (StudentPayment >= 0)
		;
go

--03: We add Views.
--This is all going to be very templated language, so
--again, not too many comments here.
--12/18/21 -- I forgot about Schemabinding!  Added in.


CREATE VIEW vCourses
	WITH SCHEMABINDING
	AS
		SELECT
			Courses.CourseID,
			Courses.CourseName,
			Courses.CourseStartDate,
			Courses.CourseEndDate,
			Courses.CourseCurrentPrice,
			Courses.ClassDays,
			Courses.ClassStartTime,
			Courses.ClassEndTime
		FROM dbo.Courses
		;
go

CREATE VIEW vStudents
	AS
		SELECT
			Students.StudentID,
			Students.StudentFirstName,
			Students.StudentLastName,
			Students.StudentNum, 
			Students.StudentEmail, 
			Students.StudentPhone,
			Students.StudentStreet,
			Students.StudentCity,
			Students.StudentState,
			Students.StudentCountry,
			Students.StudentZip
		FROM dbo.Students
		;
go

CREATE VIEW vEnrollment
	WITH SCHEMABINDING
	AS
		SELECT
		Enrollment.EnrollmentID,
		Enrollment.CourseID,
		Enrollment.StudentID,
		Enrollment.EnrollmentDate,
		Enrollment.CourseStudentPrice
		FROM dbo.Enrollment
		;
go


CREATE VIEW vPayment
	WITH SCHEMABINDING
	AS
		SELECT
			Payment.PaymentID,
			Payment.EnrollmentID,
			Payment.CourseStudentPrice,
			Payment.StudentPayment
		FROM dbo.Payment
		;
go 

--04: We add data.
--Woohoo!  Let's make these useful!

INSERT INTO Courses(
	CourseName, 
	CourseStartDate, 
	CourseEndDate, 
	CourseCurrentPrice, 
	ClassDays, 
	ClassStartTime, 
	ClassEndTime
	)
VALUES(
	'SQL1 - Winter 2017',
	'1/10/2017',
	'1/24/2017',
	399,
	'T',
	'18:00',
	'20:50'
	);
go

INSERT INTO Courses(
	CourseName, 
	CourseStartDate, 
	CourseEndDate, 
	CourseCurrentPrice, 
	ClassDays, 
	ClassStartTime, 
	ClassEndTime
	)
VALUES(
	'SQL2 - Winter 2017',
	'1/31/2017',
	'2/14/2017',
	399,
	'T',
	'18:00',
	'20:50'
	);
go

INSERT INTO Students(
	StudentFirstName, 
	StudentLastName, 
	StudentNum, 
	StudentEmail, 
	StudentPhone, 
	StudentStreet, 
	StudentCity, 
	StudentState, 
	StudentCountry, 
	StudentZip
	)
VALUES(
	'Bob',
	'Smith',
	'B-Smith-071',
	'Bsmith@HipMail.com',
	'(206)111-2222',
	'123 Main St.',
	'Seattle',
	'WA',
	'United States',
	'98001'
	);
go

INSERT INTO Students(
	StudentFirstName, 
	StudentLastName, 
	StudentNum, 
	StudentEmail, 
	StudentPhone, 
	StudentStreet, 
	StudentCity, 
	StudentState, 
	StudentCountry, 
	StudentZip
	)
VALUES(
	'Sue',
	'Jones',
	'S-Jones-003',
	'SueJones@YaYou.com',
	'(206)231-4321',
	'333 1st Ave.',
	'Seattle',
	'WA',
	'United States',
	'98001'
	);
go

INSERT INTO Enrollment(
	CourseID,
	StudentID,
	EnrollmentDate,
	CourseStudentPrice
	)
VALUES(
	1,
	1,
	'1/3/2017',
	399
	);
go

INSERT INTO Enrollment(
	CourseID,
	StudentID,
	EnrollmentDate,
	CourseStudentPrice
	)
VALUES(
	1,
	2,
	'1/12/2017',
	399
	);
go

INSERT INTO Enrollment(
	CourseID,
	StudentID,
	EnrollmentDate,
	CourseStudentPrice
	)
VALUES(
	2,
	1,
	'12/14/2016',
	349
	);
go

INSERT INTO Enrollment(
	CourseID,
	StudentID,
	EnrollmentDate,
	CourseStudentPrice
	)
VALUES(
	2,
	2,
	'12/14/2016',
	349
	);
go

INSERT INTO Payment(
	EnrollmentID,
	CourseStudentPrice,
	StudentPayment
	)
VALUES(
	1,
	399,
	399);
go

INSERT INTO Payment(
	EnrollmentID,
	CourseStudentPrice,
	StudentPayment
	)
VALUES(
	2,
	399,
	399);
go

INSERT INTO Payment(
	EnrollmentID,
	CourseStudentPrice,
	StudentPayment
	)
VALUES(
	3,
	349,
	349);
go

INSERT INTO Payment(
	EnrollmentID,
	CourseStudentPrice,
	StudentPayment
	)
VALUES(
	4,
	349,
	349);
go

--I tested with my views throughout, but I also
--wanted a final check here. I've commented it
--out; feel free to comment it back in.

--SELECT * FROM vCourses;
--SELECT * FROM vStudents;
--SELECT * FROM vEnrollment;
--SELECT * FROM vPayment;
--go

--05: We create Procedures
--Now we create our basic stored procedures:
--Insert, Update, and Delete.  You will find
--the template familiar.


--Course SProcs!
Create Procedure pInsCourses(
	@CourseName nVarChar(100),
	@CourseStartDate date,
	@CourseEndDate date,
	@CourseCurrentPrice money,
	@ClassDays nVarChar(10),
	@ClassStartTime time,
	@ClassEndTime time
	)
-- Author: Marci DeLeon
 -- Desc: Processes Insert data into Courses table
 -- Change Log: 12-16-21, MDeLeon, created code
 -- 12-16-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Courses(
		CourseName,
		CourseStartDate,
		CourseEndDate,
		CourseCurrentPrice,
		ClassDays,
		ClassStartTime,
		ClassEndTime
		)
	VALUES(
	@CourseName,
	@CourseStartDate,
	@CourseEndDate,
	@CourseCurrentPrice,
	@ClassDays,
	@ClassStartTime,
	@ClassEndTime
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

Create Procedure pUpdateCourses(
	@CourseID int,
	@CourseName nVarChar(100),
	@CourseStartDate date,
	@CourseEndDate date,
	@CourseCurrentPrice money,
	@ClassDays nVarChar(10),
	@ClassStartTime time,
	@ClassEndTime time
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Courses table
 -- Change Log: 12-16-21, MDeLeon, created code
 -- 2021-12-16, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Courses
		SET 
			CourseName = @CourseName,
			CourseStartDate = @CourseStartDate,
			CourseEndDate = @CourseEndDate,
			CourseCurrentPrice = @CourseCurrentPrice,
			ClassDays = @ClassDays,
			ClassStartTime = @ClassStartTime,
			ClassEndTime = @ClassEndTime
		WHERE 
			CourseID = @CourseID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Course ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelCourses
 (@CourseID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Courses table
 -- Change Log: 12-16-21, MDeLeon, created Sproc
 -- 2021-12-16, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Courses
	WHERE CourseID = @CourseID
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

--Students SProc!
Create Procedure pInsStudents(
	@StudentFirstName nVarChar(100),
	@StudentLastName nVarChar(100),
	@StudentNum nVarChar(100),
	@StudentEmail nVarChar(100),
	@StudentPhone nVarChar(100),
	@StudentStreet nVarChar(100),
	@StudentCity nVarChar(100),
	@StudentState nVarChar(100),
	@StudentCountry nVarChar(100),
	@StudentZip nVarChar(20)
	)
-- Author: Marci DeLeon
 -- Desc: Processes Insert data into Students table
 -- Change Log: 12-16-21, MDeLeon, created code
 -- 12-16-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Students(
		StudentFirstName,
		StudentLastName,
		StudentNum,
		StudentEmail,
		StudentPhone,
		StudentStreet,
		StudentCity,
		StudentState,
		StudentCountry,
		StudentZip
		)
	VALUES(
	@StudentFirstName,
	@StudentLastName,
	@StudentNum,
	@StudentEmail,
	@StudentPhone,
	@StudentStreet,
	@StudentCity,
	@StudentState,
	@StudentCountry,
	@StudentZip
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

Create Procedure pUpdateStudents(
	@StudentID int,
	@StudentFirstName nVarChar(100),
	@StudentLastName nVarChar(100),
	@StudentNum nVarChar(100),
	@StudentEmail nVarChar(100),
	@StudentPhone nVarChar(100),
	@StudentStreet nVarChar(100),
	@StudentCity nVarChar(100),
	@StudentState nVarChar(100),
	@StudentCountry nVarChar(100),
	@StudentZip nVarChar(20)
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Student table
 -- Change Log: 12-16-21, MDeLeon, created code
 -- 2021-12-16, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Students
		SET 
			StudentFirstName = @StudentFirstName,
			StudentLastName = @StudentLastName,
			StudentNum = @StudentNum,
			StudentEmail = @StudentEmail,
			StudentPhone = @StudentPhone,
			StudentStreet = @StudentStreet,
			StudentCity = @StudentCity,
			StudentState = @StudentState,
			StudentCountry = @StudentCountry,
			StudentZip = @StudentZip
		WHERE 
			StudentID = @StudentID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Student ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelStudents
 (@StudentID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Students table
 -- Change Log: 12-16-21, MDeLeon, created Sproc
 -- 2021-12-16, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Students
	WHERE StudentID = @StudentID
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

--Enrollment SProcs!
Create Procedure pInsEnrollment(
	@CourseID int,
	@StudentID int,
	@EnrollmentDate date,
	@CourseStudentPrice money
	)
-- Author: Marci DeLeon
 -- Desc: Processes Insert data into Enrollment table
 -- Change Log: 12-18-21, MDeLeon, created code
 -- 12-18-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Enrollment(
		CourseID,
		StudentID,
		EnrollmentDate,
		CourseStudentPrice
		)
	VALUES(
		@CourseID,
		@StudentID,
		@EnrollmentDate,
		@CourseStudentPrice
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

Create Procedure pUpdateEnrollment(
	@EnrollmentID int,
	@CourseID int,
	@StudentID int,
	@EnrollmentDate date,
	@CourseStudentPrice money
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Enrollment table
 -- Change Log: 12-18-21, MDeLeon, created code
 -- 2021-12-18, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Enrollment
		SET 
			CourseID = @CourseID,
			StudentID = @StudentID,
			EnrollmentDate = @EnrollmentDate,
			CourseStudentPrice = @CourseStudentPrice
		WHERE 
			EnrollmentID = @EnrollmentID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Enrollment ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelEnrollment
 (@EnrollmentID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Enrollment table
 -- Change Log: 12-18-21, MDeLeon, created Sproc
 -- 2021-12-18, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Enrollment
	WHERE EnrollmentID = @EnrollmentID
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

--And finally, Payment SProcs!
Create Procedure pInsPayment(
	@EnrollmentID int,
	@CourseStudentPrice money,
	@StudentPayment money
	)
-- Author: Marci DeLeon
 -- Desc: Processes Insert data into Payment table
 -- Change Log: 12-18-21, MDeLeon, created code
 -- 12-18-21, Marci DeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	INSERT INTO Payment(
		EnrollmentID,
		CourseStudentPrice,
		StudentPayment
		)
	VALUES(
		@EnrollmentID,
		@CourseStudentPrice,
		@StudentPayment
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

Create Procedure pUpdatePayment(
	@PaymentID int,
	@EnrollmentID int,
	@CourseStudentPrice money,
	@StudentPayment money
	)
 -- Author: Marci DeLeon
 -- Desc: Processes Update/alter Payment table
 -- Change Log: 12-18-21, MDeLeon, created code
 -- 2021-12-18, MDeLeon, Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
		UPDATE Payment
		SET 
			EnrollmentID = @EnrollmentID,
			CourseStudentPrice = @CourseStudentPrice,
			StudentPayment = @StudentPayment
		WHERE 
			PaymentID = @PaymentID
		;
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   PRINT 'Did you provide the correct Payment ID?'
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelPayment
 (@PaymentID int
 )
 -- Author: Marci DeLeon
 -- Desc: Processes Deletion of rows in the Payment table
 -- Change Log: 12-18-21, MDeLeon, created Sproc
 -- 2021-12-18, MDeLeon,Created Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	DELETE
	FROM dbo.Payment
	WHERE PaymentID = @PaymentID
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

--06: We set permissions!
--I might be tempted to put these in with the
--views, but at the same time, it also makes
--sense to put them all together here.

--DENY Statements
DENY 
	SELECT ON
		Courses
	TO
		Public
;
go

DENY 
	SELECT ON
		Students
	TO
		Public
;
go

DENY 
	SELECT ON
		Enrollment
	TO
		Public
;
go

DENY 
	SELECT ON
		Payment
	TO
		Public
;
go

--GRANT Statements

GRANT
	SELECT ON
		vCourses
	TO
		Public
;
go

GRANT
	SELECT ON
		vStudents
	TO
		Public
;
go

GRANT
	SELECT ON
		vEnrollment
	TO
		Public
;
go

GRANT
	SELECT ON
		vPayment
	TO
		Public
;
go

GRANT
	SELECT ON
		vCourses
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pInsCourses
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pUpdateCourses
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pDelCourses
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pInsStudents
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pUpdateStudents
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pDelStudents
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pInsEnrollment
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pUpdateEnrollment
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pDelEnrollment
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pInsPayment
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pUpdatePayment
	TO
		Public
;
go

GRANT
	EXECUTE ON
		pDelPayment
	TO
		Public
;
go

--08: We test the Sprocs!

--Courses
Declare @Status int;
Exec @Status = pInsCourses
		@CourseName = 'Poetry of the Nine Worlds',
		@CourseStartDate = '1/3/2022',
		@CourseEndDate = '4/15/2022',
		@CourseCurrentPrice = 325,
		@ClassDays = 'MW',
		@ClassStartTime = '9:00',
		@ClassEndTime = '9:50'
Select Case @Status
  When +1 Then 'Course Insert was successful!'
  When -1 Then 'Course Insert failed! Common Issues: Duplicate Data'
  End as [Status];
go

--SELECT * FROM vCourses;
--go
--(I did this after each EXEC, to make
--sure, but figured I wouldn't keep 
--them in, except here.)

Declare @Status int;
Exec @Status = pInsStudents
		@StudentFirstName = 'Fitzroy',
		@StudentLastName = 'Angursell',
		@StudentNum = 'F-Angursell-001',
		@StudentEmail = 'ADamarace@Astandalas.gov',
		@StudentPhone = '(425)782-9317',
		@StudentStreet = '125 Victoria Ave',
		@StudentCity = 'Shoreline',
		@StudentState = 'WA',
		@StudentCountry = 'United States',
		@StudentZip = '98133'
Select Case @Status
  When +1 Then 'Student Insert was successful!'
  When -1 Then 'Student Insert failed! Common Issues: Duplicate Data'
  End as [Status];
go

Declare @Status int;
Exec @Status = pInsEnrollment
		@CourseID = 3,
		@StudentID = 3,
		@EnrollmentDate = '11/13/2021',
		@CourseStudentPrice = 325
Select Case @Status
  When +1 Then 'Enrollment Insert was successful!'
  When -1 Then 'Enrollment Insert failed! Common Issues: Duplicate Data'
  End as [Status];
go

Declare @Status int;
Exec @Status = pInsPayment
		@EnrollmentID = 5,
		@CourseStudentPrice = 325,
		@StudentPayment = 325
Select Case @Status
  When +1 Then 'Payment Insert was successful!'
  When -1 Then 'Course Insert failed! Common Issues: Duplicate Data'
  End as [Status];
go

--SELECT * FROM vCourses;
--SELECT * FROM vStudents;
--SELECT * FROM vEnrollment;
--SELECT * FROM vPayment;
--go

Declare @Status int;
Exec @Status = pUpdateCourses
				@CourseID = 3,
				@CourseName = 'Poetry of the Andastalan Empire',
				@CourseStartDate = '1/3/2022',
				@CourseEndDate = '4/15/2022',
				@CourseCurrentPrice = 325,
                @ClassDays = 'MWF',
				@ClassStartTime = '9:00',
				@ClassEndTime = '9:50'
Select Case @Status
  When +1 Then 'Courses Update was successful!'
  When -1 Then 'Courses Update failed! Common Issues: Duplicate Data'
  End as [Status];
go

Declare @Status int;
Exec @Status = pUpdateStudents
				@StudentID = 3,
				@StudentFirstName = 'Fitzroy',
				@StudentLastName = 'Angursell',
				@StudentNum = 'F-Angursell-001',
				@StudentEmail = 'FAngursell@Andastalas.gov',
				@StudentPhone = '(425)760-9301',
				@StudentStreet = '125 Victor Ave',
				@StudentCity = 'Lake City',
				@StudentState = 'WA',
				@StudentCountry = 'United States',
				@StudentZip = '98133'
Select Case @Status
  When +1 Then 'Student Update was successful!'
  When -1 Then 'Student Update failed! Common Issues: Duplicate Data'
  End as [Status];
go

Declare @Status int;
Exec @Status = pUpdateEnrollment
				@EnrollmentID = 5,
				@CourseID = 3,
				@StudentID = 3,
				@EnrollmentDate = '11/24/2021',
				@CourseStudentPrice = 315
Select Case @Status
  When +1 Then 'Enrollment Update was successful!'
  When -1 Then 'Enrollment Update failed! Common Issues: Duplicate Data'
  End as [Status];
go

Declare @Status int;
Exec @Status = pUpdatePayment
				@PaymentID = 5,
				@EnrollmentID = 5,
				@CourseStudentPrice = 315,
				@StudentPayment = 315
Select Case @Status
  When +1 Then 'Payment Update was successful!'
  When -1 Then 'Payment Update failed! Common Issues: Duplicate Data'
  End as [Status];
go

--SELECT * FROM vCourses;
--SELECT * FROM vStudents;
--SELECT * FROM vEnrollment;
--SELECT * FROM vPayment;
--go

--Delete Sprocs!
--(I forgot I needed to do these in reverse
--order.  Hurrah for checking!)

Declare @Status int;
Exec @Status = pDelPayment
                @PaymentID = 5
Select Case @Status
  When +1 Then 'Payment Deletion was successful!'
  When -1 Then 'Payment Deletion failed! Did you provide the right Payment ID?'
  End as [Status];
go

Declare @Status int;
Exec @Status = pDelEnrollment
                @EnrollmentID = 5
Select Case @Status
  When +1 Then 'Enrollment Deletion was successful!'
  When -1 Then 'Enrollment Deletion failed! Did you provide the right Enrollment ID?'
  End as [Status];
go

--Note here that I have this as Course and then 
--Student.  Since neither of these tables have 
--Foreign Keys that are dependent on each other
--it doesn't matter in which order I delete them.

Declare @Status int;
Exec @Status = pDelCourses
                @CourseID = 3
Select Case @Status
  When +1 Then 'Course Deletion was successful!'
  When -1 Then 'Course Deletion failed! Did you provide the right Course ID?'
  End as [Status];
go

Declare @Status int;
Exec @Status = pDelStudents
                @StudentID = 3
Select Case @Status
  When +1 Then 'Student Deletion was successful!'
  When -1 Then 'Student Deletion failed! Did you provide the right Student ID?'
  End as [Status];
go

SELECT * FROM vCourses;
SELECT * FROM vStudents;
SELECT * FROM vEnrollment;
SELECT * FROM vPayment;
go

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/