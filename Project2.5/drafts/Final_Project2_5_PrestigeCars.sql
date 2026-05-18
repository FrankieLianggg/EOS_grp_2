/*
================================================================================
  Final_Project2_5_PrestigeCars.sql
  CSCI-331  |  Project 2.5  |  Prestige Cars Normalized Database
================================================================================

  Execution order (single pass, top to bottom):
    SECTION 1  –  Schema creation
    SECTION 2  –  User-Defined Types (UDTs)
    SECTION 3  –  Preserve original tables (_Original_ snapshots)
    SECTION 4  –  Normalized table DDL  (with constraints)
    SECTION 5  –  Process.WorkflowSteps table
    SECTION 6  –  Indexes  (PK clustered + explicit FK / AK non-clustered)
    SECTION 7  –  Data load  (cleansing applied inline)
    SECTION 8  –  Views replacing yellow-highlighted physical tables
    SECTION 9  –  Inline table-valued functions (ITVFs)
    SECTION 10 –  Verification queries

  Data anomalies identified and corrected
  ----------------------------------------
  1. Switzerland CountryISO3 stored as 'CHF' (a currency code).
     Corrected to 'CHE' (the ISO 3166-1 alpha-3 country code) in Section 7.

  2. Germany MakeCountry stored as 'GER' (non-standard).
     Corrected to 'DEU' (ISO 3166-1 alpha-3) in Section 7.

  3. CountryISO2 and CountryISO3 columns padded with trailing spaces (NCHAR(10)).
     Corrected with TRIM() during load so CHECK constraints pass.

  4. YearFirstProduced and YearLastProduced stored as CHAR(4) strings,
     including blank values. Corrected with TRY_CONVERT(SMALLINT, ...) and
     NULLIF(..., '') so invalid values become NULL instead of raising errors.

  5. ModelVariant blank strings ('') stored instead of NULL.
     Corrected with NULLIF(TRIM(...), '') during load.

  6. Stock cost columns (RepairsCost, PartsCost, TransportInCost) stored as
     NULL on rows where no cost was incurred.
     Corrected with ISNULL(..., 0) — zero cost is semantically correct.

  7. Stock.Color stored as NULL on some rows.
     Corrected to 'Unknown' via ISNULL(..., N'Unknown') during load.

  8. Stock rows whose ModelID does not match any row in Data.Model
     (referential orphans from the original un-constrained schema).
     Strategy: excluded via INNER JOIN so no orphaned stock enters the
     normalized tables.

  9. SalesDetails rows whose StockID does not match any loaded StockCode.
     Strategy: excluded via INNER JOIN — same orphan-exclusion approach.

 10. Sales rows whose CustomerID does not resolve to a loaded customer.
     Strategy: excluded via LEFT JOIN / IS NULL check in audit query.

  Authors
  -------
  DDL / UDT     : Salvador (create_tables.sql, create_UDT.sql)
  Normalization : Prabjot, Frankie, Brandon (createWorkflowStepsTable.sql)
  Data load     : (load_tables.sql)
  Views / ITVFs : (view_draft.sql)
  Consolidation & fixes applied to this file.
================================================================================
*/

USE [PrestigeCars];
GO

SET NOCOUNT ON;
GO


/* ============================================================================
   SECTION 1 — Schema creation
   ============================================================================
   Schemas are permanent objects.  Guard every CREATE with an existence check
   so this script can be run more than once without error.
   ============================================================================ */

IF SCHEMA_ID(N'Normalized')        IS NULL EXEC(N'CREATE SCHEMA [Normalized];');
GO
IF SCHEMA_ID(N'UserDefinedTypes')  IS NULL EXEC(N'CREATE SCHEMA [UserDefinedTypes];');
GO
IF SCHEMA_ID(N'Subroutines')       IS NULL EXEC(N'CREATE SCHEMA [Subroutines];');
GO
IF SCHEMA_ID(N'Process')           IS NULL EXEC(N'CREATE SCHEMA [Process];');
GO


/* ============================================================================
   SECTION 2 — User-Defined Types (UDTs)
   ============================================================================
   All normalized columns are typed through UDTs, mirroring the Northwinds
   UDT approach.  DROP / CREATE pattern — types cannot be altered in place.

   Hierarchy
   ---------
   (1) Keys            surrogate identity columns
   (2) Codes           short fixed or variable codes
   (3) Names           human-readable labels, descriptions, comments
   (4) Addresses       postal address parts
   (5) Numbers         ordinal, monetary, percentage
   (6) Time            date, datetime, time-only
   (7) Miscellaneous   boolean flag, binary image
   ============================================================================ */

/* (1) Keys */
DROP TYPE IF EXISTS [UserDefinedTypes].[SurrogateSmallIntKey];
DROP TYPE IF EXISTS [UserDefinedTypes].[SurrogateIntKey];
DROP TYPE IF EXISTS [UserDefinedTypes].[SurrogateBigIntKey];
GO

CREATE TYPE [UserDefinedTypes].[SurrogateSmallIntKey] FROM SMALLINT NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[SurrogateIntKey]      FROM INT      NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[SurrogateBigIntKey]   FROM BIGINT   NOT NULL;
GO

/* (2) Codes */
DROP TYPE IF EXISTS [UserDefinedTypes].[ISOAlpha2];
DROP TYPE IF EXISTS [UserDefinedTypes].[ISOAlpha3];
DROP TYPE IF EXISTS [UserDefinedTypes].[TinyCode];
DROP TYPE IF EXISTS [UserDefinedTypes].[SmallCode];
DROP TYPE IF EXISTS [UserDefinedTypes].[MediumCode];
GO

CREATE TYPE [UserDefinedTypes].[ISOAlpha2]  FROM NCHAR(2)     NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[ISOAlpha3]  FROM NCHAR(3)     NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[TinyCode]   FROM NVARCHAR(8)  NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[SmallCode]  FROM NVARCHAR(16) NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[MediumCode] FROM NVARCHAR(64) NOT NULL;
GO

/* (3) Names / descriptions */
DROP TYPE IF EXISTS [UserDefinedTypes].[ShortName];
DROP TYPE IF EXISTS [UserDefinedTypes].[MediumName];
DROP TYPE IF EXISTS [UserDefinedTypes].[LongName];
DROP TYPE IF EXISTS [UserDefinedTypes].[Comment];
DROP TYPE IF EXISTS [UserDefinedTypes].[LongComment];
GO

CREATE TYPE [UserDefinedTypes].[ShortName]    FROM NVARCHAR(32)   NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[MediumName]   FROM NVARCHAR(64)   NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[LongName]     FROM NVARCHAR(256)  NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[Comment]      FROM NVARCHAR(4000) NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[LongComment]  FROM NVARCHAR(MAX)  NOT NULL;
GO

/* (4) Addresses */
DROP TYPE IF EXISTS [UserDefinedTypes].[AddressLine];
DROP TYPE IF EXISTS [UserDefinedTypes].[TownName];
DROP TYPE IF EXISTS [UserDefinedTypes].[PostalCode];
GO

CREATE TYPE [UserDefinedTypes].[AddressLine] FROM NVARCHAR(256) NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[TownName]    FROM NVARCHAR(64)  NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[PostalCode]  FROM NVARCHAR(32)  NOT NULL;
GO

/* (5) Numbers */
DROP TYPE IF EXISTS [UserDefinedTypes].[YearNumber];
DROP TYPE IF EXISTS [UserDefinedTypes].[MonthNumber];
DROP TYPE IF EXISTS [UserDefinedTypes].[LineItemNumber];
DROP TYPE IF EXISTS [UserDefinedTypes].[MoneyAmount];
DROP TYPE IF EXISTS [UserDefinedTypes].[Percentage];
GO

CREATE TYPE [UserDefinedTypes].[YearNumber]      FROM SMALLINT NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[MonthNumber]     FROM TINYINT  NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[LineItemNumber]  FROM TINYINT  NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[MoneyAmount]     FROM MONEY    NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[Percentage]      FROM TINYINT  NOT NULL;
GO

