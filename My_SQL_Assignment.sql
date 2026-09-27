-- =============================================
--  EXCELLENC SQL CAPSTONE PROJECT TEMPLATE
-- =============================================

-- SECTION 1: DATABASE CREATION
-- CREATE DATABASE EdTechLearnPro;
-- USE EdTechLearnPro;

CREATE DATABASE LearnproDM;
USE LearnProDB;




CREATE TABLE Students
(
    StudentID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(15) NOT NULL UNIQUE,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    RegistrationDate DATE NOT NULL DEFAULT(GETDATE()),
    IsActive BIT NOT NULL DEFAULT(1),

    CONSTRAINT CHK_Student_Email
    CHECK (Email LIKE '%@%.%')
);

-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table
select * from [dbo].[Students_900_copy];
select * from Students

--copy data into students table from newly createdtable
insert into Students select * from [dbo].[Students_900_copy];




--drop the copy table into which csv data is imported
  drop table  [dbo].[Students_900_copy];

CREATE TABLE Courses
(
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL UNIQUE,
    Category VARCHAR(50) NOT NULL,
    CourseFee DECIMAL(10,2) NOT NULL,

    DifficultyLevel VARCHAR(20) NOT NULL,

    CONSTRAINT CHK_CourseFee
    CHECK (CourseFee > 0),

    CONSTRAINT CHK_Difficulty
    CHECK (DifficultyLevel IN ('Beginner','Intermediate','Advanced'))
);

-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table
select * from Courses;

--copy data into courses table from newly createdtable
insert into Courses select * from [dbo].[Courses copy]

select * from [dbo].[Courses copy]

--drop the copy table into which csv data is imported
drop table [dbo].[Courses copy]

CREATE TABLE Trainers
(
    TrainerID INT PRIMARY KEY,
    TrainerName VARCHAR(100) NOT NULL,
    Expertise VARCHAR(100) NOT NULL,

    SatisfactionScore DECIMAL(3,2) NOT NULL,

    CONSTRAINT CHK_Satisfaction
    CHECK (SatisfactionScore BETWEEN 0 AND 5)
);

-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table 
select * from  Trainers;

--copy data into trainers table from newly createdtable
insert into trainers select * from [dbo].[Copy of Trainers]

select * from [dbo].[Copy of Trainers]

--drop the copy table into which csv data is imported
drop table[dbo].[Copy of Trainers]


CREATE TABLE TrainerCourseMapping
(
    MappingID INT PRIMARY KEY,

    TrainerID INT NOT NULL,

    CourseID INT NOT NULL,

    AssignedDate DATE NOT NULL,

    CONSTRAINT FK_Mapping_Trainer
    FOREIGN KEY (TrainerID)
    REFERENCES Trainers(TrainerID),

    CONSTRAINT FK_Mapping_Course
    FOREIGN KEY (CourseID)
    REFERENCES Courses(CourseID)
);

-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table 
select * from  TrainerCourseMapping

--copy data into TrainerCourseMapping table from newly createdtable
insert into TrainerCourseMapping select * from TrainerCourseMapping_copy

--drop the copy table into which csv data is imported
drop table TrainerCourseMapping_copy


CREATE TABLE Enrollments
(
    EnrollmentID INT PRIMARY KEY,

    StudentID INT NOT NULL,

    CourseID INT NOT NULL,

    EnrollmentDate DATE NOT NULL,

    Discount DECIMAL(5,2) NOT NULL DEFAULT(0),

    PaymentStatus VARCHAR(20) NOT NULL,

    CONSTRAINT FK_Enrollment_Student
    FOREIGN KEY(StudentID)
    REFERENCES Students(StudentID),

    CONSTRAINT FK_Enrollment_Course
    FOREIGN KEY(CourseID)
    REFERENCES Courses(CourseID),

    CONSTRAINT CHK_Discount
    CHECK (Discount>=0 AND Discount<=100),

    CONSTRAINT CHK_PaymentStatus
    CHECK (PaymentStatus IN ('Paid','Partially Paid','Unpaid'))
);

-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table 
select * from Enrollments_1200_copy
select * from Enrollments

ALTER TABLE Enrollments 
DROP CONSTRAINT CHK_PaymentStatus 

