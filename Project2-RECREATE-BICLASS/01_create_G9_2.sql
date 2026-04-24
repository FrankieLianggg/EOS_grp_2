-- =============================================
-- 01_create_G9_2.sql
-- Create Project Database and Required Schemas
-- =============================================

-- Create database if it does not exist
IF DB_ID('G9_2') IS NULL
    CREATE DATABASE G9_2; -- creates the project database the first time the script is run
GO

-- Switch to database
USE G9_2; -- switches context so all new objects are created in the group database
GO

-- =============================================
-- Create Required Schemas (Only if not exists)
-- =============================================

-- DbSecurity schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DbSecurity')
    EXEC('CREATE SCHEMA DbSecurity'); -- stores user and authorization-related tables
GO

-- Process schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Process')
    EXEC('CREATE SCHEMA Process');
GO

-- Sequence schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'PkSequence')
    EXEC('CREATE SCHEMA PkSequence');
GO

-- Dimension schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'CH01-01-Dimension')
    EXEC('CREATE SCHEMA [CH01-01-Dimension]'); -- holds the dimension tables for the star schema
GO

-- Fact schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'CH01-01-Fact')
    EXEC('CREATE SCHEMA [CH01-01-Fact]');
GO

-- =============================================
-- Verify schemas
-- =============================================
SELECT name AS SchemaName
FROM sys.schemas
ORDER BY name; -- confirms that the required schemas were created successfully
GO