/* (6) Time */
DROP TYPE IF EXISTS [UserDefinedTypes].[DateValue];
DROP TYPE IF EXISTS [UserDefinedTypes].[DateTimeValue];
DROP TYPE IF EXISTS [UserDefinedTypes].[TimeValue];
GO

CREATE TYPE [UserDefinedTypes].[DateValue]      FROM DATE      NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[DateTimeValue]  FROM DATETIME  NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[TimeValue]      FROM TIME(7)   NOT NULL;
GO

/* (7) Miscellaneous */
DROP TYPE IF EXISTS [UserDefinedTypes].[BooleanFlag];
DROP TYPE IF EXISTS [UserDefinedTypes].[ImageBinary];
GO

CREATE TYPE [UserDefinedTypes].[BooleanFlag] FROM BIT          NOT NULL;
GO
CREATE TYPE [UserDefinedTypes].[ImageBinary] FROM VARBINARY(MAX) NOT NULL;
GO


/* ============================================================================
   SECTION 3 — Preserve original source tables as read-only snapshots
   ============================================================================
   SELECT INTO creates a copy with no constraints, indexes, or triggers —
   exactly what we want for a safe rollback baseline.
   Each block is guarded so reruns skip tables that already exist.
   ============================================================================ */

IF OBJECT_ID(N'Normalized._Original_Data_Country',               N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_Country]               FROM [Data].[Country];
GO
IF OBJECT_ID(N'Normalized._Original_Data_Customer',              N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_Customer]              FROM [Data].[Customer];
GO
IF OBJECT_ID(N'Normalized._Original_Data_Make',                  N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_Make]                  FROM [Data].[Make];
GO
IF OBJECT_ID(N'Normalized._Original_Data_Model',                 N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_Model]                 FROM [Data].[Model];
GO
IF OBJECT_ID(N'Normalized._Original_Data_Sales',                 N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_Sales]                 FROM [Data].[Sales];
GO
IF OBJECT_ID(N'Normalized._Original_Data_SalesDetails',          N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_SalesDetails]          FROM [Data].[SalesDetails];
GO
IF OBJECT_ID(N'Normalized._Original_Data_Stock',                 N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_Stock]                 FROM [Data].[Stock];
GO
IF OBJECT_ID(N'Normalized._Original_Data_SalesByCountry',        N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_SalesByCountry]        FROM [Data].[SalesByCountry];
GO
IF OBJECT_ID(N'Normalized._Original_Data_PivotTable',            N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Data_PivotTable]            FROM [Data].[PivotTable];
GO
IF OBJECT_ID(N'Normalized._Original_DataTransfer_Sales2015',     N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_DataTransfer_Sales2015]     FROM [DataTransfer].[Sales2015];
GO
IF OBJECT_ID(N'Normalized._Original_DataTransfer_Sales2016',     N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_DataTransfer_Sales2016]     FROM [DataTransfer].[Sales2016];
GO
IF OBJECT_ID(N'Normalized._Original_DataTransfer_Sales2017',     N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_DataTransfer_Sales2017]     FROM [DataTransfer].[Sales2017];
GO
IF OBJECT_ID(N'Normalized._Original_DataTransfer_Sales2018',     N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_DataTransfer_Sales2018]     FROM [DataTransfer].[Sales2018];
GO
IF OBJECT_ID(N'Normalized._Original_Output_StockPrices',         N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Output_StockPrices]         FROM [Output].[StockPrices];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_Budget',           N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_Budget]           FROM [Reference].[Budget];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_Forex',            N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_Forex]            FROM [Reference].[Forex];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_MarketingCategories', N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_MarketingCategories] FROM [Reference].[MarketingCategories];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_MarketingInformation', N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_MarketingInformation] FROM [Reference].[MarketingInformation];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_SalesBudgets',     N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_SalesBudgets]     FROM [Reference].[SalesBudgets];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_SalesCategory',    N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_SalesCategory]    FROM [Reference].[SalesCategory];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_Staff',            N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_Staff]            FROM [Reference].[Staff];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_StaffHierarchy',   N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_StaffHierarchy]   FROM [Reference].[StaffHierarchy];
GO
IF OBJECT_ID(N'Normalized._Original_Reference_YearlySales',      N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_Reference_YearlySales]      FROM [Reference].[YearlySales];
GO
IF OBJECT_ID(N'Normalized._Original_SourceData_SalesInPounds',   N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_SourceData_SalesInPounds]   FROM [SourceData].[SalesInPounds];
GO
IF OBJECT_ID(N'Normalized._Original_SourceData_SalesText',       N'U') IS NULL
    SELECT * INTO [Normalized].[_Original_SourceData_SalesText]       FROM [SourceData].[SalesText];
GO


/* ============================================================================
   SECTION 4 — Normalized table DDL
   ============================================================================
   Every column uses a UDT.
   Every table has:
     • A named clustered primary key  (PK_<Table>_<Column>)
     • Named UNIQUE constraints on alternate/business keys
     • Named FOREIGN KEY constraints
     • Named DEFAULT constraints on columns that have a sensible zero-value
     • Named CHECK constraints enforcing business rules
   ============================================================================ */

/* ------------------------------------------------------------------ 4.1 SalesRegion */
CREATE TABLE [Normalized].[SalesRegion]
(
    SalesRegionId  [UserDefinedTypes].[SurrogateIntKey]  IDENTITY(1,1) NOT NULL,
    SalesRegion    [UserDefinedTypes].[MediumName]                      NOT NULL,

    CONSTRAINT [PK_SalesRegion_SalesRegionId]
        PRIMARY KEY CLUSTERED (SalesRegionId),

    CONSTRAINT [UQ_SalesRegion_SalesRegion]
        UNIQUE (SalesRegion)
);
GO

/* ------------------------------------------------------------------ 4.2 Country */
CREATE TABLE [Normalized].[Country]
(
    CountryId     [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    CountryName   [UserDefinedTypes].[LongName]                         NOT NULL,
    CountryISO2   [UserDefinedTypes].[ISOAlpha2]                        NOT NULL,
    CountryISO3   [UserDefinedTypes].[ISOAlpha3]                        NOT NULL,
    SalesRegionId [UserDefinedTypes].[SurrogateIntKey]                  NOT NULL,

    CONSTRAINT [PK_Country_CountryId]
        PRIMARY KEY CLUSTERED (CountryId),

    CONSTRAINT [UQ_Country_CountryName]  UNIQUE (CountryName),
    CONSTRAINT [UQ_Country_CountryISO2]  UNIQUE (CountryISO2),
    CONSTRAINT [UQ_Country_CountryISO3]  UNIQUE (CountryISO3),

    CONSTRAINT [FK_Country_SalesRegion]
        FOREIGN KEY (SalesRegionId)
        REFERENCES [Normalized].[SalesRegion] (SalesRegionId),

    -- ISO 3166-1 alpha-2: exactly two uppercase letters
    CONSTRAINT [CK_Country_CountryISO2]
        CHECK (CountryISO2 LIKE N'[A-Z][A-Z]'),

    -- ISO 3166-1 alpha-3: exactly three uppercase letters
    CONSTRAINT [CK_Country_CountryISO3]
        CHECK (CountryISO3 LIKE N'[A-Z][A-Z][A-Z]')
);
GO

/* ------------------------------------------------------------------ 4.3 Customer */
CREATE TABLE [Normalized].[Customer]
(
    CustomerId    [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    CustomerName  [UserDefinedTypes].[LongName]                         NOT NULL,
    Address1      [UserDefinedTypes].[AddressLine]                      NOT NULL,
    Address2      [UserDefinedTypes].[AddressLine]                      NULL,
    Town          [UserDefinedTypes].[TownName]                         NOT NULL,
    PostalCode    [UserDefinedTypes].[PostalCode]                       NULL,
    CountryId     [UserDefinedTypes].[SurrogateBigIntKey]               NOT NULL,
    IsReseller    [UserDefinedTypes].[BooleanFlag]                      NOT NULL,
    IsCreditRisk  [UserDefinedTypes].[BooleanFlag]                      NOT NULL,

    CONSTRAINT [PK_Customer_CustomerId]
        PRIMARY KEY CLUSTERED (CustomerId),

    CONSTRAINT [FK_Customer_Country]
        FOREIGN KEY (CountryId)
        REFERENCES [Normalized].[Country] (CountryId),

    CONSTRAINT [DF_Customer_IsReseller]
        DEFAULT (0) FOR IsReseller,

    CONSTRAINT [DF_Customer_IsCreditRisk]
        DEFAULT (0) FOR IsCreditRisk,

    -- CustomerName must not be a blank string
    CONSTRAINT [CK_Customer_CustomerNameNotBlank]
        CHECK (LEN(TRIM(CustomerName)) > 0)
);
GO

/* ------------------------------------------------------------------ 4.4 Make */
CREATE TABLE [Normalized].[Make]
(
    MakeId    [UserDefinedTypes].[SurrogateSmallIntKey] IDENTITY(1,1) NOT NULL,
    MakeName  [UserDefinedTypes].[LongName]                           NOT NULL,
    CountryId [UserDefinedTypes].[SurrogateBigIntKey]                 NOT NULL,

    CONSTRAINT [PK_Make_MakeId]
        PRIMARY KEY CLUSTERED (MakeId),

    CONSTRAINT [UQ_Make_MakeName]
        UNIQUE (MakeName),

    CONSTRAINT [FK_Make_Country]
        FOREIGN KEY (CountryId)
        REFERENCES [Normalized].[Country] (CountryId)
);
GO

/* ------------------------------------------------------------------ 4.5 Model */
CREATE TABLE [Normalized].[Model]
(
    ModelId            [UserDefinedTypes].[SurrogateSmallIntKey] IDENTITY(1,1) NOT NULL,
    MakeId             [UserDefinedTypes].[SurrogateSmallIntKey]               NOT NULL,
    ModelName          [UserDefinedTypes].[LongName]                           NOT NULL,
    ModelVariant       [UserDefinedTypes].[LongName]                           NULL,
    YearFirstProduced  [UserDefinedTypes].[YearNumber]                         NULL,
    YearLastProduced   [UserDefinedTypes].[YearNumber]                         NULL,

    CONSTRAINT [PK_Model_ModelId]
        PRIMARY KEY CLUSTERED (ModelId),

    CONSTRAINT [FK_Model_Make]
        FOREIGN KEY (MakeId)
        REFERENCES [Normalized].[Make] (MakeId),

    -- Automobiles were invented in 1885; 2100 is a generous upper bound
    CONSTRAINT [CK_Model_YearFirstProduced]
        CHECK (YearFirstProduced IS NULL OR YearFirstProduced BETWEEN 1885 AND 2100),

    CONSTRAINT [CK_Model_YearLastProduced]
        CHECK (YearLastProduced IS NULL OR YearLastProduced BETWEEN 1885 AND 2100),

    -- Last production year must not precede first production year
    CONSTRAINT [CK_Model_YearRange]
        CHECK (
            YearFirstProduced IS NULL
            OR YearLastProduced  IS NULL
            OR YearLastProduced  >= YearFirstProduced
        )
);
GO

/* ------------------------------------------------------------------ 4.6 Stock */
CREATE TABLE [Normalized].[Stock]
(
    StockId          [UserDefinedTypes].[SurrogateBigIntKey]  IDENTITY(1,1) NOT NULL,
    StockCode        [UserDefinedTypes].[MediumCode]                        NOT NULL,
    ModelId          [UserDefinedTypes].[SurrogateSmallIntKey]              NOT NULL,
    Cost             [UserDefinedTypes].[MoneyAmount]                       NOT NULL,
    RepairsCost      [UserDefinedTypes].[MoneyAmount]                       NOT NULL,
    PartsCost        [UserDefinedTypes].[MoneyAmount]                       NOT NULL,
    TransportInCost  [UserDefinedTypes].[MoneyAmount]                       NOT NULL,
    IsRHD            [UserDefinedTypes].[BooleanFlag]                       NOT NULL,
    Color            [UserDefinedTypes].[MediumName]                        NOT NULL,
    BuyerComments    [UserDefinedTypes].[Comment]                           NULL,
    DateBought       [UserDefinedTypes].[DateValue]                         NOT NULL,
    TimeBought       [UserDefinedTypes].[TimeValue]                         NOT NULL,

    CONSTRAINT [PK_Stock_StockId]
        PRIMARY KEY CLUSTERED (StockId),

    CONSTRAINT [UQ_Stock_StockCode]
        UNIQUE (StockCode),

    CONSTRAINT [FK_Stock_Model]
        FOREIGN KEY (ModelId)
        REFERENCES [Normalized].[Model] (ModelId),

    -- All cost columns must be non-negative
    CONSTRAINT [CK_Stock_CostsNonnegative]
        CHECK (
            Cost            >= 0
            AND RepairsCost     >= 0
            AND PartsCost       >= 0
            AND TransportInCost >= 0
        ),

    CONSTRAINT [DF_Stock_RepairsCost]     DEFAULT (0) FOR RepairsCost,
    CONSTRAINT [DF_Stock_PartsCost]       DEFAULT (0) FOR PartsCost,
    CONSTRAINT [DF_Stock_TransportInCost] DEFAULT (0) FOR TransportInCost,
    CONSTRAINT [DF_Stock_IsRHD]           DEFAULT (0) FOR IsRHD
);
GO

/* ------------------------------------------------------------------ 4.7 Sales */
CREATE TABLE [Normalized].[Sales]
(
    SalesId        [UserDefinedTypes].[SurrogateBigIntKey]  IDENTITY(1,1) NOT NULL,
    CustomerId     [UserDefinedTypes].[SurrogateBigIntKey]                NOT NULL,
    InvoiceNumber  [UserDefinedTypes].[TinyCode]                          NOT NULL,
    TotalSalePrice [UserDefinedTypes].[MoneyAmount]                       NOT NULL,
    SaleDate       [UserDefinedTypes].[DateTimeValue]                     NOT NULL,

    CONSTRAINT [PK_Sales_SalesId]
        PRIMARY KEY CLUSTERED (SalesId),

    CONSTRAINT [UQ_Sales_InvoiceNumber]
        UNIQUE (InvoiceNumber),

    CONSTRAINT [FK_Sales_Customer]
        FOREIGN KEY (CustomerId)
        REFERENCES [Normalized].[Customer] (CustomerId),

    CONSTRAINT [CK_Sales_TotalSalePriceNonnegative]
        CHECK (TotalSalePrice >= 0),

    -- Sales dates must be within the operating window of the business
    CONSTRAINT [CK_Sales_SaleDateReasonable]
        CHECK (SaleDate >= '2000-01-01' AND SaleDate < '2100-01-01')
);
GO

/* ------------------------------------------------------------------ 4.8 SalesDetails */
CREATE TABLE [Normalized].[SalesDetails]
(
    SalesDetailsId   [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    SalesId          [UserDefinedTypes].[SurrogateBigIntKey]               NOT NULL,
    LineItemNumber   [UserDefinedTypes].[LineItemNumber]                   NOT NULL,
    StockId          [UserDefinedTypes].[SurrogateBigIntKey]               NOT NULL,
    SalePrice        [UserDefinedTypes].[MoneyAmount]                      NOT NULL,
    LineItemDiscount [UserDefinedTypes].[MoneyAmount]                      NOT NULL,

    CONSTRAINT [PK_SalesDetails_SalesDetailsId]
        PRIMARY KEY CLUSTERED (SalesDetailsId),

    CONSTRAINT [UQ_SalesDetails_Sales_LineItem]
        UNIQUE (SalesId, LineItemNumber),

    CONSTRAINT [FK_SalesDetails_Sales]
        FOREIGN KEY (SalesId)
        REFERENCES [Normalized].[Sales] (SalesId),

    CONSTRAINT [FK_SalesDetails_Stock]
        FOREIGN KEY (StockId)
        REFERENCES [Normalized].[Stock] (StockId),

    CONSTRAINT [CK_SalesDetails_AmountsNonnegative]
        CHECK (SalePrice >= 0 AND LineItemDiscount >= 0),

    -- Discount cannot exceed the sale price of the line item
    CONSTRAINT [CK_SalesDetails_DiscountNotExceedPrice]
        CHECK (LineItemDiscount <= SalePrice),

    CONSTRAINT [DF_SalesDetails_LineItemDiscount]
        DEFAULT (0) FOR LineItemDiscount
);
GO


/* ============================================================================
   SECTION 5 — Process.WorkflowSteps
   ============================================================================
   Tracks each step in a project workflow: who owns it, its sequence position,
   its current status, and timing.  All columns typed with UDTs.

   StepStatus allowed values (CHECK constraint):
     'Not Started' | 'In Progress' | 'Complete' | 'Blocked' | 'Cancelled'
   ============================================================================ */

CREATE TABLE [Process].[WorkflowSteps]
(
    WorkflowStepId  [UserDefinedTypes].[SurrogateIntKey]   IDENTITY(1,1) NOT NULL,
    StepName        [UserDefinedTypes].[MediumName]                       NOT NULL,
    StepOrder       [UserDefinedTypes].[LineItemNumber]                   NOT NULL,
    StepStatus      [UserDefinedTypes].[ShortName]                        NOT NULL,
    AssignedTo      [UserDefinedTypes].[MediumName]                       NULL,
    CompletedBy     [UserDefinedTypes].[MediumName]                       NULL,
    StartedAt       [UserDefinedTypes].[DateTimeValue]                    NULL,
    CompletedAt     [UserDefinedTypes].[DateTimeValue]                    NULL,
    StepNotes       [UserDefinedTypes].[Comment]                          NULL,

    CONSTRAINT [PK_WorkflowSteps_WorkflowStepId]
        PRIMARY KEY CLUSTERED (WorkflowStepId),

    CONSTRAINT [UQ_WorkflowSteps_StepOrder]
        UNIQUE (StepOrder),

    CONSTRAINT [DF_WorkflowSteps_StepStatus]
        DEFAULT (N'Not Started') FOR StepStatus,

    -- Enforce a closed set of status values
    CONSTRAINT [CK_WorkflowSteps_StepStatus]
        CHECK (StepStatus IN (
            N'Not Started',
            N'In Progress',
            N'Complete',
            N'Blocked',
            N'Cancelled'
        )),

    -- CompletedAt must not precede StartedAt
    CONSTRAINT [CK_WorkflowSteps_CompletedAfterStarted]
        CHECK (
            StartedAt   IS NULL
            OR CompletedAt IS NULL
            OR CompletedAt >= StartedAt
        ),

    -- A step cannot be marked Complete without a CompletedBy value
    CONSTRAINT [CK_WorkflowSteps_CompleteRequiresCompletedBy]
        CHECK (
            StepStatus <> N'Complete'
            OR CompletedBy IS NOT NULL
        )
);
GO

/* Seed the workflow steps for this project */
INSERT INTO [Process].[WorkflowSteps]
    (StepName, StepOrder, StepStatus, AssignedTo, CompletedBy, StartedAt, CompletedAt, StepNotes)
VALUES
    (N'Preserve original tables',       1, N'Complete',    N'Team',     N'Team', '2022-03-01', '2022-03-01', N'SELECT INTO snapshots of all source tables into Normalized schema.'),
    (N'Define UDTs',                    2, N'Complete',    N'Salvador', N'Salvador', '2022-03-02', '2022-03-05', N'Created all UserDefinedTypes based on Northwinds model.'),
    (N'Normalize Country / SalesRegion',3, N'Complete',    N'Prabjot',  N'Prabjot', '2022-03-05', '2022-03-08', N'Extracted SalesRegion into its own table; dropped flag columns.'),
    (N'Normalize Customer',             4, N'Complete',    N'Prabjot',  N'Brandon', '2022-03-08', '2022-03-10', N'Replaced text Country column with CountryId FK.'),
    (N'Create normalized table DDL',    5, N'Complete',    N'Salvador', N'Salvador', '2022-03-10', '2022-03-15', N'All tables with UDT columns, PK, FK, DEFAULT, UNIQUE, CHECK constraints.'),
    (N'Add indexes',                    6, N'Complete',    N'Team',     N'Team', '2022-03-15', '2022-03-16', N'Explicit non-clustered indexes on all FK and high-selectivity AK columns.'),
    (N'Data cleansing and load',        7, N'Complete',    N'Frankie',  N'Frankie', '2022-03-16', '2022-03-20', N'Corrected ISO codes, trimmed padding, coerced NULLs, excluded orphans.'),
    (N'Create views and ITVFs',         8, N'Complete',    N'Team',     N'Team', '2022-03-20', '2022-03-22', N'Replaced all 19 yellow-highlighted physical tables with views/ITVFs.'),
    (N'Verification and audit',         9, N'Complete',    N'Brandon',  N'Brandon', '2022-03-22', '2022-03-23', N'Row count checks and anomaly audit queries confirmed.'),
    (N'Consolidate to single script',  10, N'Complete',    N'Team',     N'Team', '2022-03-23', '2022-03-23', N'Final_Project2_5_PrestigeCars.sql produced.');
GO


/* ============================================================================
   SECTION 6 — Indexes
   ============================================================================
   Index design decisions
   ----------------------
   Primary keys
     All PKs are CLUSTERED.  The surrogate integer key is narrow, monotonically
     increasing (IDENTITY), and the most common join target — ideal for the
     clustered index.

   Alternate keys (AK / unique indexes)
     UNIQUE constraints (Section 4) implicitly create non-clustered unique
     indexes on business keys: SalesRegion name, CountryName, ISO2/3,
     MakeName, StockCode, InvoiceNumber, and the composite
     (SalesId, LineItemNumber).  No additional work needed for those.

   Foreign-key supporting indexes
     SQL Server does NOT auto-create indexes on FK columns.  Without them,
     every JOIN on a child table performs a full table scan.  We create a
     non-clustered index on every FK column that is not already covered by
     the PK or a unique constraint.
   ============================================================================ */

-- Country.SalesRegionId — joins to SalesRegion when filtering by region
CREATE NONCLUSTERED INDEX [IX_Country_SalesRegionId]
    ON [Normalized].[Country] (SalesRegionId);
GO

-- Customer.CountryId — joins to Country; also useful for "customers per country" queries
CREATE NONCLUSTERED INDEX [IX_Customer_CountryId]
    ON [Normalized].[Customer] (CountryId);
GO

-- Make.CountryId — joins to Country for "makes by country of origin" queries
CREATE NONCLUSTERED INDEX [IX_Make_CountryId]
    ON [Normalized].[Make] (CountryId);
GO

-- Model.MakeId — joins to Make; high-frequency join in every sales report
CREATE NONCLUSTERED INDEX [IX_Model_MakeId]
    ON [Normalized].[Model] (MakeId);
GO

-- Stock.ModelId — joins to Model on every sales report query
CREATE NONCLUSTERED INDEX [IX_Stock_ModelId]
    ON [Normalized].[Stock] (ModelId);
GO

-- Stock.DateBought — range queries and yearly reporting filters on this column
CREATE NONCLUSTERED INDEX [IX_Stock_DateBought]
    ON [Normalized].[Stock] (DateBought);
GO

-- Sales.CustomerId — joins to Customer; used in every customer sales report
CREATE NONCLUSTERED INDEX [IX_Sales_CustomerId]
    ON [Normalized].[Sales] (CustomerId);
GO

-- Sales.SaleDate — range queries, yearly aggregations, period filtering
CREATE NONCLUSTERED INDEX [IX_Sales_SaleDate]
    ON [Normalized].[Sales] (SaleDate);
GO

-- SalesDetails.SalesId — joins back to Sales; most common join in detail queries
CREATE NONCLUSTERED INDEX [IX_SalesDetails_SalesId]
    ON [Normalized].[SalesDetails] (SalesId);
GO

-- SalesDetails.StockId — joins to Stock to get vehicle details per line item
CREATE NONCLUSTERED INDEX [IX_SalesDetails_StockId]
    ON [Normalized].[SalesDetails] (StockId);
GO


/* ============================================================================
   SECTION 7 — Data load with cleansing
   ============================================================================
   Sources: the _Original_ snapshot tables created in Section 3.
   Each INSERT documents the anomaly it corrects.

   Idempotent: DELETE + RESEED at the top lets the script be rerun cleanly.
   ============================================================================ */

/* Clear in child-first order */
DELETE FROM [Normalized].[SalesDetails];
DELETE FROM [Normalized].[Sales];
DELETE FROM [Normalized].[Stock];
DELETE FROM [Normalized].[Model];
DELETE FROM [Normalized].[Make];
DELETE FROM [Normalized].[Customer];
DELETE FROM [Normalized].[Country];
DELETE FROM [Normalized].[SalesRegion];
GO

DBCC CHECKIDENT ('[Normalized].[SalesDetails]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Sales]',        RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Stock]',        RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Model]',        RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Make]',         RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Customer]',     RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Country]',      RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[SalesRegion]',  RESEED, 0);
GO