ALTER TABLE Enrollments 
ADD CONSTRAINT CHK_Enrollments_PaymentStatus 
CHECK (PaymentStatus IN ('Paid', 'Unpaid', 'Partially Paid'));

--copy data  Enrollments table form newly createdtable
insert into Enrollments select * from Enrollments_1200_copy

--drop the copy table into which csv data is imported
drop table   Enrollments_1200_copy

CREATE TABLE Payments
(
    PaymentID INT PRIMARY KEY,

    EnrollmentID INT NOT NULL UNIQUE,

    AmountPaid DECIMAL(10,2) NOT NULL,

    PaymentDate DATE NOT NULL,

    CONSTRAINT FK_Payment_Enrollment
    FOREIGN KEY (EnrollmentID)
    REFERENCES Enrollments(EnrollmentID),

    CONSTRAINT CHK_Amount
    CHECK (AmountPaid>=0)
);

-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table 
select * from [dbo].[Payments_1200_copy]
select * from Payments

--copy data   Payments table form newly createdtable
insert into  Payments select * from  [dbo].[Payments_1200_copy]

--drop the copy table into which csv data is imported
drop table  [dbo].[Payments_1200_copy]



 CREATE TABLE Marketing 
    (
     MarketingID INT IDENTITY(1,1) PRIMARY KEY,
     MonthYear DATE NOT NULL,
     Channel VARCHAR(50) NOT NULL,
     Spend DECIMAL(12,2) CHECK (Spend >= 0), 
     LeadsGenerated INT CHECK (LeadsGenerated >= 0) 
     );



-- convert excel file to csv file
-- import data directly from csv file using import wizard into new table 
select * from [dbo].[Marketing_72_copy]
select * from Marketing

--copy data into Marketing table from newly createdtable
insert into Marketing select * from [dbo].[Marketing_72_copy]

select * from  [dbo].[Marketing_72_copy]


--drop the copy table into which csv data is imported
drop table [dbo].[Marketing_72_copy]


-- Top 5 Cities by Enrollments
SELECT TOP 5
    s.City,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
GROUP BY s.City
ORDER BY TotalEnrollments DESC;


--Students Enrolled in More Than 2 Courses
SELECT
    s.StudentID,
    s.FullName,
    COUNT(e.CourseID) AS TotalCourses
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
GROUP BY
    s.StudentID,
    s.FullName
HAVING COUNT(e.CourseID) > 2;

--Students with No Payment
SELECT
    s.StudentID,
    s.FullName,
    e.PaymentStatus
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
LEFT JOIN Payments p
    ON e.EnrollmentID = p.EnrollmentID
WHERE e.PaymentStatus = 'Unpaid';

-- Highest revenue generating month. 

SELECT TOP (1)
    DATENAME(MONTH, PaymentDate) AS MonthName,
    SUM(AmountPaid) AS TotalRevenue
FROM Payments
GROUP BY DATENAME(MONTH, PaymentDate),
         MONTH(PaymentDate)
ORDER BY TotalRevenue DESC;

-- Top 3 most popular courses. 

SELECT TOP (3)
    c.CourseID,
    c.CourseName,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Courses c
INNER JOIN Enrollments e
    ON c.CourseID = e.CourseID
GROUP BY
    c.CourseID,
    c.CourseName
ORDER BY TotalEnrollments DESC;

--. Enrollments with discount above average discount. 

SELECT
    e.EnrollmentID,
    s.FullName,
    c.CourseName,
    e.Discount
FROM Enrollments e
INNER JOIN Students s
    ON e.StudentID = s.StudentID
INNER JOIN Courses c
    ON e.CourseID = c.CourseID
WHERE e.Discount >
(
    SELECT AVG(Discount)
    FROM Enrollments
)
ORDER BY e.Discount DESC;

 --States with more than 10 paid enrollments.  

 SELECT
    s.State,
    COUNT(e.EnrollmentID) AS TotalPaidEnrollments
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
WHERE e.PaymentStatus = 'Paid'
GROUP BY s.State
HAVING COUNT(e.EnrollmentID) > 10
ORDER BY TotalPaidEnrollments ;

