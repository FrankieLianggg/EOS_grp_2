-- =============================================
-- 04_create_security_and_workflow.sql
-- Create UserAuthorization and WorkflowSteps tables
-- =============================================

USE G9_2; -- runs the security and workflow setup in the correct database
GO

-- =============================================
-- Drop tables if they exist (order matters)
-- =============================================

IF OBJECT_ID('Process.WorkflowSteps', 'U') IS NOT NULL
    DROP TABLE Process.WorkflowSteps; -- drops the child table first so the foreign key does not block the reset
GO

IF OBJECT_ID('DbSecurity.UserAuthorization', 'U') IS NOT NULL
    DROP TABLE DbSecurity.UserAuthorization;
GO

-- =============================================
-- Create UserAuthorization table
-- =============================================

CREATE TABLE DbSecurity.UserAuthorization -- stores each group member who can be linked to workflow activity
(
    UserAuthorizationKey INT NOT NULL
        CONSTRAINT PK_UserAuthorization PRIMARY KEY
        CONSTRAINT DF_UserAuthorizationKey 
            DEFAULT (NEXT VALUE FOR PkSequence.UserAuthorizationSequenceObject), -- assigns a sequence-generated key instead of an identity column

    ClassTime NCHAR(5) NULL
        CONSTRAINT DF_UserAuthorization_ClassTime DEFAULT ('09:15'),

    IndividualProject NVARCHAR(60) NULL
        CONSTRAINT DF_UserAuthorization_Project 
            DEFAULT ('PROJECT 2 RECREATE THE BICLASS DATABASE STAR SCHEMA'),

    GroupMemberLastName NVARCHAR(35) NOT NULL,
    GroupMemberFirstName NVARCHAR(25) NOT NULL,
    GroupName NVARCHAR(20) NOT NULL,

    DateAdded DATETIME2(7) NULL
        CONSTRAINT DF_UserAuthorization_DateAdded DEFAULT (SYSDATETIME()),

    DateOfLastUpdate DATETIME2(7) NULL
        CONSTRAINT DF_UserAuthorization_DateOfLastUpdate DEFAULT (SYSDATETIME())
);
GO

-- =============================================
-- Create WorkflowSteps table
-- =============================================

CREATE TABLE Process.WorkflowSteps -- records each ETL step, row count, and execution timing
(
    WorkFlowStepKey INT NOT NULL
        CONSTRAINT PK_WorkflowSteps PRIMARY KEY
        CONSTRAINT DF_WorkFlowStepKey 
            DEFAULT (NEXT VALUE FOR PkSequence.WorkflowStepsSequenceObject),

    WorkFlowStepDescription NVARCHAR(100) NOT NULL,

    WorkFlowStepTableRowCount INT NULL
        CONSTRAINT DF_Workflow_RowCount DEFAULT (0),

    StartingDateTime DATETIME2(7) NULL
        CONSTRAINT DF_Workflow_Start DEFAULT (SYSDATETIME()),

    EndingDateTime DATETIME2(7) NULL
        CONSTRAINT DF_Workflow_End DEFAULT (SYSDATETIME()),

    ClassTime CHAR(5) NULL
        CONSTRAINT DF_Workflow_ClassTime DEFAULT ('09:15'),

    UserAuthorizationKey INT NOT NULL,

    DateAdded DATETIME2(7) NULL
        CONSTRAINT DF_Workflow_DateAdded DEFAULT (SYSDATETIME()),

    DateOfLastUpdate DATETIME2(7) NULL
        CONSTRAINT DF_Workflow_DateOfLastUpdate DEFAULT (SYSDATETIME()),

    CONSTRAINT FK_WorkflowSteps_UserAuthorization
        FOREIGN KEY (UserAuthorizationKey)
        REFERENCES DbSecurity.UserAuthorization(UserAuthorizationKey) -- links each workflow row back to the person responsible
);
GO

-- =============================================
-- Reset and insert group members
-- =============================================

DELETE FROM Process.WorkflowSteps;
GO

DELETE FROM DbSecurity.UserAuthorization;
GO

ALTER SEQUENCE PkSequence.UserAuthorizationSequenceObject RESTART WITH 1; -- resets keys so the sample member list starts from 1 again
GO

ALTER SEQUENCE PkSequence.WorkflowStepsSequenceObject RESTART WITH 1;
GO

INSERT INTO DbSecurity.UserAuthorization
(
    GroupMemberLastName,
    GroupMemberFirstName,
    GroupName
)
VALUES
('Liang', 'Frankie', 'EOS_grp_2'),
('Singh', 'Kanwaljit', 'EOS_grp_2'),
('Cho', 'Brandon', 'EOS_grp_2'),
('Qayyum', 'Amrina', 'EOS_grp_2'),
('Kaur', 'Prabhjot', 'EOS_grp_2'),
('Wang', 'Shuai', 'EOS_grp_2'),
('Singh', 'Simran', 'EOS_grp_2'),
('Cardoso', 'Salvador', 'EOS_grp_2');
GO

-- =============================================
-- Verification
-- =============================================

SELECT *
FROM DbSecurity.UserAuthorization
ORDER BY UserAuthorizationKey; -- shows the final inserted team members in key order
GO