/*
 *  createWorkflowStepsTable.sql
 *
 *  STATUS: REFERENCE / SCRATCH ONLY — DO NOT RUN IN PRODUCTION
 *
 *  This file documents the early exploratory work done to understand
 *  the normalization changes needed on the original Data schema tables.
 *
 *  The final implementation is split across these scripts (run in order):
 *    1. create_UDT.sql
 *    2. preserve_original_tables.sql
 *    3. create_tables.sql          <-- WorkflowSteps table is created here
 *    4. load_tables.sql
 *    5. view_draft.sql
 *
 *  PROBLEMS WITH THE ORIGINAL VERSION OF THIS FILE (now fixed):
 *
 *    1. It mutated the live Data.Country and Data.Customer tables directly
 *       (DROP COLUMN, ADD COLUMN), which is destructive and conflicts with
 *       the safer "preserve originals, build in Normalized schema" strategy
 *       used by the rest of the project.
 *
 *    2. It re-created the Process schema without a safety guard, so it
 *       would fail on a second run.
 *
 *    3. The WorkflowSteps table was missing meaningful columns required
 *       by the project spec (step name, status, dates, revision notes).
 *       The completed definition is now in create_tables.sql.
 *
 *    4. The backup SELECTs (Country_Backup, Customer_Backup) duplicate
 *       what preserve_original_tables.sql already does cleanly.
 *
 *  KEPT BELOW FOR REFERENCE:
 *    The original queries used to verify the exploratory Data-schema
 *    changes.  These are SELECT-only and safe to run for inspection.
 */


/*
 *  Read-only verification queries (safe to run at any time).
 *  These show the state of the original source tables.
 */

-- Check original country data and region breakdown
SELECT * FROM [Data].[Country];
SELECT * FROM [Data].[Customer];

-- Show distinct sales regions that needed to be extracted
SELECT DISTINCT SalesRegion
FROM [Data].[Country]
WHERE SalesRegion IS NOT NULL
ORDER BY SalesRegion;

/*Created by Prabjot, Edited by Frankie and verified by Brandon*/