-- SECTION 5: JOINS(ALL TYPES) 

--Students + Enrollments + Courses (STUDENT NAME + COURSE NAME + TRAINER NAME)

SELECT
    s.FullName,
    c.CourseName,
    t.TrainerName
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
INNER JOIN Courses c
    ON e.CourseID = c.CourseID
INNER JOIN TrainerCourseMapping tm
    ON c.CourseID = tm.CourseID
INNER JOIN Trainers t
    ON tm.TrainerID = t.TrainerID
ORDER BY
    s.FullName,
    c.CourseName;

    --Courses + TrainerCourseMapping + Trainers(TRAINER PERFORMANCE WITH NUMBER OF ASSIGNED COURSE)

    SELECT
    t.TrainerID,
    t.TrainerName,
    t.Expertise,
    COUNT(c.CourseID) AS TotalAssignedCourses
FROM Trainers t
INNER JOIN TrainerCourseMapping tm
    ON t.TrainerID = tm.TrainerID
INNER JOIN Courses c
    ON tm.CourseID = c.CourseID
GROUP BY
    t.TrainerID,
    t.TrainerName,
    t.Expertise
ORDER BY TotalAssignedCourses DESC;

--Enrollments + Payments(REVENUE PER COURSE) 
SELECT
    c.CourseName,
    SUM(p.AmountPaid) AS Revenue
FROM Courses c
INNER JOIN Enrollments e
ON c.CourseID=e.CourseID
INNER JOIN Payments p
ON e.EnrollmentID=p.EnrollmentID
GROUP BY
    c.CourseName
ORDER BY
    Revenue DESC;

 -- Revenue per course  

SELECT
    c.CourseName,
    SUM(p.AmountPaid) AS TotalRevenue
FROM Courses c
INNER JOIN Enrollments e
    ON c.CourseID = e.CourseID
INNER JOIN Payments p
    ON e.EnrollmentID = p.EnrollmentID
GROUP BY c.CourseName
ORDER BY TotalRevenue DESC;

-- City wise + course wise revenue summary

SELECT
    s.City,
    c.CourseName,
    COUNT(e.EnrollmentID) AS TotalEnrollments,
    SUM(p.AmountPaid) AS TotalRevenue,
    AVG(p.AmountPaid) AS AverageRevenue
FROM Students s
INNER JOIN Enrollments e
    ON s.StudentID = e.StudentID
INNER JOIN Courses c
    ON e.CourseID = c.CourseID
INNER JOIN Payments p
    ON e.EnrollmentID = p.EnrollmentID
GROUP BY
    s.City,
    c.CourseName
ORDER BY
    s.City ASC,
    TotalRevenue DESC;

--PART 6 — GROUP BY + HAVING + AGGREGATION 

--Monthly Revenue

SELECT
    YEAR(PaymentDate) AS Year,
    MONTH(PaymentDate) AS Month,
    COUNT(PaymentID) AS TotalPayments,
    SUM(AmountPaid) AS TotalRevenue,
    AVG(AmountPaid) AS AveragePayment,
    MIN(AmountPaid) AS MinimumPayment,
    MAX(AmountPaid) AS MaximumPayment
FROM Payments
GROUP BY
    YEAR(PaymentDate),
    MONTH(PaymentDate)
ORDER BY
    Year,
    Month;

  -- Enrollment counts per course 

  SELECT
    c.CourseID,
    c.CourseName,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Courses c
INNER JOIN Enrollments e
    ON c.CourseID = e.CourseID
GROUP BY
    c.CourseID,
    c.CourseName
ORDER BY
    TotalEnrollments DESC;

-- Average fee per category 

SELECT
    Category,
    COUNT(CourseID) AS TotalCourses,
    AVG(CourseFee) AS AverageFee,
    MIN(CourseFee) AS MinimumFee,
    MAX(CourseFee) AS MaximumFee
FROM Courses
GROUP BY Category
ORDER BY AverageFee DESC;

--Trainer Satisfaction Averages

SELECT
    Expertise,
    COUNT(TrainerID) AS TotalTrainers,
    AVG(SatisfactionScore) AS AverageSatisfaction,
    MIN(SatisfactionScore) AS MinimumRating,
    MAX(SatisfactionScore) AS MaximumRating
FROM Trainers
GROUP BY Expertise
ORDER BY AverageSatisfaction DESC;

-- State wise registration patterns  

SELECT
    s.State,
    COUNT(s.StudentID) AS TotalRegistrations
FROM Students s
GROUP BY s.State
ORDER BY TotalRegistrations DESC;

--PART 7 — SUBQUERIES + CTEs 

-- Courses with above average enrollments

SELECT
    c.CourseID,
    c.CourseName,
    COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Courses c
INNER JOIN Enrollments e
ON c.CourseID = e.CourseID
GROUP BY
    c.CourseID,
    c.CourseName
HAVING COUNT(e.EnrollmentID) >
(
    SELECT AVG(EnrollmentCount)
    FROM
    (
        SELECT COUNT(*) AS EnrollmentCount
        FROM Enrollments
        GROUP BY CourseID
    ) AS AvgEnrollments
);

--Students Enrolled in the Most Expensive Course

SELECT
    s.StudentID,
    s.FullName,
    c.CourseName,
    c.CourseFee
FROM Students s
INNER JOIN Enrollments e
ON s.StudentID=e.StudentID
INNER JOIN Courses c
ON e.CourseID=c.CourseID
WHERE c.CourseFee=
(
    SELECT MAX(CourseFee)
    FROM Courses
);

--Highest Discount Enrollment Details

SELECT
    e.EnrollmentID,
    s.FullName,
    c.CourseName,
    e.Discount
FROM Enrollments e
INNER JOIN Students s
ON e.StudentID=s.StudentID
INNER JOIN Courses c
ON e.CourseID=c.CourseID
WHERE e.Discount=
(
    SELECT MAX(Discount)
    FROM Enrollments
);

--Revenue Trend using CTE (Last 6 Months)

WITH MonthlyRevenue AS
(
    SELECT
        YEAR(PaymentDate) AS Year,
        MONTH(PaymentDate) AS Month,
        SUM(AmountPaid) AS TotalRevenue
    FROM Payments
    WHERE PaymentDate >= DATEADD(MONTH,-6,GETDATE())
    GROUP BY
        YEAR(PaymentDate),
        MONTH(PaymentDate)
)

SELECT *
FROM MonthlyRevenue
ORDER BY
Year,
Month;

--PART 8 — WINDOW FUNCTIONS 

--RANK() – Revenue Per Month

SELECT
    YEAR(PaymentDate) AS Year,
    MONTH(PaymentDate) AS Month,
    SUM(AmountPaid) AS TotalRevenue,
    RANK() OVER(ORDER BY SUM(AmountPaid) DESC) AS RevenueRank
FROM Payments
GROUP BY
    YEAR(PaymentDate),
    MONTH(PaymentDate)
ORDER BY RevenueRank;

-- DENSE_RANK() top 3 courses per month 

WITH CourseEnrollment AS
(
    SELECT
        YEAR(e.EnrollmentDate) AS Year,
        MONTH(e.EnrollmentDate) AS Month,
        c.CourseName,
        COUNT(e.EnrollmentID) AS TotalEnrollments
    FROM Enrollments e
    INNER JOIN Courses c
        ON e.CourseID = c.CourseID
    GROUP BY
        YEAR(e.EnrollmentDate),
        MONTH(e.EnrollmentDate),
        c.CourseName
)

SELECT *
FROM
(
    SELECT *,
        DENSE_RANK() OVER
        (
            PARTITION BY Year, Month
            ORDER BY TotalEnrollments DESC
        ) AS CourseRank
    FROM CourseEnrollment
) AS RankedCourses
WHERE CourseRank <= 3;

--LAG() – Month-over-Month Revenue Change

WITH MonthlyRevenue AS
(
    SELECT
        YEAR(PaymentDate) AS Year,
        MONTH(PaymentDate) AS Month,
        SUM(AmountPaid) AS TotalRevenue
    FROM Payments
    GROUP BY
        YEAR(PaymentDate),
        MONTH(PaymentDate)
)

