-- =============================================
-- File: 13_final_verification.sql
-- Purpose:
--   This script is the final verification report for the completed project.
--
-- What this script checks:
--   1. Runs the master load procedure one more time.
--   2. Confirms the fact table row count.
--   3. Displays row counts for all tables.
--   4. Displays foreign keys to verify relationships.
--   5. Shows sample fact data.
--   6. Shows workflow step output.
--   7. Summarizes member contribution and total execution time.
-- =============================================

USE G9_2;
GO

-------------------------------------------------
-- Run the full master procedure so verification is based on a fresh load.
-------------------------------------------------
EXEC Project2.LoadStarSchemaData @GroupMemberUserAuthorizationKey = 1;
GO

-------------------------------------------------
-- Confirm the total number of rows in the fact table.
-------------------------------------------------
SELECT 
    COUNT(*) AS FactRowCount
FROM [CH01-01-Fact].[Data];
GO

-------------------------------------------------
-- Display row counts for every table in the database.
-------------------------------------------------
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
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
GO

-------------------------------------------------
-- Verify all foreign keys and relationships in the star schema.
-------------------------------------------------
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS ChildSchema,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ParentSchema,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable
FROM sys.foreign_keys fk
ORDER BY ChildSchema, ChildTable, ForeignKeyName;
GO

-------------------------------------------------
-- Show a small sample of the fact table for manual inspection.
-------------------------------------------------
SELECT TOP 10 *
FROM [CH01-01-Fact].[Data];
GO

-------------------------------------------------
-- Show the workflow steps recorded during the load.
-------------------------------------------------
EXEC Process.usp_ShowWorkflowSteps;
GO

-------------------------------------------------
-- Show work contribution grouped by member.
-------------------------------------------------
SELECT
    ua.GroupMemberFirstName,
    ua.GroupMemberLastName,
    COUNT(*) AS NumberOfProceduresWorkedOn,
    SUM(DATEDIFF(MILLISECOND, ws.StartingDateTime, ws.EndingDateTime)) AS TotalExecutionTimeMs
FROM Process.WorkflowSteps ws
JOIN DbSecurity.UserAuthorization ua
    ON ws.UserAuthorizationKey = ua.UserAuthorizationKey
GROUP BY
    ua.GroupMemberFirstName,
    ua.GroupMemberLastName
ORDER BY
    ua.GroupMemberLastName,
    ua.GroupMemberFirstName;
GO

-------------------------------------------------
-- Show the grand total execution time for the ETL run.
-------------------------------------------------
SELECT 
    SUM(DATEDIFF(MILLISECOND, StartingDateTime, EndingDateTime)) AS TotalExecutionTimeMs
FROM Process.WorkflowSteps;
GO
