USE G9_2;
GO

-- =============================================
-- Author:      Brandon Cho and Salvador Cardoso
-- Procedure:   [Project2].[DropForeignKeysFromStarSchemaData]
-- Create date: 2026-04-15
-- Description: Drops the foreign keys that would block truncation and reload of the star schema tables.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[DropForeignKeysFromStarSchemaData]
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimProduct'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimProduct];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_SalesManagers'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_SalesManagers];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimMaritalStatus'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimMaritalStatus];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimGender'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimGender];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimOccupation'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimOccupation];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimOrderDate'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimOrderDate];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimTerritory'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimTerritory];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimCustomer'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data] DROP CONSTRAINT [FK_Data_DimCustomer];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_DimProduct_DimProductSubcategory'
          AND parent_object_id = OBJECT_ID('[CH01-01-Dimension].[DimProduct]')
    )
        ALTER TABLE [CH01-01-Dimension].[DimProduct] DROP CONSTRAINT [FK_DimProduct_DimProductSubcategory];

    IF EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_DimProductSubcategory_DimProductCategory'
          AND parent_object_id = OBJECT_ID('[CH01-01-Dimension].[DimProductSubcategory]')
    )
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory] DROP CONSTRAINT [FK_DimProductSubcategory_DimProductCategory];
END;
GO

-- =============================================
-- Author:      Brandon Cho and Salvador Cardoso
-- Procedure:   [Project2].[AddForeignKeysToStarSchemaData]
-- Create date: 2026-04-15
-- Description: Recreates the foreign keys after the star schema has been reloaded.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[AddForeignKeysToStarSchemaData]
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_DimProductSubcategory_DimProductCategory'
          AND parent_object_id = OBJECT_ID('[CH01-01-Dimension].[DimProductSubcategory]')
    )
        ALTER TABLE [CH01-01-Dimension].[DimProductSubcategory]
        ADD CONSTRAINT [FK_DimProductSubcategory_DimProductCategory]
        FOREIGN KEY (ProductCategoryKey)
        REFERENCES [CH01-01-Dimension].[DimProductCategory](ProductCategoryKey);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_DimProduct_DimProductSubcategory'
          AND parent_object_id = OBJECT_ID('[CH01-01-Dimension].[DimProduct]')
    )
        ALTER TABLE [CH01-01-Dimension].[DimProduct]
        ADD CONSTRAINT [FK_DimProduct_DimProductSubcategory]
        FOREIGN KEY (ProductSubcategoryKey)
        REFERENCES [CH01-01-Dimension].[DimProductSubcategory](ProductSubcategoryKey);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimProduct'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimProduct]
        FOREIGN KEY (ProductKey)
        REFERENCES [CH01-01-Dimension].[DimProduct](ProductKey);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_SalesManagers'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_SalesManagers]
        FOREIGN KEY (SalesManagerKey)
        REFERENCES [CH01-01-Dimension].[SalesManagers](SalesManagerKey);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimMaritalStatus'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimMaritalStatus]
        FOREIGN KEY (MaritalStatus)
        REFERENCES [CH01-01-Dimension].[DimMaritalStatus](MaritalStatus);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimGender'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimGender]
        FOREIGN KEY (Gender)
        REFERENCES [CH01-01-Dimension].[DimGender](Gender);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimOccupation'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimOccupation]
        FOREIGN KEY (OccupationKey)
        REFERENCES [CH01-01-Dimension].[DimOccupation](OccupationKey);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimOrderDate'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimOrderDate]
        FOREIGN KEY (OrderDate)
        REFERENCES [CH01-01-Dimension].[DimOrderDate](OrderDate);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimTerritory'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimTerritory]
        FOREIGN KEY (TerritoryKey)
        REFERENCES [CH01-01-Dimension].[DimTerritory](TerritoryKey);

    IF NOT EXISTS (
        SELECT 1
        FROM sys.foreign_keys
        WHERE name = 'FK_Data_DimCustomer'
          AND parent_object_id = OBJECT_ID('[CH01-01-Fact].[Data]')
    )
        ALTER TABLE [CH01-01-Fact].[Data]
        ADD CONSTRAINT [FK_Data_DimCustomer]
        FOREIGN KEY (CustomerKey)
        REFERENCES [CH01-01-Dimension].[DimCustomer](CustomerKey);
END;
GO

-- =============================================
-- Author:      Brandon Cho and Salvador Cardoso
-- Procedure:   [Project2].[ShowTableStatusRowCount]
-- Create date: 2026-04-18
-- Description: Captures row counts for the star schema tables and logs the summary as a workflow step.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[ShowTableStatusRowCount]
    @GroupMemberUserAuthorizationKey INT,
    @TableStatus NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTime DATETIME2(7) = SYSDATETIME();
    DECLARE @EndTime DATETIME2(7);
    DECLARE @RowCount INT;

    SELECT @RowCount = ISNULL(SUM(p.rows), 0)
    FROM sys.tables t
    JOIN sys.schemas s
      ON t.schema_id = s.schema_id
    JOIN sys.partitions p
      ON t.object_id = p.object_id
    WHERE p.index_id IN (0,1)
      AND s.name IN ('CH01-01-Dimension', 'CH01-01-Fact');

    SET @EndTime = SYSDATETIME();

    EXEC Process.usp_TrackWorkFlow
         @WorkFlowStepDescription = @TableStatus,
         @WorkFlowStepTableRowCount = @RowCount,
         @StartingDateTime = @StartTime,
         @EndingDateTime = @EndTime,
         @UserAuthorizationKey = @GroupMemberUserAuthorizationKey;

    SELECT
        s.name AS SchemaName,
        t.name AS TableName,
        SUM(p.rows) AS TotalRows
    FROM sys.tables t
    JOIN sys.schemas s
      ON t.schema_id = s.schema_id
    JOIN sys.partitions p
      ON t.object_id = p.object_id
    WHERE p.index_id IN (0,1)
      AND s.name IN ('CH01-01-Dimension', 'CH01-01-Fact')
    GROUP BY s.name, t.name
    ORDER BY s.name, t.name;