SELECT
    Year,
    Month,
    TotalRevenue,
    LAG(TotalRevenue) OVER(ORDER BY Year, Month) AS PreviousMonthRevenue,
    TotalRevenue -
    LAG(TotalRevenue) OVER(ORDER BY Year, Month) AS RevenueDifference
FROM MonthlyRevenue;

--LEAD() – Forecast Next Month Trend

WITH MonthlyRevenue AS
(
    SELECT
        YEAR(PaymentDate) AS Year,
        MONTH(PaymentDate) AS Month,
        SUM(AmountPaid) AS TotalRevenue
    FROM Payments
    GROUP BY
        YEAR(PaymentDate),
        MONTH(PaymentDate)
)

SELECT
    Year,
    Month,
    TotalRevenue,
    LEAD(TotalRevenue) OVER(ORDER BY Year, Month) AS NextMonthRevenue
FROM MonthlyRevenue;

-- ROW_NUMBER() for duplicate detection -- again check


SELECT
    StudentID,
    FullName,
    Email,
    ROW_NUMBER() OVER
    (
        PARTITION BY Email
        ORDER BY StudentID
    ) AS RowNum
FROM Students;

 WITH DuplicateStudents AS
(
    SELECT
        StudentID,
        FullName,
        Email,
        ROW_NUMBER() OVER
        (
            PARTITION BY Email
            ORDER BY StudentID
        ) AS RowNum
    FROM Students
)

SELECT *
FROM DuplicateStudents
WHERE RowNum > 1;

--PART 9 — VIEWS  

--vw_MonthlyRevenue

CREATE VIEW vw_MonthlyRevenue
AS
SELECT
    YEAR(p.PaymentDate) AS Year,
    MONTH(p.PaymentDate) AS Month,
    COUNT(p.PaymentID) AS TotalPayments,
    SUM(p.AmountPaid) AS TotalRevenue,
    AVG(p.AmountPaid) AS AverageRevenue,
    MIN(p.AmountPaid) AS MinimumPayment,
    MAX(p.AmountPaid) AS MaximumPayment
FROM Payments p
GROUP BY
    YEAR(p.PaymentDate),
    MONTH(p.PaymentDate);
GO

SELECT * FROM vw_MonthlyRevenue;

--vw_TrainerPerformance

CREATE VIEW vw_TrainerPerformance
AS
SELECT
    t.TrainerID,
    t.TrainerName,
    t.Expertise,
    COUNT(DISTINCT tm.CourseID) AS TotalCourses,
    COUNT(e.StudentID) AS TotalStudents,
    SUM(p.AmountPaid) AS TotalRevenue,
    AVG(t.SatisfactionScore) AS AverageSatisfaction
FROM Trainers t
INNER JOIN TrainerCourseMapping tm
    ON t.TrainerID = tm.TrainerID
INNER JOIN Enrollments e
    ON tm.CourseID = e.CourseID
INNER JOIN Payments p
    ON e.EnrollmentID = p.EnrollmentID
GROUP BY
    t.TrainerID,
    t.TrainerName,
    t.Expertise;
GO

SELECT * FROM vw_TrainerPerformance;

-- SECTION 10: INDEXES
-- Index 1 : Students.Email
CREATE INDEX IX_Students_Email
ON Students(Email);
--FOR CHECKING INDEX
EXEC sp_helpindex 'Students';

-- Index 2 : Courses.CourseName
CREATE INDEX IX_Courses_CourseName
ON Courses(CourseName);
--FOR CHECKING INDEX
EXEC sp_helpindex 'Courses';
-- Index 3 : Enrollment Date
CREATE INDEX IX_Enrollments_EnrollmentDate
ON Enrollments(EnrollmentDate);
--FOR CHECKING INDEX
EXEC sp_helpindex 'Enrollments';
-- Index 4 : Composite Index(StudentID,CourseID)
CREATE INDEX IX_Enrollments_Student_Course
ON Enrollments(StudentID, CourseID);
--FOR CHECKING INDEX
EXEC sp_helpindex 'Enrollments';

