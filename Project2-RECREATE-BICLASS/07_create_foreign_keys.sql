-- =============================================
-- File: 07_create_foreign_keys.sql
-- Purpose:
--   This script manages the relationships between the dimension tables,
--   the fact table, and the product hierarchy tables.
--
-- What this script does:
--   1. Drops existing foreign keys if they already exist.
--   2. Recreates the foreign keys in the correct order.
--   3. Runs a verification query at the end.
--
-- Why this matters:
--   Foreign keys enforce the star schema relationships and protect
--   referential integrity between facts and dimensions.
-- =============================================

USE G9_2;
GO

-- =============================================
-- DROP EXISTING FOREIGN KEYS (FACT TABLE FIRST)
-- =============================================

-- Fact table foreign key to DimProduct
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimProduct]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimProduct];
GO

-- Fact table foreign key to SalesManagers
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_SalesManagers]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_SalesManagers];
GO

-- Fact table foreign key to DimMaritalStatus
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimMaritalStatus]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimMaritalStatus];
GO

-- Fact table foreign key to DimGender
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimGender]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimGender];
GO

-- Fact table foreign key to DimOccupation
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimOccupation]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimOccupation];
GO

-- Fact table foreign key to DimOrderDate
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimOrderDate]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimOrderDate];
GO

-- Fact table foreign key to DimTerritory
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimTerritory]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimTerritory];
GO

-- Fact table foreign key to DimCustomer
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimCustomer]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimCustomer];
GO

-- Product foreign key to product subcategory
IF OBJECT_ID('[CH01-01-Dimension].[FK_DimProduct_DimProductSubcategory]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Dimension].[DimProduct] DROP CONSTRAINT [FK_DimProduct_DimProductSubcategory];
GO

-- Product subcategory foreign key to product category
IF OBJECT_ID('[CH01-01-Dimension].[FK_DimProductSubcategory_Category]', 'F') IS NOT NULL
    ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory] DROP CONSTRAINT [FK_DimProductSubcategory_Category];
GO

-- =============================================
-- CREATE FOREIGN KEYS
-- =============================================

-- Link product subcategories to product categories.
IF OBJECT_ID('[CH01-01-Dimension].[FK_DimProductSubcategory_Category]', 'F') IS NULL
    ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
    ADD CONSTRAINT FK_DimProductSubcategory_Category
    FOREIGN KEY (ProductCategoryKey)
    REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey);
GO

-- Link products to product subcategories.
IF OBJECT_ID('[CH01-01-Dimension].[FK_DimProduct_DimProductSubcategory]', 'F') IS NULL
    ALTER TABLE [CH01-01-Dimension].[DimProduct]
    ADD CONSTRAINT FK_DimProduct_DimProductSubcategory
    FOREIGN KEY (ProductSubcategoryKey)
    REFERENCES [CH01-01-Dimension].[DimProductSubcategory](ProductSubcategoryKey);
GO

-- =============================================
-- FACT TABLE FOREIGN KEYS
-- =============================================

-- Link fact table rows to DimProduct.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimProduct]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimProduct
    FOREIGN KEY (ProductKey)
    REFERENCES [CH01-01-Dimension].[DimProduct](ProductKey);
GO

-- Link fact table rows to SalesManagers.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_SalesManagers]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_SalesManagers
    FOREIGN KEY (SalesManagerKey)
    REFERENCES [CH01-01-Dimension].[SalesManagers](SalesManagerKey);
GO

-- Link fact table rows to DimMaritalStatus.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimMaritalStatus]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimMaritalStatus
    FOREIGN KEY (MaritalStatus)
    REFERENCES [CH01-01-Dimension].[DimMaritalStatus](MaritalStatus);
GO

-- Link fact table rows to DimGender.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimGender]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimGender
    FOREIGN KEY (Gender)
    REFERENCES [CH01-01-Dimension].[DimGender](Gender);
GO

-- Link fact table rows to DimOccupation.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimOccupation]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimOccupation
    FOREIGN KEY (OccupationKey)
    REFERENCES [CH01-01-Dimension].[DimOccupation](OccupationKey);
GO

-- Link fact table rows to DimOrderDate.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimOrderDate]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimOrderDate
    FOREIGN KEY (OrderDate)
    REFERENCES [CH01-01-Dimension].[DimOrderDate](OrderDate);
GO

-- Link fact table rows to DimTerritory.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimTerritory]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimTerritory
    FOREIGN KEY (TerritoryKey)
    REFERENCES [CH01-01-Dimension].[DimTerritory](TerritoryKey);
GO

-- Link fact table rows to DimCustomer.
IF OBJECT_ID('[CH01-01-Fact].[FK_Data_DimCustomer]', 'F') IS NULL
    ALTER TABLE [CH01-01-Fact].[Data]
    ADD CONSTRAINT FK_Data_DimCustomer
    FOREIGN KEY (CustomerKey)
    REFERENCES [CH01-01-Dimension].[DimCustomer](CustomerKey);
GO

-- =============================================
-- VERIFICATION
-- Display all foreign keys after creation.
-- =============================================
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS ChildSchema,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ParentSchema,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable
FROM sys.foreign_keys fk
ORDER BY ChildSchema, ChildTable, ForeignKeyName;
GO
