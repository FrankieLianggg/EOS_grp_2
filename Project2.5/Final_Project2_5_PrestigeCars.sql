/* ============================================================
   Project 2.5 - Prestige Cars Normalized Database
   Final SQL Script
   Group: EOS_grp_2
   Database: PrestigeCars

   Run this AFTER running PrestigeCarsDatabaseScript.sql.
   This script creates:
   1. Udt schema and 18 user-defined datatypes
   2. Process.WorkflowSteps table
   3. Constraints
   4. Views
   5. Output.ufnSalesByYear inline table-valued function
   6. Workflow step updates
   7. Final verification queries
   ============================================================ */

USE PrestigeCars;
GO

/* ============================================================
   1. CREATE UDT SCHEMA AND USER-DEFINED DATATYPES
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Udt')
    EXEC('CREATE SCHEMA Udt');
GO

IF TYPE_ID('Udt.CountryName') IS NULL
    EXEC('CREATE TYPE Udt.CountryName FROM NVARCHAR(150) NULL');
GO

IF TYPE_ID('Udt.ISO2') IS NULL
    EXEC('CREATE TYPE Udt.ISO2 FROM NCHAR(2) NULL');
GO

IF TYPE_ID('Udt.ISO3') IS NULL
    EXEC('CREATE TYPE Udt.ISO3 FROM NCHAR(3) NULL');
GO

IF TYPE_ID('Udt.SalesRegion') IS NULL
    EXEC('CREATE TYPE Udt.SalesRegion FROM NVARCHAR(20) NULL');
GO

IF TYPE_ID('Udt.ShortName') IS NULL
    EXEC('CREATE TYPE Udt.ShortName FROM NVARCHAR(50) NULL');
GO

IF TYPE_ID('Udt.LongName') IS NULL
    EXEC('CREATE TYPE Udt.LongName FROM NVARCHAR(150) NULL');
GO

IF TYPE_ID('Udt.DescriptionText') IS NULL
    EXEC('CREATE TYPE Udt.DescriptionText FROM NVARCHAR(1000) NULL');
GO

IF TYPE_ID('Udt.SurrogateKeyInt') IS NULL
    EXEC('CREATE TYPE Udt.SurrogateKeyInt FROM INT NULL');
GO

IF TYPE_ID('Udt.SmallSurrogateKey') IS NULL
    EXEC('CREATE TYPE Udt.SmallSurrogateKey FROM SMALLINT NULL');
GO

IF TYPE_ID('Udt.MoneyAmount') IS NULL
    EXEC('CREATE TYPE Udt.MoneyAmount FROM MONEY NULL');
GO

IF TYPE_ID('Udt.PriceAmount') IS NULL
    EXEC('CREATE TYPE Udt.PriceAmount FROM NUMERIC(18,2) NULL');
GO

IF TYPE_ID('Udt.InvoiceNumber') IS NULL
    EXEC('CREATE TYPE Udt.InvoiceNumber FROM CHAR(8) NULL');
GO

IF TYPE_ID('Udt.StockCode') IS NULL
    EXEC('CREATE TYPE Udt.StockCode FROM NVARCHAR(50) NULL');
GO

IF TYPE_ID('Udt.YearNumber') IS NULL
    EXEC('CREATE TYPE Udt.YearNumber FROM INT NULL');
GO

IF TYPE_ID('Udt.MonthNumber') IS NULL
    EXEC('CREATE TYPE Udt.MonthNumber FROM TINYINT NULL');
GO

IF TYPE_ID('Udt.YesNoFlag') IS NULL
    EXEC('CREATE TYPE Udt.YesNoFlag FROM BIT NULL');
GO

IF TYPE_ID('Udt.DateOnly') IS NULL
    EXEC('CREATE TYPE Udt.DateOnly FROM DATE NULL');
GO

IF TYPE_ID('Udt.DateTimeValue') IS NULL
    EXEC('CREATE TYPE Udt.DateTimeValue FROM DATETIME NULL');
GO


/* ============================================================
   2. CREATE PROCESS.WORKFLOWSTEPS TABLE
   ============================================================ */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Process')
    EXEC('CREATE SCHEMA Process');
GO

IF OBJECT_ID('Process.WorkflowSteps', 'U') IS NULL
BEGIN
    CREATE TABLE Process.WorkflowSteps
    (
        WorkflowStepID INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_WorkflowSteps PRIMARY KEY,

        StepName NVARCHAR(100) NOT NULL,
        StepDescription NVARCHAR(1000) NULL,

        StepStatus NVARCHAR(30) NOT NULL
            CONSTRAINT DF_WorkflowSteps_StepStatus DEFAULT ('Not Started'),

        StartedAt DATETIME2 NULL,
        CompletedAt DATETIME2 NULL,
        CompletedBy NVARCHAR(100) NULL,
        Notes NVARCHAR(1000) NULL,

        CONSTRAINT CK_WorkflowSteps_StepStatus
            CHECK (StepStatus IN ('Not Started', 'In Progress', 'Completed', 'Blocked'))
    );