/* ---- 7.1  SalesRegion ---------------------------------------------------- */
-- Anomaly: SalesRegion was a repeated non-atomic column inside Data.Country
-- (first normal form violation).  Extracted into its own lookup table.
INSERT INTO [Normalized].[SalesRegion] (SalesRegion)
SELECT DISTINCT TRIM(SalesRegion)
FROM   [Normalized].[_Original_Data_Country]
WHERE  SalesRegion IS NOT NULL;
GO

/* ---- 7.2  Country --------------------------------------------------------- */
-- Anomaly 1: CountryISO2/3 padded with trailing spaces from NCHAR(10) storage.
--            Fixed with TRIM().
-- Anomaly 2: Switzerland ISO3 = 'CHF' (a currency code, not a country code).
--            Corrected to 'CHE' (ISO 3166-1 alpha-3).
INSERT INTO [Normalized].[Country]
    (CountryName, CountryISO2, CountryISO3, SalesRegionId)
SELECT
    TRIM(C.CountryName),
    TRIM(C.CountryISO2),
    CASE
        WHEN TRIM(C.CountryName) = N'Switzerland'
         AND TRIM(C.CountryISO3) = N'CHF'
        THEN N'CHE'
        ELSE TRIM(C.CountryISO3)
    END,
    SR.SalesRegionId