END;
GO

-- =============================================
-- Author:      Brandon Cho and Salvador Cardoso
-- Procedure:   [Project2].[TruncateStarSchemaData]
-- Create date: 2026-04-18
-- Description: Truncates the star schema tables and restarts the sequence objects used by the loaded tables.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[TruncateStarSchemaData]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE [CH01-01-Fact].[Data];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProduct];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProductSubcategory];
    TRUNCATE TABLE [CH01-01-Dimension].[DimProductCategory];
    TRUNCATE TABLE [CH01-01-Dimension].[SalesManagers];
    TRUNCATE TABLE [CH01-01-Dimension].[DimCustomer];
    TRUNCATE TABLE [CH01-01-Dimension].[DimTerritory];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOccupation];
    TRUNCATE TABLE [CH01-01-Dimension].[DimMaritalStatus];
    TRUNCATE TABLE [CH01-01-Dimension].[DimGender];
    TRUNCATE TABLE [CH01-01-Dimension].[DimOrderDate];

    ALTER SEQUENCE [PkSequence].[DataSequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[DimProductSequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[DimProductSubcategorySequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[DimProductCategorySequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[SalesManagersSequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[DimCustomerSequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[DimTerritorySequenceObject] RESTART WITH 1;
    ALTER SEQUENCE [PkSequence].[DimOccupationSequenceObject] RESTART WITH 1;
END;
GO

-- =============================================
-- Author:      Brandon Cho and Salvador Cardoso
-- Procedure:   [Project2].[LoadStarSchemaData]
-- Create date: 2026-04-19
-- Description: Orchestrates the complete reload of the BIClass star schema from the copied FileUpload source data.
-- =============================================
CREATE OR ALTER PROCEDURE [Project2].[LoadStarSchemaData]
    @GroupMemberUserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BrandonUserAuthorizationKey INT;
    DECLARE @SalvadorUserAuthorizationKey INT;

    SELECT TOP (1)
        @BrandonUserAuthorizationKey = UserAuthorizationKey
    FROM DbSecurity.UserAuthorization
    WHERE GroupMemberFirstName = 'Brandon'
      AND GroupMemberLastName = 'Cho';

    SELECT TOP (1)
        @SalvadorUserAuthorizationKey = UserAuthorizationKey
    FROM DbSecurity.UserAuthorization
    WHERE GroupMemberFirstName = 'Salvador'
      AND GroupMemberLastName = 'Cardoso';

    IF @BrandonUserAuthorizationKey IS NULL
        THROW 50001, 'Brandon Cho was not found in DbSecurity.UserAuthorization.', 1;

    IF @SalvadorUserAuthorizationKey IS NULL
        THROW 50002, 'Salvador Cardoso was not found in DbSecurity.UserAuthorization.', 1;

    EXEC Project2.DropForeignKeysFromStarSchemaData;

    EXEC Project2.ShowTableStatusRowCount
         @GroupMemberUserAuthorizationKey = @SalvadorUserAuthorizationKey,
         @TableStatus = N'Pre-truncate of tables';

    EXEC Project2.TruncateStarSchemaData;

    EXEC Project2.Load_DimProductCategory    @BrandonUserAuthorizationKey;
    EXEC Project2.Load_DimProductSubcategory @BrandonUserAuthorizationKey;
    EXEC Project2.Load_SalesManagers         @BrandonUserAuthorizationKey;
    EXEC Project2.Load_DimGender             @BrandonUserAuthorizationKey;
    EXEC Project2.Load_DimMaritalStatus      @BrandonUserAuthorizationKey;

    EXEC Project2.Load_DimOccupation         @SalvadorUserAuthorizationKey;
    EXEC Project2.Load_DimOrderDate          @SalvadorUserAuthorizationKey;
    EXEC Project2.Load_DimCustomer           @SalvadorUserAuthorizationKey;
    EXEC Project2.Load_DimTerritory          @SalvadorUserAuthorizationKey;
    EXEC Project2.Load_DimProduct            @SalvadorUserAuthorizationKey;
    EXEC Project2.Load_Data                  @SalvadorUserAuthorizationKey;

    EXEC Project2.ShowTableStatusRowCount
         @GroupMemberUserAuthorizationKey = @SalvadorUserAuthorizationKey,
         @TableStatus = N'Row count after loading the star schema';

    EXEC Project2.AddForeignKeysToStarSchemaData;
END;
GO