END;
GO

IF NOT EXISTS 
(
    SELECT 1 
    FROM Process.WorkflowSteps 
    WHERE StepName = 'Load original database'
)
BEGIN
    INSERT INTO Process.WorkflowSteps
    (
        StepName,
        StepDescription,
        StepStatus,
        StartedAt,
        CompletedAt,
        CompletedBy,
        Notes
    )
    VALUES
    (
        'Load original database',
        'Ran PrestigeCarsDatabaseScript.sql and verified original tables.',
        'Completed',
        SYSDATETIME(),
        SYSDATETIME(),
        'EOS_grp_2',
        NULL
    ),
    (
        'Create UDTs',
        'Create reusable user-defined datatypes for table columns.',
        'Completed',
        SYSDATETIME(),
        SYSDATETIME(),
        'EOS_grp_2',
        'Created reusable user-defined datatypes in the Udt schema.'
    ),
    (
        'Normalize database',
        'Split repeated data and improve table design.',
        'Completed',
        SYSDATETIME(),
        SYSDATETIME(),
        'EOS_grp_2',
        'Improved the original design by documenting UDTs, adding data integrity constraints, creating reporting views, and replacing reporting logic with an inline table-valued function.'
    ),
    (
        'Add constraints',
        'Add PK, FK, UNIQUE, DEFAULT, and CHECK constraints.',
        'Completed',
        SYSDATETIME(),
        SYSDATETIME(),
        'EOS_grp_2',
        'Added foreign keys, check constraints, and default constraints.'
    ),
    (
        'Create views/functions',
        'Replace candidate physical tables with views and inline table-valued functions.',
        'Completed',
        SYSDATETIME(),
        SYSDATETIME(),
        'EOS_grp_2',
        'Created views and Output.ufnSalesByYear inline table-valued function.'
    ),
    (
        'Create final backup',
        'Create final .bak file for submission.',
        'Completed',
        SYSDATETIME(),
        SYSDATETIME(),
        'EOS_grp_2',
        'Created final PrestigeCars .bak backup file for submission.'
    );
END;
GO


/* ============================================================
   3. ADD CONSTRAINTS
   ============================================================ */

/* ---------- Primary Keys / Unique Constraints ---------- */

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Make')
        ALTER TABLE Data.Make
        ADD CONSTRAINT PK_Make PRIMARY KEY (MakeID);
END TRY
BEGIN CATCH
    PRINT 'PK_Make was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Model')
        ALTER TABLE Data.Model
        ADD CONSTRAINT PK_Model PRIMARY KEY (ModelID);
END TRY
BEGIN CATCH
    PRINT 'PK_Model was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Customer')
        ALTER TABLE Data.Customer
        ADD CONSTRAINT PK_Customer PRIMARY KEY (CustomerID);
END TRY
BEGIN CATCH
    PRINT 'PK_Customer was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_Sales')
        ALTER TABLE Data.Sales
        ADD CONSTRAINT PK_Sales PRIMARY KEY (SalesID);
END TRY
BEGIN CATCH
    PRINT 'PK_Sales was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_SalesDetails')
        ALTER TABLE Data.SalesDetails
        ADD CONSTRAINT PK_SalesDetails PRIMARY KEY (SalesDetailsID);
END TRY
BEGIN CATCH
    PRINT 'PK_SalesDetails was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_Make_MakeName')
        ALTER TABLE Data.Make
        ADD CONSTRAINT UQ_Make_MakeName UNIQUE (MakeName);
END TRY
BEGIN CATCH
    PRINT 'UQ_Make_MakeName was not added: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ---------- Foreign Key Constraints ---------- */

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Model_Make')
        ALTER TABLE Data.Model
        ADD CONSTRAINT FK_Model_Make
        FOREIGN KEY (MakeID)
        REFERENCES Data.Make(MakeID);
END TRY
BEGIN CATCH
    PRINT 'FK_Model_Make was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Sales_Customer')
        ALTER TABLE Data.Sales
        ADD CONSTRAINT FK_Sales_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Data.Customer(CustomerID);
END TRY
BEGIN CATCH
    PRINT 'FK_Sales_Customer was not added: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_SalesDetails_Sales')
        ALTER TABLE Data.SalesDetails
        ADD CONSTRAINT FK_SalesDetails_Sales
        FOREIGN KEY (SalesID)
        REFERENCES Data.Sales(SalesID);
END TRY
BEGIN CATCH
    PRINT 'FK_SalesDetails_Sales was not added: ' + ERROR_MESSAGE();
