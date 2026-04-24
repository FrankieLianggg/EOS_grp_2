-- =============================================
-- File: 05_create_core_tables_from_BIClass.sql
-- Purpose:
--   This script recreates the core BIClass dimension tables in G9_2.
--   These tables are part of the target star schema.
--
-- What this script does:
--   1. Switches context to the G9_2 database.
--   2. Drops old versions of the core dimension tables if they exist.
--   3. Recreates the dimension tables using sequence-based keys where needed.
--   4. Adds UserAuthorizationKey columns so we can track who loaded the data.
--
-- Notes:
--   - The fact table and DimProduct are created in later scripts in some versions
--     of this project. This script focuses on the core dimension objects.
--   - Sequence objects must already exist before this script is run.
-- =============================================

USE G9_2;
GO

-- -------------------------------------------------
-- Drop the old tables first so the script can be rerun cleanly.
-- This avoids errors if the tables already exist from a previous run.
-- -------------------------------------------------
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimCustomer];
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimGender];
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimMaritalStatus];
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimOccupation];
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimOrderDate];
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimTerritory];
DROP TABLE IF EXISTS [CH01-01-Dimension].[SalesManagers];
GO

-- -------------------------------------------------
-- Create DimCustomer
-- Stores one row per customer and uses a sequence-based surrogate key.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimCustomer](
    CustomerKey INT PRIMARY KEY DEFAULT NEXT VALUE FOR PkSequence.DimCustomerSequenceObject,
    CustomerName VARCHAR(30),
    UserAuthorizationKey INT
);

-- -------------------------------------------------
-- Create DimGender
-- This is a small lookup dimension using the natural key Gender.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimGender](
    Gender CHAR(1) PRIMARY KEY,
    UserAuthorizationKey INT
);

-- -------------------------------------------------
-- Create DimMaritalStatus
-- This is another small lookup dimension using the natural key MaritalStatus.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimMaritalStatus](
    MaritalStatus CHAR(1) PRIMARY KEY,
    UserAuthorizationKey INT
);

-- -------------------------------------------------
-- Create DimOccupation
-- Stores occupations and uses a sequence-based surrogate key.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimOccupation](
    OccupationKey INT PRIMARY KEY DEFAULT NEXT VALUE FOR PkSequence.DimOccupationSequenceObject,
    Occupation VARCHAR(20),
    UserAuthorizationKey INT
);

-- -------------------------------------------------
-- Create DimOrderDate
-- Stores order dates. In this design the date itself is the primary key.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimOrderDate](
    OrderDate DATE PRIMARY KEY
);

-- -------------------------------------------------
-- Create DimTerritory
-- Stores territory location information with a surrogate key.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimTerritory](
    TerritoryKey INT PRIMARY KEY DEFAULT NEXT VALUE FOR PkSequence.DimTerritorySequenceObject,
    TerritoryRegion VARCHAR(20),
    TerritoryCountry VARCHAR(20),
    TerritoryGroup VARCHAR(20),
    UserAuthorizationKey INT
);

-- -------------------------------------------------
-- Create SalesManagers
-- Stores the sales manager dimension using a surrogate key.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[SalesManagers](
    SalesManagerKey INT PRIMARY KEY DEFAULT NEXT VALUE FOR PkSequence.SalesManagersSequenceObject,
    SalesManager VARCHAR(20),
    UserAuthorizationKey INT
);
GO