/* 
Q1.Why Each Index Improves Performance? 
ANS- Indexes improve query performance by allowing SQL Server to locate data quickly without scanning the entire table. 
They reduce data retrieval time for searching, filtering, sorting, and joining operations. In this project, indexes on 
Students.Email, Courses.CourseName, Enrollments.EnrollmentDate, and the composite index on (StudentID, CourseID) help 
optimize common search, reporting, and join queries, making the database more efficient.


Q2.Where Indexing is Unnecessary?
ANS- Indexing is unnecessary on columns that have very few distinct values (low selectivity), such as PaymentStatus
(Paid, Unpaid, Partially Paid). These indexes usually provide little performance benefit. Similarly, creating indexes
on very small tables or adding too many indexes can reduce performance because SQL Server must update every index during 
INSERT, UPDATE, and DELETE operations.
*/

-- SECTION 11: STORED PROCEDURES
-- Procedure 1 : Fetch Monthly Revenue
CREATE PROCEDURE sp_GetMonthlyRevenue
    @Month INT
AS
BEGIN

    SELECT
        YEAR(PaymentDate) AS RevenueYear,
        MONTH(PaymentDate) AS RevenueMonth,
        SUM(AmountPaid) AS TotalRevenue
    FROM Payments
    WHERE MONTH(PaymentDate) = @Month
    GROUP BY
        YEAR(PaymentDate),
        MONTH(PaymentDate);

END; 
--FOR CHECK RUN THIS COMMAND (IN @Month you enter your won value then it give this month total revenue only)
EXEC sp_GetMonthlyRevenue @Month = 4;

-- Procedure 2 : Add New Student with Validation
CREATE PROCEDURE sp_AddStudent
(
    @FullName VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @RegistrationDate DATE,
    @IsActive BIT
)
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Students
        WHERE Email = @Email
    )
    BEGIN
        PRINT 'Student with this email already exists.';
    END

    ELSE
    BEGIN

        INSERT INTO Students
        (
            FullName,
            Email,
            Phone,
            City,
            State,
            RegistrationDate,
            IsActive
        )

        VALUES
        (
            @FullName,
            @Email,
            @Phone,
            @City,
            @State,
            @RegistrationDate,
            @IsActive
        );

        PRINT 'Student added successfully.';

    END

END;
--FOR CHECK RUN THIS COMMAND 
EXEC sp_AddStudent
    @FullName = 'Rahul Sharma',
    @Email = 'rahul@gmail.com',
    @Phone = '9876543210',
    @City = 'Delhi',
    @State = 'Delhi',
    @RegistrationDate = '2025-07-15',
    @IsActive = 1;
-- Procedure 3 :Getting Trainer Performance above a threshold(OUT)
CREATE PROCEDURE sp_TrainerPerformance
(
    @MinCourses INT,
    @TrainerCount INT OUTPUT
)
AS
BEGIN

    SELECT
        t.TrainerID,
        t.TrainerName,
        COUNT(c.CourseID) AS TotalAssignedCourses
    FROM Trainers t
    INNER JOIN TrainerCourseMapping tm
        ON t.TrainerID = tm.TrainerID
    INNER JOIN Courses c
        ON tm.CourseID = c.CourseID
    GROUP BY
        t.TrainerID,
        t.TrainerName
    HAVING COUNT(c.CourseID) >= @MinCourses;

    SELECT
        @TrainerCount = COUNT(*)
    FROM
    (
        SELECT
            t.TrainerID
        FROM Trainers t
        INNER JOIN TrainerCourseMapping tm
            ON t.TrainerID = tm.TrainerID
        GROUP BY
            t.TrainerID
        HAVING COUNT(tm.CourseID) >= @MinCourses
    ) AS T;

END;
--FOR CHECK RUN THIS COMMAND 
DECLARE @Count INT;

EXEC sp_TrainerPerformance
    @MinCourses = 2,
    @TrainerCount = @Count OUTPUT;

SELECT @Count AS TotalQualifiedTrainers; 

