-- =============================================
-- File: 12_test_queries.sql
-- Purpose:
--   This script tests the ETL procedures and verifies that data has loaded.
--
-- What this script does:
--   1. Runs the master load procedure.
--   2. Displays row counts for all tables.
--   3. Displays the workflow steps.
--   4. Shows contribution totals grouped by member.
-- =============================================

USE G9_2;
GO

-------------------------------------------------
-- Run the full ETL process using one user key.
-------------------------------------------------
EXEC Project2.LoadStarSchemaData @GroupMemberUserAuthorizationKey = 1;
GO

-------------------------------------------------
-- Check table row counts after the load finishes.
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
-- Show detailed workflow steps recorded by usp_TrackWorkFlow.
-------------------------------------------------
EXEC Process.usp_ShowWorkflowSteps;
GO

-------------------------------------------------
-- Summarize how many procedures and how much execution time are
-- associated with each member in UserAuthorization.
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
