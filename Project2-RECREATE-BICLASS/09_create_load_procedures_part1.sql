-- =============================================
-- File: 09_create_load_procedures_part1.sql
-- Purpose:
--   This script creates the first group of ETL load procedures.
--   These procedures populate smaller lookup and hierarchy dimensions.
--
-- Procedures included:
--   1. Project2.Load_DimProductCategory
--   2. Project2.Load_DimProductSubcategory
--   3. Project2.Load_SalesManagers
--   4. Project2.Load_DimGender
--   5. Project2.Load_DimMaritalStatus
--
-- Common ETL pattern used in each procedure:
--   - start a timer
--   - insert only new distinct rows from FileUpload.OriginallyLoadedData
--   - log the result using Process.usp_TrackWorkFlow
-- =============================================

USE G9_2;
GO

-- =============================================
-- Procedure: Project2.Load_DimProductCategory
-- Purpose:
--   Loads the product category dimension from the source file upload table.
--   Only distinct, non-null product categories are inserted.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimProductCategory
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProductCategory]
    (
        ProductCategoryKey,
        ProductCategory,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.DimProductCategorySequenceObject,
        src.ProductCategory,
        @UserKey
    FROM
    (
        SELECT ProductCategory
        FROM FileUpload.OriginallyLoadedData
        WHERE ProductCategory IS NOT NULL
        GROUP BY ProductCategory
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimProductCategory] d
        WHERE d.ProductCategory = src.ProductCategory
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimProductCategory',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_DimProductSubcategory
-- Purpose:
--   Loads product subcategories and links each one to its parent category.
--   The category key is looked up from DimProductCategory.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimProductSubcategory
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProductSubcategory]
    (
        ProductSubcategoryKey,
        ProductCategoryKey,
        ProductSubcategory,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.DimProductSubcategorySequenceObject,
        pc.ProductCategoryKey,
        src.ProductSubcategory,
        @UserKey
    FROM
    (
        SELECT ProductCategory, ProductSubcategory
        FROM FileUpload.OriginallyLoadedData
        WHERE ProductSubcategory IS NOT NULL
        GROUP BY ProductCategory, ProductSubcategory
    ) AS src
    INNER JOIN [CH01-01-Dimension].[DimProductCategory] pc
        ON pc.ProductCategory = src.ProductCategory
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimProductSubcategory] d
        WHERE d.ProductSubcategory = src.ProductSubcategory
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimProductSubcategory',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_SalesManagers
-- Purpose:
--   Loads distinct sales manager names into the SalesManagers dimension.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_SalesManagers
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[SalesManagers]
    (
        SalesManagerKey,
        SalesManager,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.SalesManagersSequenceObject,
        src.SalesManager,
        @UserKey
    FROM
    (
        SELECT SalesManager
        FROM FileUpload.OriginallyLoadedData
        WHERE SalesManager IS NOT NULL
        GROUP BY SalesManager
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[SalesManagers] d
        WHERE d.SalesManager = src.SalesManager
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load SalesManagers',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_DimGender
-- Purpose:
--   Loads the small lookup dimension for Gender.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimGender
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimGender]
    (
        Gender,
        UserAuthorizationKey
    )
    SELECT
        src.Gender,
        @UserKey
    FROM
    (
        SELECT Gender
        FROM FileUpload.OriginallyLoadedData
        WHERE Gender IS NOT NULL
        GROUP BY Gender
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimGender] d
        WHERE d.Gender = src.Gender
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimGender',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_DimMaritalStatus
-- Purpose:
--   Loads the small lookup dimension for MaritalStatus.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimMaritalStatus
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimMaritalStatus]
    (
        MaritalStatus,
        UserAuthorizationKey
    )
    SELECT
        src.MaritalStatus,
        @UserKey
    FROM
    (
        SELECT MaritalStatus
        FROM FileUpload.OriginallyLoadedData
        WHERE MaritalStatus IS NOT NULL
        GROUP BY MaritalStatus
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimMaritalStatus] d
        WHERE d.MaritalStatus = src.MaritalStatus
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimMaritalStatus',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO
