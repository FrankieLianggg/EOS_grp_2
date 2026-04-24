-- =============================================
-- File: 06_create_new_product_dimensions.sql
-- Purpose:
--   This script creates the two new product hierarchy dimensions required
--   by Project 2: DimProductCategory and DimProductSubcategory.
--
-- What this script does:
--   1. Switches to G9_2.
--   2. Drops the product hierarchy tables if they already exist.
--   3. Recreates DimProductCategory.
--   4. Recreates DimProductSubcategory and links it to DimProductCategory.
--
-- Why this matters:
--   The project requires adding product category and product subcategory
--   so that the star schema can model the product hierarchy correctly.
-- =============================================

USE G9_2;
GO

-- -------------------------------------------------
-- Drop subcategory first because it depends on category.
-- Then drop category.
-- -------------------------------------------------
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductSubcategory];
DROP TABLE IF EXISTS [CH01-01-Dimension].[DimProductCategory];
GO

-- -------------------------------------------------
-- Create DimProductCategory
-- Stores the top level product grouping.
-- ProductCategoryKey is generated from a sequence object.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimProductCategory](
    ProductCategoryKey INT PRIMARY KEY DEFAULT NEXT VALUE FOR PkSequence.DimProductCategorySequenceObject,
    ProductCategory VARCHAR(20),
    UserAuthorizationKey INT
);

-- -------------------------------------------------
-- Create DimProductSubcategory
-- Stores the second level in the product hierarchy.
-- Each subcategory belongs to one category.
-- -------------------------------------------------
CREATE TABLE [CH01-01-Dimension].[DimProductSubcategory](
    ProductSubcategoryKey INT PRIMARY KEY DEFAULT NEXT VALUE FOR PkSequence.DimProductSubcategorySequenceObject,
    ProductCategoryKey INT,
    ProductSubcategory VARCHAR(20),
    UserAuthorizationKey INT,
    FOREIGN KEY (ProductCategoryKey)
        REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey)
);
GO