-- SECTION 12:USER DEFINED FUNCTIONS
--Create Scalar Function → fn_NetFeeAfterDiscount
CREATE FUNCTION fn_NetFeeAfterDiscount
(
    @CourseFee DECIMAL(10,2),
    @Discount DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN

    RETURN @CourseFee - (@CourseFee * @Discount / 100);

END;
--EXECUTE THIS COMMAND FOR SHOW OUTPUT 
SELECT dbo.fn_NetFeeAfterDiscount(50000,10) AS NetFee;

--Create Table-Valued Function → Return Enrollments by Course
CREATE FUNCTION fn_EnrollmentsByCourse
(
    @CourseID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        e.EnrollmentID,
        s.StudentID,
        s.FullName,
        c.CourseName,
        e.EnrollmentDate,
        e.Discount,
        e.PaymentStatus
    FROM Enrollments e
    INNER JOIN Students s
        ON e.StudentID = s.StudentID
    INNER JOIN Courses c
        ON e.CourseID = c.CourseID
    WHERE e.CourseID = @CourseID
);
--EXECUTE THIS COMMAND FOR SHOW OUTPUT 
SELECT *
FROM dbo.fn_EnrollmentsByCourse(504); 

-- SECTION 13: EXCEPTION HANDLING
-- Create ErrorLog Table
CREATE TABLE ErrorLog
(
    ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorNumber INT,
    ErrorMessage NVARCHAR(4000),
    ErrorProcedure NVARCHAR(200),
    ErrorLine INT,
    ErrorDate DATETIME DEFAULT GETDATE()
);

-- TRY...CATCH inside Stored Procedure
--FIRST DELETE THE EXSISTING STORED POSEDURE THEN MAKE AGAIN USING TRAY...CATH
DROP PROCEDURE IF EXISTS sp_AddStudent;
GO

--MAKE STORED PROCEDURES USING TRY...CATCH
CREATE PROCEDURE sp_AddStudent
(
    @FullName VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @RegistrationDate DATE,
    @IsActive BIT
)
AS
BEGIN

    BEGIN TRY

        INSERT INTO Students
        (
            FullName,
            Email,
            Phone,
            City,
            State,
            RegistrationDate,
            IsActive
        )
        VALUES
        (
            @FullName,
            @Email,
            @Phone,
            @City,
            @State,
            @RegistrationDate,
            @IsActive
        );

        PRINT 'Student added successfully.';

    END TRY

    BEGIN CATCH

        INSERT INTO ErrorLog
        (
            ErrorNumber,
            ErrorMessage,
            ErrorProcedure,
            ErrorLine
        )
        VALUES
        (
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_PROCEDURE(),
            ERROR_LINE()
        );

        PRINT 'Unable to add student. Please check the data and try again.';

    END CATCH

END;
GO

--Test the Procedure
EXEC sp_AddStudent
    @FullName = 'Rahul Sharma',
    @Email = 'rahul@gmail.com',
    @Phone = '9876543210',
    @City = 'Delhi',
    @State = 'Delhi',
    @RegistrationDate = '2025-07-18',
    @IsActive = 1;
    --EXECUTE ERRORLOG TABLE
    SELECT * FROM ErrorLog
---- SECTION 14: TRIGGERS
-- Q1 : Prevent Discount > 50%
CREATE TRIGGER trg_PreventHighDiscount
ON Enrollments
INSTEAD OF INSERT
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM inserted
        WHERE Discount > 50
    )
    BEGIN
        RAISERROR('Discount cannot be greater than 50%%.',16,1);
        RETURN;
    END;

    INSERT INTO Enrollments
    (
        StudentID,
        CourseID,
        EnrollmentDate,
        Discount,
        PaymentStatus
    )

    SELECT
        StudentID,
        CourseID,
        EnrollmentDate,
        Discount,
        PaymentStatus
    FROM inserted;

END;
GO
--FOR TESTING THIS TRIGGER
INSERT INTO Enrollments
(
    StudentID,
    CourseID,
    EnrollmentDate,
    Discount,
    PaymentStatus
)

VALUES
(
    1001,
    501,
    GETDATE(),
    50,
    'Paid'
);

--AFTER INSERT → Auto insert AmountPaid = 0 when PaymentStatus = 'Unpaid'
CREATE TRIGGER trg_AutoInsertPayment
ON Enrollments
AFTER INSERT
AS
BEGIN

    INSERT INTO Payments
    (
        EnrollmentID,
        AmountPaid,
        PaymentDate
    )

    SELECT
        EnrollmentID,
        0,
        GETDATE()
    FROM inserted
    WHERE PaymentStatus = 'Unpaid';