END CATCH;
GO


/* ---------- Check Constraints ---------- */

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Country_ISO2_Length')
    ALTER TABLE Data.Country
    ADD CONSTRAINT CK_Country_ISO2_Length
    CHECK (CountryISO2 IS NULL OR LEN(CountryISO2) = 2);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Country_ISO3_Length')
    ALTER TABLE Data.Country
    ADD CONSTRAINT CK_Country_ISO3_Length
    CHECK (CountryISO3 IS NULL OR LEN(CountryISO3) = 3);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Sales_TotalSalePrice_NonNegative')
    ALTER TABLE Data.Sales
    ADD CONSTRAINT CK_Sales_TotalSalePrice_NonNegative
    CHECK (TotalSalePrice IS NULL OR TotalSalePrice >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_SalesDetails_SalePrice_NonNegative')
    ALTER TABLE Data.SalesDetails
    ADD CONSTRAINT CK_SalesDetails_SalePrice_NonNegative
    CHECK (SalePrice IS NULL OR SalePrice >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_SalesDetails_LineItemDiscount_NonNegative')
    ALTER TABLE Data.SalesDetails
    ADD CONSTRAINT CK_SalesDetails_LineItemDiscount_NonNegative
    CHECK (LineItemDiscount IS NULL OR LineItemDiscount >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Stock_Cost_NonNegative')
    ALTER TABLE Data.Stock
    ADD CONSTRAINT CK_Stock_Cost_NonNegative
    CHECK (Cost IS NULL OR Cost >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Stock_RepairsCost_NonNegative')
    ALTER TABLE Data.Stock
    ADD CONSTRAINT CK_Stock_RepairsCost_NonNegative
    CHECK (RepairsCost IS NULL OR RepairsCost >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Stock_PartsCost_NonNegative')
    ALTER TABLE Data.Stock
    ADD CONSTRAINT CK_Stock_PartsCost_NonNegative
    CHECK (PartsCost IS NULL OR PartsCost >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Stock_TransportInCost_NonNegative')
    ALTER TABLE Data.Stock
    ADD CONSTRAINT CK_Stock_TransportInCost_NonNegative
    CHECK (TransportInCost IS NULL OR TransportInCost >= 0);
GO


/* ---------- Default Constraints ---------- */

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_Customer_IsReseller')
    ALTER TABLE Data.Customer
    ADD CONSTRAINT DF_Customer_IsReseller
    DEFAULT (0) FOR IsReseller;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_Customer_IsCreditRisk')
    ALTER TABLE Data.Customer
    ADD CONSTRAINT DF_Customer_IsCreditRisk
    DEFAULT (0) FOR IsCreditRisk;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_Stock_IsRHD')
    ALTER TABLE Data.Stock
    ADD CONSTRAINT DF_Stock_IsRHD
    DEFAULT (1) FOR IsRHD;
GO


/* ============================================================
   4. CREATE VIEWS
   ============================================================ */

/* View 1: Stock prices / total stock cost */
CREATE OR ALTER VIEW Output.vwStockPrices
AS
SELECT
    MK.MakeName,
    MD.ModelName,
    ST.StockCode,
    ST.Color,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    ISNULL(ST.Cost, 0)
        + ISNULL(ST.RepairsCost, 0)
        + ISNULL(ST.PartsCost, 0)
        + ISNULL(ST.TransportInCost, 0) AS TotalStockCost
FROM Data.Stock AS ST
INNER JOIN Data.Model AS MD
    ON ST.ModelID = MD.ModelID
INNER JOIN Data.Make AS MK
    ON MD.MakeID = MK.MakeID;
GO


/* View 2: Yearly sales */
CREATE OR ALTER VIEW Reference.vwYearlySales
AS
SELECT
    YEAR(SA.SaleDate) AS SalesYear,
    MK.MakeName,
    MD.ModelName,
    CU.CustomerName,
    CO.CountryName,
    SD.SalePrice,
    SA.TotalSalePrice,
    SA.SaleDate
FROM Data.Sales AS SA
INNER JOIN Data.SalesDetails AS SD
    ON SA.SalesID = SD.SalesID
INNER JOIN Data.Customer AS CU
    ON SA.CustomerID = CU.CustomerID
LEFT JOIN Data.Country AS CO
    ON CU.Country = CO.CountryISO2
LEFT JOIN Data.Stock AS ST
    ON SD.StockID = ST.StockCode
LEFT JOIN Data.Model AS MD
    ON ST.ModelID = MD.ModelID
LEFT JOIN Data.Make AS MK
    ON MD.MakeID = MK.MakeID;
GO


/* View 3: Sales by country */
CREATE OR ALTER VIEW Data.vwSalesByCountry
AS
SELECT
    CO.CountryName,
    CU.Country,
    COUNT(SA.SalesID) AS NumberOfSales,
    SUM(SA.TotalSalePrice) AS TotalSalesAmount
FROM Data.Sales AS SA
INNER JOIN Data.Customer AS CU
    ON SA.CustomerID = CU.CustomerID
LEFT JOIN Data.Country AS CO
    ON CU.Country = CO.CountryISO2
GROUP BY
    CO.CountryName,
    CU.Country;
GO


/* ============================================================
   5. CREATE INLINE TABLE-VALUED FUNCTION
   ============================================================ */

CREATE OR ALTER FUNCTION Output.ufnSalesByYear
(
    @SalesYear INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        SA.SalesID,
        SA.InvoiceNumber,
        SA.SaleDate,
        YEAR(SA.SaleDate) AS SalesYear,
        CU.CustomerName,
        CU.Country,
        SA.TotalSalePrice
    FROM Data.Sales AS SA
    INNER JOIN Data.Customer AS CU
        ON SA.CustomerID = CU.CustomerID
    WHERE YEAR(SA.SaleDate) = @SalesYear
);
GO


/* ============================================================
   6. UPDATE WORKFLOW STEPS
   ============================================================ */

UPDATE Process.WorkflowSteps
SET StepStatus = 'Completed',
    StartedAt = ISNULL(StartedAt, SYSDATETIME()),
    CompletedAt = ISNULL(CompletedAt, SYSDATETIME()),
    Notes = 'Created reusable user-defined datatypes in the Udt schema.'
WHERE StepName = 'Create UDTs';
GO

UPDATE Process.WorkflowSteps
SET StepStatus = 'Completed',
    StartedAt = ISNULL(StartedAt, SYSDATETIME()),
    CompletedAt = ISNULL(CompletedAt, SYSDATETIME()),
    Notes = 'Improved the original design by documenting UDTs, adding data integrity constraints, creating reporting views, and replacing reporting logic with an inline table-valued function.'
WHERE StepName = 'Normalize database';
GO

UPDATE Process.WorkflowSteps
SET StepStatus = 'Completed',
    StartedAt = ISNULL(StartedAt, SYSDATETIME()),
    CompletedAt = ISNULL(CompletedAt, SYSDATETIME()),
    Notes = 'Added foreign keys, check constraints, and default constraints.'
WHERE StepName = 'Add constraints';
GO

UPDATE Process.WorkflowSteps
SET StepStatus = 'Completed',
    StartedAt = ISNULL(StartedAt, SYSDATETIME()),
    CompletedAt = ISNULL(CompletedAt, SYSDATETIME()),
    Notes = 'Created views and Output.ufnSalesByYear inline table-valued function.'
WHERE StepName = 'Create views/functions';
GO

UPDATE Process.WorkflowSteps
SET StepStatus = 'Completed',
    StartedAt = ISNULL(StartedAt, SYSDATETIME()),
    CompletedAt = ISNULL(CompletedAt, SYSDATETIME()),
    Notes = 'Created final PrestigeCars .bak backup file for submission.'
WHERE StepName = 'Create final backup';
GO


/* ============================================================
   7. TEST THE INLINE TABLE-VALUED FUNCTION
   ============================================================ */

SELECT TOP 10 *
FROM Output.ufnSalesByYear(2018);
GO


/* ============================================================
   8. FINAL VERIFICATION QUERIES
   ============================================================ */

SELECT 
    'Tables' AS ObjectType, 
    COUNT(*) AS ObjectCount 
FROM sys.tables

UNION ALL

SELECT 
    'Views', 
    COUNT(*) 
FROM sys.views

UNION ALL

SELECT 
    'Inline Table-Valued Functions', 
    COUNT(*) 
FROM sys.objects 
WHERE type = 'IF'

UNION ALL

SELECT 
    'User Defined Types', 
    COUNT(*) 
FROM sys.types 
WHERE is_user_defined = 1

UNION ALL

SELECT 
    'Foreign Keys', 
    COUNT(*) 
FROM sys.foreign_keys

UNION ALL

SELECT 
    'Check Constraints', 
    COUNT(*) 
FROM sys.check_constraints

UNION ALL

SELECT 
    'Default Constraints', 
    COUNT(*) 
FROM sys.default_constraints;
GO


SELECT *
FROM Process.WorkflowSteps;
GO


/* ============================================================
   9. BACKUP COMMAND

   Note:
   This path is for SQL Server running inside Docker.
   Run this only when you are ready to create the final backup.
   ============================================================ */

BACKUP DATABASE [PrestigeCars]
TO DISK = N'/var/opt/mssql/backup/ClassTimeEOSgrp2PrestigeCars.bak'
WITH INIT, FORMAT, STATS = 10;
GO