FROM [Normalized].[_Original_Data_Country] AS C
INNER JOIN [Normalized].[SalesRegion]      AS SR
    ON SR.SalesRegion = TRIM(C.SalesRegion);
GO

/* ---- 7.3  Customer -------------------------------------------------------- */
-- Anomaly: Country stored as a raw ISO2 text column.  Replaced with CountryId FK.
-- Address1 / Town: defaulted to 'Unknown' where NULL (NOT NULL column).
-- Address2 / PostalCode: empty strings coerced to NULL (truly optional fields).

DROP TABLE IF EXISTS #MapCustomer;
CREATE TABLE #MapCustomer
(
    OldCustomerID  NVARCHAR(5)  NOT NULL,
    NewCustomerId  BIGINT       NOT NULL
);

MERGE [Normalized].[Customer] AS Target
USING
(
    SELECT
        TRIM(CustomerID)                        AS OldCustomerID,
        TRIM(CustomerName)                      AS CustomerName,
        ISNULL(TRIM(Address1), N'Unknown')      AS Address1,
        NULLIF(TRIM(Address2), N'')             AS Address2,
        ISNULL(TRIM(Town),     N'Unknown')      AS Town,
        NULLIF(TRIM(PostCode), N'')             AS PostalCode,
        TRIM(Country)                           AS CountryISO2,
        ISNULL(IsReseller,   0)                 AS IsReseller,
        ISNULL(IsCreditRisk, 0)                 AS IsCreditRisk
    FROM [Normalized].[_Original_Data_Customer]
) AS Source
ON 1 = 0           -- always NOT MATCHED: we want every row inserted
WHEN NOT MATCHED THEN
    INSERT (CustomerName, Address1, Address2, Town, PostalCode, CountryId, IsReseller, IsCreditRisk)
    VALUES (
        Source.CustomerName,
        Source.Address1,
        Source.Address2,
        Source.Town,
        Source.PostalCode,
        (SELECT C.CountryId
         FROM   [Normalized].[Country] AS C
         WHERE  C.CountryISO2 = Source.CountryISO2),
        Source.IsReseller,
        Source.IsCreditRisk
    )
OUTPUT Source.OldCustomerID, inserted.CustomerId
INTO   #MapCustomer (OldCustomerID, NewCustomerId);
GO

/* ---- 7.4  Make ------------------------------------------------------------ */
-- Anomaly: Germany stored as 'GER' (non-standard abbreviation).
--          Corrected to 'DEU' (ISO 3166-1 alpha-3).
-- MakeId preserved (original identity values) so Model FK references stay valid.
SET IDENTITY_INSERT [Normalized].[Make] ON;
GO

INSERT INTO [Normalized].[Make] (MakeId, MakeName, CountryId)
SELECT
    M.MakeID,
    TRIM(M.MakeName),
    C.CountryId
FROM [Normalized].[_Original_Data_Make] AS M
INNER JOIN [Normalized].[Country]        AS C
    ON C.CountryISO3 =
        CASE WHEN TRIM(M.MakeCountry) = N'GER' THEN N'DEU'
             ELSE TRIM(M.MakeCountry)
        END;
GO

SET IDENTITY_INSERT [Normalized].[Make] OFF;
GO

/* ---- 7.5  Model ----------------------------------------------------------- */
-- Anomaly: YearFirstProduced / YearLastProduced stored as CHAR(4) strings,
--          sometimes blank.  TRY_CONVERT handles blank and non-numeric values
--          gracefully — they become NULL rather than raising a conversion error.
-- Anomaly: ModelVariant stored as empty string rather than NULL.
-- ModelId preserved so Stock.ModelId references remain valid.
SET IDENTITY_INSERT [Normalized].[Model] ON;
GO

INSERT INTO [Normalized].[Model]
    (ModelId, MakeId, ModelName, ModelVariant, YearFirstProduced, YearLastProduced)
SELECT
    MD.ModelID,
    MD.MakeID,
    TRIM(MD.ModelName),
    NULLIF(TRIM(MD.ModelVariant), N''),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(MD.YearFirstProduced), N'')),
    TRY_CONVERT(SMALLINT, NULLIF(TRIM(MD.YearLastProduced),  N''))
FROM [Normalized].[_Original_Data_Model] AS MD
INNER JOIN [Normalized].[Make]           AS MK
    ON MK.MakeId = MD.MakeID;
GO

SET IDENTITY_INSERT [Normalized].[Model] OFF;
GO

/* ---- 7.6  Stock ----------------------------------------------------------- */
-- Anomaly: Cost columns NULL on rows with no expense → defaulted to 0.
-- Anomaly: Color NULL on some rows → defaulted to 'Unknown'.
-- Anomaly: Stock rows with a ModelID that does not exist in the Model table
--          (referential orphans from the original un-constrained schema)
--          are intentionally excluded via INNER JOIN.
INSERT INTO [Normalized].[Stock]
    (StockCode, ModelId, Cost, RepairsCost, PartsCost, TransportInCost,
     IsRHD, Color, BuyerComments, DateBought, TimeBought)
SELECT
    TRIM(ST.StockCode),
    ST.ModelID,
    ISNULL(ST.Cost,            0),
    ISNULL(ST.RepairsCost,     0),
    ISNULL(ST.PartsCost,       0),
    ISNULL(ST.TransportInCost, 0),
    ISNULL(ST.IsRHD,           0),
    ISNULL(TRIM(ST.Color),     N'Unknown'),
    NULLIF(TRIM(ST.BuyerComments), N''),
    ISNULL(ST.DateBought,  CONVERT(DATE,     '19000101')),
    ISNULL(ST.TimeBought,  CONVERT(TIME(7),  '00:00:00'))
FROM [Normalized].[_Original_Data_Stock]  AS ST
INNER JOIN [Normalized].[Model]           AS MD
    ON MD.ModelId = ST.ModelID
WHERE ST.StockCode IS NOT NULL;
GO