END;
GO
--FOR TESTING THIS TRIGGER RUN THIS COMMAND
INSERT INTO Enrollments
(
    StudentID,
    CourseID,
    EnrollmentDate,
    Discount,
    PaymentStatus
)

VALUES
(
    1005,
    502,
    GETDATE(),
    10,
    'Unpaid'
);
--FOR VERIFYING RUN THIS COMMAND
SELECT *
FROM Payments
ORDER BY PaymentID DESC;

--AFTER UPDATE → Log Old + New Values INTO AUDITLOG TABLE 

--First create the audit table.
CREATE TABLE AuditLog
(
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID INT,
    OldAmount DECIMAL(10,2),
    NewAmount DECIMAL(10,2),
    UpdatedOn DATETIME DEFAULT GETDATE()
);

--Now create the trigger.
CREATE TRIGGER trg_AuditPaymentUpdate
ON Payments
AFTER UPDATE
AS
BEGIN

    INSERT INTO AuditLog
    (
        PaymentID,
        OldAmount,
        NewAmount
    )

    SELECT
        d.PaymentID,
        d.AmountPaid,
        i.AmountPaid
    FROM deleted d
    INNER JOIN inserted i
        ON d.PaymentID = i.PaymentID;

END;
GO
--FOR TESTING TRIGGER 
UPDATE Payments
SET AmountPaid = AmountPaid + 500
WHERE PaymentID = 1;
--FOR CHECKING AUDITLOG TABLE DATA ARE INSERT OR NOT 
SELECT *
FROM AuditLog;

-- SECTION 15: FINAL ANALYTICAL INSIGHTS 
--CAC (Cost Per Acquisition) & ROI per Marketing Channel
SELECT

    Channel,

    SUM(Spend) AS TotalSpend,

    SUM(LeadsGenerated) AS TotalLeads,

    ROUND(
        SUM(Spend) * 1.0 / SUM(LeadsGenerated),
        2
    ) AS CAC

FROM Marketing

GROUP BY Channel

ORDER BY CAC;

--12 Month Enrollment Heatmap (Month × City)
SELECT
    DATENAME(MONTH,e.EnrollmentDate) AS Month,
    s.City,
    COUNT(*) AS TotalEnrollments
FROM Students s
INNER JOIN Enrollments e
ON s.StudentID = e.StudentID
GROUP BY
DATENAME(MONTH,e.EnrollmentDate),
MONTH(e.EnrollmentDate),
s.City
ORDER BY
MONTH(e.EnrollmentDate),
s.City;

--Top Course & Worst Course by Revenue
SELECT
    c.CourseName,
    SUM(p.AmountPaid) AS TotalRevenue
FROM Courses c
INNER JOIN Enrollments e
ON c.CourseID = e.CourseID
INNER JOIN Payments p
ON e.EnrollmentID = p.EnrollmentID
GROUP BY
    c.CourseName
ORDER BY
    TotalRevenue DESC;
/* 
Top row = Best course
Last row = Worst course 
*/

--Trainer Impact on Course Satisfaction
SELECT
    t.TrainerName,
    AVG(t.SatisfactionScore) AS AverageSatisfaction,
    COUNT(tcm.CourseID) AS AssignedCourses
FROM Trainers t
INNER JOIN TrainerCourseMapping tcm
ON t.TrainerID = tcm.TrainerID
GROUP BY
    t.TrainerName
ORDER BY
    AverageSatisfaction DESC;

--Month over month bussiness growth
SELECT
    YEAR(PaymentDate) AS Year,
    MONTH(PaymentDate) AS Month,
    SUM(AmountPaid) AS Revenue,

    LAG(SUM(AmountPaid))
    OVER
    (
        ORDER BY YEAR(PaymentDate), MONTH(PaymentDate)
    ) AS PreviousMonthRevenue,

    SUM(AmountPaid)
    -
    LAG(SUM(AmountPaid))
    OVER
    (
        ORDER BY YEAR(PaymentDate), MONTH(PaymentDate)
    ) AS RevenueGrowth

FROM Payments

GROUP BY
    YEAR(PaymentDate),
    MONTH(PaymentDate)

ORDER BY
    Year,
    Month;

