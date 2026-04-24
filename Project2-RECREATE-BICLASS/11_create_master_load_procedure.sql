-- =============================================
-- File: 11_create_master_load_procedure.sql
-- Purpose:
--   This script creates the master ETL procedure that reloads the star schema.
--
-- What this script does:
--   1. Clears old fact and dimension data.
--   2. Resets sequence objects so surrogate keys start from 1 again.
--   3. Executes all dimension load procedures in dependency order.
--   4. Executes the fact load procedure last.
--   5. Logs the total run as one workflow step.
--
-- Why order matters:
--   The fact table depends on all dimensions already existing.
--   The product table depends on category and subcategory being loaded first.
-- =============================================

USE G9_2;
GO

CREATE OR ALTER PROCEDURE Project2.LoadStarSchemaData
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Start DATETIME2 = SYSDATETIME();

    -------------------------------------------------
    -- Step 1: Clear existing data to support a safe rerun.
    -------------------------------------------------
    DELETE FROM [CH01-01-Fact].[Data];

    DELETE FROM [CH01-01-Dimension].[DimProduct];
    DELETE FROM [CH01-01-Dimension].[DimCustomer];
    DELETE FROM [CH01-01-Dimension].[DimTerritory];
    DELETE FROM [CH01-01-Dimension].[DimOccupation];
    DELETE FROM [CH01-01-Dimension].[DimMaritalStatus];
    DELETE FROM [CH01-01-Dimension].[DimGender];
    DELETE FROM [CH01-01-Dimension].[SalesManagers];
    DELETE FROM [CH01-01-Dimension].[DimProductSubcategory];
    DELETE FROM [CH01-01-Dimension].[DimProductCategory];

    -------------------------------------------------
    -- Step 2: Reset sequence objects so keys start again from 1.
    -------------------------------------------------
    ALTER SEQUENCE PkSequence.DimProductCategorySequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductSubcategorySequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.SalesManagersSequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimCustomerSequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimProductSequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimTerritorySequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DimOccupationSequenceObject RESTART WITH 1;
    ALTER SEQUENCE PkSequence.DataSequenceObject RESTART WITH 1;

    -------------------------------------------------
    -- Step 3: Load dimensions in the correct dependency order.
    -------------------------------------------------
    EXEC Project2.Load_DimProductCategory @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_DimProductSubcategory @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_SalesManagers @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_DimGender @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_DimMaritalStatus @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_DimCustomer @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_DimTerritory @GroupMemberUserAuthorizationKey;
    EXEC Project2.Load_DimProduct @GroupMemberUserAuthorizationKey;

    -------------------------------------------------
    -- Step 4: Load the fact table after all dimensions are ready.
    -------------------------------------------------
    EXEC Project2.Load_Data @GroupMemberUserAuthorizationKey;

    -------------------------------------------------
    -- Step 5: Log the entire master load procedure execution.
    -------------------------------------------------
    DECLARE @End DATETIME2 = SYSDATETIME();
    EXEC Process.usp_TrackWorkFlow
        'Master Load Procedure',
        0,
        @Start,
        @End,
        @GroupMemberUserAuthorizationKey;
END;
GO