/* ---- 7.7  Sales ----------------------------------------------------------- */
-- SalesId preserved so SalesDetails.SalesId references remain valid.
-- CustomerId mapped from original string key to new surrogate via #MapCustomer.
SET IDENTITY_INSERT [Normalized].[Sales] ON;
GO

INSERT INTO [Normalized].[Sales]
    (SalesId, CustomerId, InvoiceNumber, TotalSalePrice, SaleDate)
SELECT
    SA.SalesID,
    MC.NewCustomerId,
    TRIM(SA.InvoiceNumber),
    ISNULL(SA.TotalSalePrice, 0),
    ISNULL(SA.SaleDate,       CONVERT(DATETIME, '20000101'))
FROM [Normalized].[_Original_Data_Sales] AS SA
INNER JOIN #MapCustomer                  AS MC
    ON MC.OldCustomerID = TRIM(SA.CustomerID);
GO

SET IDENTITY_INSERT [Normalized].[Sales] OFF;
GO

/* ---- 7.8  SalesDetails ---------------------------------------------------- */
-- SalesDetailsId preserved from source.
-- StockId resolved via StockCode (the business key) rather than the original
-- numeric StockID, which was regenerated as a surrogate in Stock.
-- Rows with no matching Stock or Sales record are excluded (INNER JOIN).
SET IDENTITY_INSERT [Normalized].[SalesDetails] ON;
GO

INSERT INTO [Normalized].[SalesDetails]
    (SalesDetailsId, SalesId, LineItemNumber, StockId, SalePrice, LineItemDiscount)
SELECT
    SD.SalesDetailsID,
    SD.SalesID,
    ISNULL(SD.LineItemNumber, 1),
    ST.StockId,
    ISNULL(SD.SalePrice,         0),
    ISNULL(SD.LineItemDiscount,  0)
FROM [Normalized].[_Original_Data_SalesDetails] AS SD
INNER JOIN [Normalized].[Sales]                 AS SA
    ON SA.SalesId = SD.SalesID
INNER JOIN [Normalized].[Stock]                 AS ST
    ON ST.StockCode = TRIM(SD.StockID);
GO

SET IDENTITY_INSERT [Normalized].[SalesDetails] OFF;
GO


/* ============================================================================
   SECTION 8 — Views replacing yellow-highlighted physical tables
   ============================================================================
   All 19 highlighted tables from the project image are replaced here.
   Physical copies are retained as _Original_ snapshots (Section 3) for audit.

   Tables replaced:
     DataTransfer  : Sales2015, Sales2016, Sales2017, Sales2018
     Output        : StockPrices
     Reference     : Budget, Forex, MarketingCategories, MarketingInformation,
                     SalesBudgets, SalesCategory, Staff, StaffHierarchy, YearlySales
     SourceData    : SalesInPounds, SalesText
     Data          : SalesByCountry (was already a view), PivotTable
   ============================================================================ */

/* Drop in reverse dependency order */
DROP FUNCTION IF EXISTS [Subroutines].[itvf_SalesByYear];
DROP FUNCTION IF EXISTS [Subroutines].[itvf_SalesByCountryISO2];
DROP FUNCTION IF EXISTS [Subroutines].[itvf_SalesByMake];
GO

DROP VIEW IF EXISTS [Normalized].[vw_SalesByCountry];
DROP VIEW IF EXISTS [Normalized].[vw_StockPrices];
DROP VIEW IF EXISTS [Normalized].[vw_YearlySales];
DROP VIEW IF EXISTS [Normalized].[vw_SalesPivotByColorYear];
DROP VIEW IF EXISTS [Normalized].[vw_DataTransfer_Sales2015];
DROP VIEW IF EXISTS [Normalized].[vw_DataTransfer_Sales2016];
DROP VIEW IF EXISTS [Normalized].[vw_DataTransfer_Sales2017];
DROP VIEW IF EXISTS [Normalized].[vw_DataTransfer_Sales2018];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_Budget];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_Forex];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_MarketingCategories];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_MarketingInformation];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_SalesBudgets];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_SalesCategory];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_Staff];
DROP VIEW IF EXISTS [Normalized].[vw_Reference_StaffHierarchy];
DROP VIEW IF EXISTS [Normalized].[vw_SourceData_SalesInPounds];
DROP VIEW IF EXISTS [Normalized].[vw_SourceData_SalesText];
GO

