-- =============================================
-- File: 08_create_workflow_procedures.sql
-- Purpose:
--   This script creates the stored procedures used to track workflow activity.
--
-- What this script does:
--   1. Creates Process.usp_TrackWorkFlow to log each ETL step.
--   2. Creates Process.usp_ShowWorkflowSteps to report the logged workflow steps.
--
-- Why this matters:
--   Project 2 requires documenting the work done by each stored procedure,
--   including the number of rows affected, the execution timing, and the
--   member responsible for the action.
-- =============================================

USE G9_2;
GO

-- =============================================
-- Procedure: Process.usp_TrackWorkFlow
-- Purpose:
--   Inserts one log row into Process.WorkflowSteps.
-- Parameters:
--   @WorkFlowStepDescription   - short description of the ETL step
--   @WorkFlowStepTableRowCount - number of rows affected by the step
--   @StartingDateTime          - optional start time for the step
--   @EndingDateTime            - optional end time for the step
--   @UserAuthorizationKey      - identifies the group member executing the step
-- =============================================
CREATE OR ALTER PROCEDURE Process.usp_TrackWorkFlow
    @WorkFlowStepDescription NVARCHAR(100),
    @WorkFlowStepTableRowCount INT,
    @StartingDateTime DATETIME2(7) = NULL,
    @EndingDateTime DATETIME2(7) = NULL,
    @UserAuthorizationKey INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Process.WorkflowSteps
    (
        WorkFlowStepDescription,
        WorkFlowStepTableRowCount,
        StartingDateTime,
        EndingDateTime,
        ClassTime,
        UserAuthorizationKey
    )
    VALUES
    (
        @WorkFlowStepDescription,
        @WorkFlowStepTableRowCount,
        ISNULL(@StartingDateTime, SYSDATETIME()),
        ISNULL(@EndingDateTime, SYSDATETIME()),
        '09:15',
        @UserAuthorizationKey
    );
END;
GO

-- =============================================
-- Procedure: Process.usp_ShowWorkflowSteps
-- Purpose:
--   Returns the workflow log joined with the user table so that the output
--   shows both step information and the person responsible.
-- =============================================
CREATE OR ALTER PROCEDURE Process.usp_ShowWorkflowSteps
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ws.WorkFlowStepKey,
        ws.WorkFlowStepDescription,
        ws.WorkFlowStepTableRowCount,
        ws.StartingDateTime,
        ws.EndingDateTime,
        DATEDIFF(MILLISECOND, ws.StartingDateTime, ws.EndingDateTime) AS ExecutionTimeMs,
        ws.ClassTime,
        ws.UserAuthorizationKey,
        ua.GroupMemberFirstName,
        ua.GroupMemberLastName,
        ua.GroupName
    FROM Process.WorkflowSteps ws
    INNER JOIN DbSecurity.UserAuthorization ua
        ON ws.UserAuthorizationKey = ua.UserAuthorizationKey
    ORDER BY ws.WorkFlowStepKey;
END;
GO

-- =============================================
-- Optional verification:
-- Uncomment the line below if you want to immediately see the workflow output.
-- =============================================
-- EXEC Process.usp_ShowWorkflowSteps;
-- GO
