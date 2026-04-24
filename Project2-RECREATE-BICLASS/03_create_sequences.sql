-- =============================================
-- 03_create_sequences.sql
-- Create all sequence objects for primary keys
-- =============================================

USE G9_2; -- ensures all sequence objects are created inside the project database
GO

-- =============================================
-- Ensure PkSequence schema exists
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'PkSequence')
    EXEC('CREATE SCHEMA PkSequence'); -- creates a dedicated schema for sequence objects
GO

-- =============================================
-- Create Sequences (only if not exists)
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'UserAuthorizationSequenceObject')
    CREATE SEQUENCE PkSequence.UserAuthorizationSequenceObject -- generates keys for the UserAuthorization table
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'WorkflowStepsSequenceObject')
    CREATE SEQUENCE PkSequence.WorkflowStepsSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimProductCategorySequenceObject')
    CREATE SEQUENCE PkSequence.DimProductCategorySequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimProductSubcategorySequenceObject')
    CREATE SEQUENCE PkSequence.DimProductSubcategorySequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimProductSequenceObject')
    CREATE SEQUENCE PkSequence.DimProductSequenceObject -- generates surrogate keys for DimProduct
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'SalesManagersSequenceObject')
    CREATE SEQUENCE PkSequence.SalesManagersSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimCustomerSequenceObject')
    CREATE SEQUENCE PkSequence.DimCustomerSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimGenderSequenceObject')
    CREATE SEQUENCE PkSequence.DimGenderSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimMaritalStatusSequenceObject')
    CREATE SEQUENCE PkSequence.DimMaritalStatusSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimOccupationSequenceObject')
    CREATE SEQUENCE PkSequence.DimOccupationSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimOrderDateSequenceObject')
    CREATE SEQUENCE PkSequence.DimOrderDateSequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DimTerritorySequenceObject')
    CREATE SEQUENCE PkSequence.DimTerritorySequenceObject
    AS INT START WITH 1 INCREMENT BY 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'DataSequenceObject')
    CREATE SEQUENCE PkSequence.DataSequenceObject -- generates surrogate keys for the fact table
    AS INT START WITH 1 INCREMENT BY 1;
GO

-- =============================================
-- Verification: List all sequences
-- =============================================
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS SequenceName
FROM sys.sequences
ORDER BY name; -- lists all sequences so we can verify they exist
GO