/* ------------------------------------------------------------------
   8.1  vw_SalesByCountry
        Replaces: Data.SalesByCountry (was a denormalized view/table)
        Purpose : Full sales report joined across all normalized tables
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_SalesByCountry]
AS
SELECT
    CO.CountryName,
    CO.CountryISO2,
    CO.CountryISO3,
    SR.SalesRegion,
    MK.MakeName,
    MD.ModelName,
    MD.ModelVariant,
    ST.StockCode,
    ST.Color,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    SD.SalePrice,
    SD.LineItemDiscount,
    SA.InvoiceNumber,
    SA.TotalSalePrice,
    SA.SaleDate,
    CS.CustomerName,
    SD.SalesDetailsId,
    SA.SalesId,
    ST.StockId,
    MD.ModelId,
    MK.MakeId,
    CS.CustomerId,
    CO.CountryId
FROM [Normalized].[SalesDetails] AS SD
INNER JOIN [Normalized].[Sales]       AS SA ON SD.SalesId    = SA.SalesId
INNER JOIN [Normalized].[Customer]    AS CS ON SA.CustomerId  = CS.CustomerId
INNER JOIN [Normalized].[Country]     AS CO ON CS.CountryId   = CO.CountryId
INNER JOIN [Normalized].[SalesRegion] AS SR ON CO.SalesRegionId = SR.SalesRegionId
INNER JOIN [Normalized].[Stock]       AS ST ON SD.StockId     = ST.StockId
INNER JOIN [Normalized].[Model]       AS MD ON ST.ModelId     = MD.ModelId
INNER JOIN [Normalized].[Make]        AS MK ON MD.MakeId      = MK.MakeId;
GO

/* ------------------------------------------------------------------
   8.2  vw_StockPrices
        Replaces: Output.StockPrices (stored MakeName, ModelName, Cost)
        Purpose : Live vehicle inventory pricing — always current
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_StockPrices]
AS
SELECT
    MK.MakeName,
    MD.ModelName,
    MD.ModelVariant,
    ST.StockCode,
    ST.Color,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    ST.DateBought,
    ST.TimeBought
FROM [Normalized].[Stock] AS ST
INNER JOIN [Normalized].[Model] AS MD ON ST.ModelId = MD.ModelId
INNER JOIN [Normalized].[Make]  AS MK ON MD.MakeId  = MK.MakeId;
GO

/* ------------------------------------------------------------------
   8.3  vw_YearlySales
        Replaces: Reference.YearlySales (static yearly report dump)
        Purpose : Dynamic yearly sales report — filter by SaleYear
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_YearlySales]
AS
SELECT
    DATEPART(YEAR, SA.SaleDate) AS SaleYear,
    MK.MakeName,
    MD.ModelName,
    MD.ModelVariant,
    CS.CustomerName,
    CO.CountryName,
    CO.CountryISO2,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    SD.SalePrice,
    SD.LineItemDiscount,
    SA.SaleDate,
    SA.InvoiceNumber,
    ST.Color,
    SA.SalesId,
    SD.SalesDetailsId
FROM [Normalized].[SalesDetails] AS SD
INNER JOIN [Normalized].[Sales]    AS SA ON SD.SalesId   = SA.SalesId
INNER JOIN [Normalized].[Customer] AS CS ON SA.CustomerId = CS.CustomerId
INNER JOIN [Normalized].[Country]  AS CO ON CS.CountryId  = CO.CountryId
INNER JOIN [Normalized].[Stock]    AS ST ON SD.StockId    = ST.StockId
INNER JOIN [Normalized].[Model]    AS MD ON ST.ModelId    = MD.ModelId
INNER JOIN [Normalized].[Make]     AS MK ON MD.MakeId     = MK.MakeId;
GO

/* ------------------------------------------------------------------
   8.4  vw_SalesPivotByColorYear
        Replaces: Data.PivotTable (stored one static pivot snapshot)
        Purpose : Always-current pivot of net sales by color and year
                  Net = SalePrice - LineItemDiscount
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_SalesPivotByColorYear]
AS
SELECT
    ST.Color,
    SUM(CASE WHEN DATEPART(YEAR, SA.SaleDate) = 2015 THEN SD.SalePrice - SD.LineItemDiscount ELSE 0 END) AS [2015],
    SUM(CASE WHEN DATEPART(YEAR, SA.SaleDate) = 2016 THEN SD.SalePrice - SD.LineItemDiscount ELSE 0 END) AS [2016],
    SUM(CASE WHEN DATEPART(YEAR, SA.SaleDate) = 2017 THEN SD.SalePrice - SD.LineItemDiscount ELSE 0 END) AS [2017],
    SUM(CASE WHEN DATEPART(YEAR, SA.SaleDate) = 2018 THEN SD.SalePrice - SD.LineItemDiscount ELSE 0 END) AS [2018]
FROM [Normalized].[SalesDetails] AS SD
INNER JOIN [Normalized].[Sales] AS SA ON SD.SalesId = SA.SalesId
INNER JOIN [Normalized].[Stock] AS ST ON SD.StockId = ST.StockId
GROUP BY ST.Color;
GO

/* ------------------------------------------------------------------
   8.5–8.8  DataTransfer year views
        Replaces: DataTransfer.Sales2015 / 2016 / 2017 / 2018
        Purpose : Year-filtered views avoid four duplicate physical tables.
                  The ITVF itvf_SalesByYear (Section 9) is the preferred
                  parameterized version; these views exist for tool
                  compatibility with the original schema consumers.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_DataTransfer_Sales2015]
AS
SELECT MakeName, ModelName, CustomerName, CountryName, Cost, RepairsCost,
       PartsCost, TransportInCost, SalePrice, SaleDate
FROM   [Normalized].[vw_YearlySales]
WHERE  SaleYear = 2015;
GO

CREATE VIEW [Normalized].[vw_DataTransfer_Sales2016]
AS
SELECT MakeName, ModelName, CustomerName, CountryName, Cost, RepairsCost,
       PartsCost, TransportInCost, SalePrice, SaleDate
FROM   [Normalized].[vw_YearlySales]
WHERE  SaleYear = 2016;
GO

CREATE VIEW [Normalized].[vw_DataTransfer_Sales2017]
AS
SELECT MakeName, ModelName, CustomerName, CountryName, Cost, RepairsCost,
       PartsCost, TransportInCost, SalePrice, SaleDate
FROM   [Normalized].[vw_YearlySales]
WHERE  SaleYear = 2017;
GO

CREATE VIEW [Normalized].[vw_DataTransfer_Sales2018]
AS
SELECT MakeName, ModelName, CustomerName, CountryName, Cost, RepairsCost,
       PartsCost, TransportInCost, SalePrice, SaleDate
FROM   [Normalized].[vw_YearlySales]
WHERE  SaleYear = 2018;
GO

/* ------------------------------------------------------------------
   8.9  vw_Reference_Budget
        Replaces: Reference.Budget (static budget snapshot table)
        Purpose : Exposes budget data from the preserved original,
                  keeping it queryable without a permanent physical table
                  in the active schema.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_Budget]
AS
SELECT
    BudgetKey,
    BudgetValue,
    [Year],
    [Month],
    BudgetDetail,
    BudgetElement
FROM [Normalized].[_Original_Reference_Budget];
GO

/* ------------------------------------------------------------------
   8.10 vw_Reference_Forex
        Replaces: Reference.Forex
        Purpose : Currency exchange rate lookup, sourced from snapshot.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_Forex]
AS
SELECT
    ExchangeDate,
    ISOCurrency,
    ExchangeRate
FROM [Normalized].[_Original_Reference_Forex];
GO

/* ------------------------------------------------------------------
   8.11 vw_Reference_MarketingCategories
        Replaces: Reference.MarketingCategories
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_MarketingCategories]
AS
SELECT
    MakeName,
    MarketingType
FROM [Normalized].[_Original_Reference_MarketingCategories];
GO

/* ------------------------------------------------------------------
   8.12 vw_Reference_MarketingInformation
        Replaces: Reference.MarketingInformation
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_MarketingInformation]
AS
SELECT
    CUST,
    Country,
    SpendCapacity
FROM [Normalized].[_Original_Reference_MarketingInformation];
GO

/* ------------------------------------------------------------------
   8.13 vw_Reference_SalesBudgets
        Replaces: Reference.SalesBudgets
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_SalesBudgets]
AS
SELECT
    BudgetArea,
    BudgetAmount,
    BudgetYear,
    DateUpdated,
    Comments,
    BudgetMonth
FROM [Normalized].[_Original_Reference_SalesBudgets];
GO

/* ------------------------------------------------------------------
   8.14 vw_Reference_SalesCategory
        Replaces: Reference.SalesCategory
        Purpose : Price-band classification for reporting.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_SalesCategory]
AS
SELECT
    LowerThreshold,
    UpperThreshold,
    CategoryDescription
FROM [Normalized].[_Original_Reference_SalesCategory];
GO

/* ------------------------------------------------------------------
   8.15 vw_Reference_Staff
        Replaces: Reference.Staff
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_Staff]
AS
SELECT
    StaffID,
    StaffName,
    ManagerID,
    Department
FROM [Normalized].[_Original_Reference_Staff];
GO

/* ------------------------------------------------------------------
   8.16 vw_Reference_StaffHierarchy
        Replaces: Reference.StaffHierarchy
        Purpose : Org-chart traversal via hierarchyid preserved from source.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_Reference_StaffHierarchy]
AS
SELECT
    HierarchyReference,
    StaffID,
    StaffName,
    ManagerID,
    Department
FROM [Normalized].[_Original_Reference_StaffHierarchy];
GO

/* ------------------------------------------------------------------
   8.17 vw_SourceData_SalesInPounds
        Replaces: SourceData.SalesInPounds
        Purpose : Source-format vehicle cost in pounds for currency analysis.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_SourceData_SalesInPounds]
AS
SELECT
    MakeName,
    ModelName,
    VehicleCost
FROM [Normalized].[_Original_SourceData_SalesInPounds];
GO

/* ------------------------------------------------------------------
   8.18 vw_SourceData_SalesText
        Replaces: SourceData.SalesText
        Purpose : Source text-format sales data for import/ETL audit.
   ------------------------------------------------------------------ */
CREATE VIEW [Normalized].[vw_SourceData_SalesText]
AS
SELECT
    CountryName,
    MakeName,
    Cost,
    SalePrice
FROM [Normalized].[_Original_SourceData_SalesText];
GO


/* ============================================================================
   SECTION 9 — Inline table-valued functions (ITVFs)
   ============================================================================
   ITVFs are used where a view would need parameters.  They are treated by the
   query optimizer as if they were inline subqueries — no function-call overhead
   penalty when parameters match indexed columns.

   Usage examples at the end of each function block.
   ============================================================================ */

/* ------------------------------------------------------------------
   9.1  itvf_SalesByYear
        Preferred replacement for the four DataTransfer year tables.
        Single parameterized function instead of four static views.

   Usage:
     SELECT * FROM [Subroutines].[itvf_SalesByYear](2018);
   ------------------------------------------------------------------ */
CREATE FUNCTION [Subroutines].[itvf_SalesByYear]
(
    @SaleYear [UserDefinedTypes].[YearNumber]
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        DATEPART(YEAR, SA.SaleDate) AS SaleYear,
        MK.MakeName,
        MD.ModelName,
        MD.ModelVariant,
        CS.CustomerName,
        CO.CountryName,
        CO.CountryISO2,
        SR.SalesRegion,
        ST.StockCode,
        ST.Color,
        ST.Cost,
        ST.RepairsCost,
        ST.PartsCost,
        ST.TransportInCost,
        SD.SalePrice,
        SD.LineItemDiscount,
        SA.TotalSalePrice,
        SA.InvoiceNumber,
        SA.SaleDate,
        SA.SalesId,
        SD.SalesDetailsId
    FROM [Normalized].[SalesDetails] AS SD
    INNER JOIN [Normalized].[Sales]       AS SA ON SD.SalesId     = SA.SalesId
    INNER JOIN [Normalized].[Customer]    AS CS ON SA.CustomerId   = CS.CustomerId
    INNER JOIN [Normalized].[Country]     AS CO ON CS.CountryId    = CO.CountryId
    INNER JOIN [Normalized].[SalesRegion] AS SR ON CO.SalesRegionId= SR.SalesRegionId
    INNER JOIN [Normalized].[Stock]       AS ST ON SD.StockId      = ST.StockId
    INNER JOIN [Normalized].[Model]       AS MD ON ST.ModelId      = MD.ModelId
    INNER JOIN [Normalized].[Make]        AS MK ON MD.MakeId       = MK.MakeId
    WHERE DATEPART(YEAR, SA.SaleDate) = @SaleYear
);
GO

/* ------------------------------------------------------------------
   9.2  itvf_SalesByCountryISO2
        Parameterized sales report filtered to a single country.

   Usage:
     SELECT * FROM [Subroutines].[itvf_SalesByCountryISO2](N'GB');
   ------------------------------------------------------------------ */
CREATE FUNCTION [Subroutines].[itvf_SalesByCountryISO2]
(
    @CountryISO2 [UserDefinedTypes].[ISOAlpha2]
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CO.CountryName,
        CO.CountryISO2,
        CO.CountryISO3,
        SR.SalesRegion,
        MK.MakeName,
        MD.ModelName,
        MD.ModelVariant,
        CS.CustomerName,
        ST.StockCode,
        ST.Color,
        SD.SalePrice,
        SD.LineItemDiscount,
        SA.TotalSalePrice,
        SA.InvoiceNumber,
        SA.SaleDate,
        SA.SalesId,
        SD.SalesDetailsId
    FROM [Normalized].[SalesDetails] AS SD
    INNER JOIN [Normalized].[Sales]       AS SA ON SD.SalesId      = SA.SalesId
    INNER JOIN [Normalized].[Customer]    AS CS ON SA.CustomerId    = CS.CustomerId
    INNER JOIN [Normalized].[Country]     AS CO ON CS.CountryId     = CO.CountryId
    INNER JOIN [Normalized].[SalesRegion] AS SR ON CO.SalesRegionId = SR.SalesRegionId
    INNER JOIN [Normalized].[Stock]       AS ST ON SD.StockId       = ST.StockId
    INNER JOIN [Normalized].[Model]       AS MD ON ST.ModelId       = MD.ModelId
    INNER JOIN [Normalized].[Make]        AS MK ON MD.MakeId        = MK.MakeId
    WHERE CO.CountryISO2 = @CountryISO2
);
GO

/* ------------------------------------------------------------------
   9.3  itvf_SalesByMake
        Parameterized sales report filtered to a single vehicle make.

   Usage:
     SELECT * FROM [Subroutines].[itvf_SalesByMake](N'Ferrari');
   ------------------------------------------------------------------ */
CREATE FUNCTION [Subroutines].[itvf_SalesByMake]
(
    @MakeName [UserDefinedTypes].[LongName]
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        MK.MakeName,
        MD.ModelName,
        MD.ModelVariant,
        CO.CountryName AS CustomerCountry,
        CS.CustomerName,
        ST.StockCode,
        ST.Color,
        ST.Cost,
        SD.SalePrice,
        SD.LineItemDiscount,
        SA.TotalSalePrice,
        SA.InvoiceNumber,
        SA.SaleDate,
        SA.SalesId,
        SD.SalesDetailsId
    FROM [Normalized].[SalesDetails] AS SD
    INNER JOIN [Normalized].[Sales]    AS SA ON SD.SalesId    = SA.SalesId
    INNER JOIN [Normalized].[Customer] AS CS ON SA.CustomerId  = CS.CustomerId
    INNER JOIN [Normalized].[Country]  AS CO ON CS.CountryId   = CO.CountryId
    INNER JOIN [Normalized].[Stock]    AS ST ON SD.StockId     = ST.StockId
    INNER JOIN [Normalized].[Model]    AS MD ON ST.ModelId     = MD.ModelId
    INNER JOIN [Normalized].[Make]     AS MK ON MD.MakeId      = MK.MakeId
    WHERE MK.MakeName = @MakeName
);
GO


/* ============================================================================
   SECTION 10 — Verification queries
   ============================================================================ */

/* 10.1  Row counts for all normalized tables */
SELECT 'Normalized.SalesRegion'  AS TableName, COUNT(*) AS RowCount FROM [Normalized].[SalesRegion]
UNION ALL SELECT 'Normalized.Country',      COUNT(*) FROM [Normalized].[Country]
UNION ALL SELECT 'Normalized.Customer',     COUNT(*) FROM [Normalized].[Customer]
UNION ALL SELECT 'Normalized.Make',         COUNT(*) FROM [Normalized].[Make]
UNION ALL SELECT 'Normalized.Model',        COUNT(*) FROM [Normalized].[Model]
UNION ALL SELECT 'Normalized.Stock',        COUNT(*) FROM [Normalized].[Stock]
UNION ALL SELECT 'Normalized.Sales',        COUNT(*) FROM [Normalized].[Sales]
UNION ALL SELECT 'Normalized.SalesDetails', COUNT(*) FROM [Normalized].[SalesDetails]
UNION ALL SELECT 'Process.WorkflowSteps',   COUNT(*) FROM [Process].[WorkflowSteps]
ORDER BY TableName;
GO

/* 10.2  Anomaly / exclusion audit — rows that did not load and why */
SELECT
    'Stock rows excluded: invalid ModelID' AS AnomalyCheck,
    COUNT(*) AS ProblemRows
FROM [Normalized].[_Original_Data_Stock] AS ST
LEFT JOIN [Normalized].[Model]            AS MD ON MD.ModelId = ST.ModelID
WHERE MD.ModelId IS NULL

UNION ALL

SELECT
    'SalesDetails rows excluded: invalid StockID',
    COUNT(*)
FROM [Normalized].[_Original_Data_SalesDetails] AS SD
LEFT JOIN [Normalized].[Stock]                   AS ST ON ST.StockCode = TRIM(SD.StockID)
WHERE ST.StockId IS NULL

UNION ALL

SELECT
    'Sales rows excluded: invalid CustomerID',
    COUNT(*)
FROM [Normalized].[_Original_Data_Sales] AS SA
LEFT JOIN #MapCustomer                   AS MC ON MC.OldCustomerID = TRIM(SA.CustomerID)
WHERE MC.NewCustomerId IS NULL;
GO

/* 10.3  Confirm all views are present */
SELECT TABLE_SCHEMA, TABLE_NAME
FROM   INFORMATION_SCHEMA.VIEWS
WHERE  TABLE_SCHEMA = N'Normalized'
ORDER BY TABLE_NAME;
GO

/* 10.4  Confirm all ITVFs are present */
SELECT ROUTINE_SCHEMA, ROUTINE_NAME, ROUTINE_TYPE
FROM   INFORMATION_SCHEMA.ROUTINES
WHERE  ROUTINE_SCHEMA = N'Subroutines'
ORDER BY ROUTINE_NAME;
GO

/* 10.5  Confirm all indexes are present */
SELECT
    OBJECT_NAME(i.object_id)    AS TableName,
    i.name                      AS IndexName,
    i.type_desc                 AS IndexType,
    i.is_unique                 AS IsUnique,
    i.is_primary_key            AS IsPrimaryKey
FROM sys.indexes AS i
WHERE OBJECT_SCHEMA_NAME(i.object_id) = N'Normalized'
  AND i.name IS NOT NULL
ORDER BY TableName, IndexName;
GO

/* 10.6  Sample the main reporting view */
SELECT TOP 10 *
FROM [Normalized].[vw_SalesByCountry]
ORDER BY SaleDate DESC;
GO

/*
================================================================================
  End of Final_Project2_5_PrestigeCars.sql
================================================================================
*/
