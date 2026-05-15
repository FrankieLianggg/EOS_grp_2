-- =============================================
-- 02_copy_source_tables.sql
-- Copy source data from BIClass into G9_2
-- =============================================

USE G9_2; -- makes sure the copied source tables are created in the target project database
GO

-- =============================================
-- Ensure FileUpload schema exists
-- =============================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'FileUpload')
    EXEC('CREATE SCHEMA FileUpload'); -- creates the schema that will store the copied source data
GO

-- =============================================
-- Copy OriginallyLoadedData
-- =============================================
IF OBJECT_ID('FileUpload.OriginallyLoadedData', 'U') IS NOT NULL
    DROP TABLE FileUpload.OriginallyLoadedData; -- removes the old copy so the table can be recreated cleanly
GO

SELECT *
INTO FileUpload.OriginallyLoadedData -- copies the BIClass source rows into our project database
FROM BIClass.FileUpload.OriginallyLoadedData;
GO

-- =============================================
-- Copy ProductCategories
-- =============================================
IF OBJECT_ID('FileUpload.ProductCategories', 'U') IS NOT NULL
    DROP TABLE FileUpload.ProductCategories;
GO

SELECT *
INTO FileUpload.ProductCategories
FROM BIClass.FileUpload.ProductCategories;
GO

-- =============================================
-- Copy ProductSubcategories
-- =============================================
IF OBJECT_ID('FileUpload.ProductSubcategories', 'U') IS NOT NULL
    DROP TABLE FileUpload.ProductSubcategories;
GO

SELECT *
INTO FileUpload.ProductSubcategories
FROM BIClass.FileUpload.ProductSubcategories;
GO

-- =============================================
-- Verification: List copied tables
-- =============================================
SELECT 
    s.name AS SchemaName, 
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'FileUpload' -- limits the verification output to the copied source tables only
ORDER BY t.name;
GO