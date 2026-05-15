-- =============================================
-- File: 10_create_load_procedures_part2.sql
-- Purpose:
--   This script creates the second group of ETL load procedures.
--   These procedures populate the larger dimensions and the fact table.
--
-- Procedures included:
--   1. Project2.Load_DimCustomer
--   2. Project2.Load_DimTerritory
--   3. Project2.Load_DimProduct
--   4. Project2.Load_Data
--
-- Important:
--   The fact table procedure must run last because it depends on the
--   dimension tables already being loaded.
-- =============================================

USE G9_2;
GO

-- =============================================
-- Procedure: Project2.Load_DimCustomer
-- Purpose:
--   Loads the customer dimension from distinct customer names.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimCustomer
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimCustomer]
    (
        CustomerKey,
        CustomerName,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.DimCustomerSequenceObject,
        src.CustomerName,
        @UserKey
    FROM
    (
        SELECT CustomerName
        FROM FileUpload.OriginallyLoadedData
        GROUP BY CustomerName
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimCustomer] d
        WHERE d.CustomerName = src.CustomerName
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimCustomer',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_DimTerritory
-- Purpose:
--   Loads the territory dimension using the distinct combination of
--   region, country, and group from the source data.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimTerritory
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimTerritory]
    (
        TerritoryKey,
        TerritoryRegion,
        TerritoryCountry,
        TerritoryGroup,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.DimTerritorySequenceObject,
        src.TerritoryRegion,
        src.TerritoryCountry,
        src.TerritoryGroup,
        @UserKey
    FROM
    (
        SELECT TerritoryRegion, TerritoryCountry, TerritoryGroup
        FROM FileUpload.OriginallyLoadedData
        GROUP BY TerritoryRegion, TerritoryCountry, TerritoryGroup
    ) AS src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimTerritory] d
        WHERE d.TerritoryRegion = src.TerritoryRegion
          AND d.TerritoryCountry = src.TerritoryCountry
          AND d.TerritoryGroup = src.TerritoryGroup
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimTerritory',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_DimProduct
-- Purpose:
--   Loads products after product category and subcategory have already been loaded.
--   ProductSubcategoryKey is looked up by joining to DimProductSubcategory.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_DimProduct
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Dimension].[DimProduct]
    (
        ProductKey,
        ProductSubcategoryKey,
        ProductCode,
        ProductName,
        Color,
        ModelName,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.DimProductSequenceObject,
        ps.ProductSubcategoryKey,
        old.ProductCode,
        old.ProductName,
        old.Color,
        old.ModelName,
        @UserKey
    FROM FileUpload.OriginallyLoadedData old
    JOIN [CH01-01-Dimension].[DimProductSubcategory] ps
        ON ps.ProductSubcategory = old.ProductSubcategory
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Dimension].[DimProduct] d
        WHERE d.ProductName = old.ProductName
          AND ISNULL(d.ProductCode,'') = ISNULL(old.ProductCode,'')
    )
    GROUP BY
        ps.ProductSubcategoryKey,
        old.ProductCode,
        old.ProductName,
        old.Color,
        old.ModelName;

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load DimProduct',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO

-- =============================================
-- Procedure: Project2.Load_Data
-- Purpose:
--   Loads the fact table by joining the source table to all required dimensions.
--   This step converts business values into foreign keys for the star schema.
-- =============================================
CREATE OR ALTER PROCEDURE Project2.Load_Data
    @UserKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    INSERT INTO [CH01-01-Fact].[Data]
    (
        SalesKey,
        ProductKey,
        SalesManagerKey,
        MaritalStatus,
        Gender,
        OccupationKey,
        OrderDate,
        TerritoryKey,
        CustomerKey,
        ProductStandardCost,
        SalesAmount,
        OrderQuantity,
        UnitPrice,
        UserAuthorizationKey
    )
    SELECT
        NEXT VALUE FOR PkSequence.DataSequenceObject,
        dp.ProductKey,
        sm.SalesManagerKey,
        ms.MaritalStatus,
        dg.Gender,
        occ.OccupationKey,
        old.OrderDate,
        dt.TerritoryKey,
        dc.CustomerKey,
        old.ProductStandardCost,
        old.SalesAmount,
        old.OrderQuantity,
        old.UnitPrice,
        @UserKey
    FROM FileUpload.OriginallyLoadedData old
    JOIN [CH01-01-Dimension].[DimProduct] dp
        ON dp.ProductName = old.ProductName
       AND ISNULL(dp.ProductCode,'') = ISNULL(old.ProductCode,'')
    JOIN [CH01-01-Dimension].[SalesManagers] sm
        ON sm.SalesManager = old.SalesManager
    JOIN [CH01-01-Dimension].[DimOccupation] occ
        ON occ.Occupation = old.Occupation
    JOIN [CH01-01-Dimension].[DimTerritory] dt
        ON dt.TerritoryRegion = old.TerritoryRegion
       AND dt.TerritoryCountry = old.TerritoryCountry
       AND dt.TerritoryGroup = old.TerritoryGroup
    JOIN [CH01-01-Dimension].[DimCustomer] dc
        ON dc.CustomerName = old.CustomerName
    JOIN [CH01-01-Dimension].[DimGender] dg
        ON dg.Gender = old.Gender
    JOIN [CH01-01-Dimension].[DimMaritalStatus] ms
        ON ms.MaritalStatus = old.MaritalStatus
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM [CH01-01-Fact].[Data] f
        WHERE f.ProductKey = dp.ProductKey
          AND f.CustomerKey = dc.CustomerKey
          AND f.OrderDate = old.OrderDate
    );

    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Load Fact Data',
        @@ROWCOUNT,
        @Start,
        @End,
        @UserKey;
END;
GO
