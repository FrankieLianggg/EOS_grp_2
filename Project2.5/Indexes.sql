USE [PrestigeCars]
GO

-- using the PrestigeCars database


SET ANSI_PADDING ON
GO

-- keeps spaces and padding behavior consistent for varchar/nvarchar columns


/****** Object:  Index [IX_Country_SalesRegionId] ******/

-- this index helps joins between Country and SalesRegion tables

IF NOT EXISTS
(
    SELECT *

    -- checking if the index already exists

    FROM sys.indexes

    -- sys.indexes stores all indexes in the database

    WHERE name = N'IX_Country_SalesRegionId'

    -- looking for this specific index name
)

CREATE NONCLUSTERED INDEX [IX_Country_SalesRegionId]

-- creating a nonclustered index called IX_Country_SalesRegionId

ON [Normalized].[Country]

-- creating the index on the Country table

(
    [SalesRegionId] ASC

    -- sorting the index in ascending order using SalesRegionId
)

WITH
(
    PAD_INDEX = OFF,

    -- sql server will not add extra empty space in index pages

    STATISTICS_NORECOMPUTE = OFF,

    -- sql server can automatically update statistics

    SORT_IN_TEMPDB = OFF,

    -- sorting will not use tempdb

    DROP_EXISTING = OFF,

    -- existing index will not be dropped automatically

    ONLINE = OFF,

    -- index creation happens offline

    ALLOW_ROW_LOCKS = ON,

    -- sql server can lock individual rows

    ALLOW_PAGE_LOCKS = ON,

    -- sql server can lock data pages

    OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF

    -- optimization for sequential inserts is turned off
)

ON [PRIMARY]

-- storing the index on the primary filegroup

GO




/****** Object:  Index [IX_Make_CountryId] ******/

-- this index helps joins between Make and Country tables

IF NOT EXISTS
(
    SELECT *
    FROM sys.indexes

    -- checking if index already exists

    WHERE name = N'IX_Make_CountryId'
)

CREATE NONCLUSTERED INDEX [IX_Make_CountryId]

-- creating index called IX_Make_CountryId

ON [Normalized].[Make]

-- creating index on Make table

(
    [CountryId] ASC

    -- using CountryId column in ascending order
)

WITH
(
    PAD_INDEX = OFF,

    -- no extra padding added to index pages

    STATISTICS_NORECOMPUTE = OFF,

    -- statistics can update automatically

    SORT_IN_TEMPDB = OFF,

    -- tempdb will not be used for sorting

    DROP_EXISTING = OFF,

    -- existing index will stay

    ONLINE = OFF,

    -- index builds offline

    ALLOW_ROW_LOCKS = ON,

    -- row locking enabled

    ALLOW_PAGE_LOCKS = ON,

    -- page locking enabled

    OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF

    -- sequential key optimization disabled
)

ON [PRIMARY]

-- storing index on primary filegroup

GO




/****** Object:  Index [IX_Model_MakeId] ******/

-- this index helps joins between Model and Make tables

IF NOT EXISTS
(
    SELECT *
    FROM sys.indexes

    -- checking if this index already exists

    WHERE name = N'IX_Model_MakeId'
)

CREATE NONCLUSTERED INDEX [IX_Model_MakeId]

-- creating nonclustered index called IX_Model_MakeId

ON [Normalized].[Model]

-- creating index on Model table

(
    [MakeId] ASC

    -- indexing the MakeId column in ascending order
)

WITH
(
    PAD_INDEX = OFF,

    -- no extra page padding

    STATISTICS_NORECOMPUTE = OFF,

    -- sql server updates statistics automatically

    SORT_IN_TEMPDB = OFF,

    -- sorting will not use tempdb

    DROP_EXISTING = OFF,

    -- existing index will not be replaced

    ONLINE = OFF,

    -- index creation happens offline

    ALLOW_ROW_LOCKS = ON,

    -- allows row-level locking

    ALLOW_PAGE_LOCKS = ON,

    -- allows page-level locking

    OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF

    -- sequential insert optimization disabled
)

ON [PRIMARY]

-- storing the index on primary storage

GO

-- this query shows the indexes that exist in the Normalized schema

SELECT
    SC.name AS SchemaName,
    TB.name AS TableName,
    IX.name AS IndexName,
    IX.type_desc AS IndexType
FROM sys.indexes AS IX
INNER JOIN sys.tables AS TB
    ON IX.object_id = TB.object_id
INNER JOIN sys.schemas AS SC
    ON TB.schema_id = SC.schema_id
WHERE SC.name = N'Normalized'
  AND IX.name LIKE N'IX_%'
ORDER BY
    TB.name,
    IX.name;
GO