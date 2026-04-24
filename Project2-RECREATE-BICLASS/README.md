# Project 2 Notes — Recreate the BIClass Database Star Schema

## Overview

In this project, we recreated the BIClass database using a star schema design in SQL Server. The goal was to build a data warehouse structure with dimension and fact tables, implement ETL processes, and track workflow execution.

## Steps Performed

1. Created a new database named **G9_2**.
2. Created required schemas such as:

   * CH01-01-Dimension
   * CH01-01-Fact
   * Process
   * DbSecurity
   * Project2
3. Created all dimension tables and the fact table.
4. Implemented sequence objects for generating surrogate keys.
5. Built foreign key relationships between tables.
6. Created stored procedures for loading dimension and fact tables.
7. Developed a master stored procedure (**LoadStarSchemaData**) to run the full ETL process.
8. Implemented workflow tracking using:

   * Process.WorkflowSteps table
   * usp_TrackWorkFlow procedure
9. Tested the database using test queries and final verification scripts.
10. Connected the database to a Java application using JDBC.

## Challenges Faced

* Encountered errors using **NEXT VALUE FOR with DISTINCT**

  * Fixed by using GROUP BY instead of DISTINCT.
* Faced schema-related errors when creating procedures

  * Resolved by creating the required schema in the correct database.
* Issues with missing columns and outdated tables

  * Fixed by dropping and recreating tables properly.
* Workflow tracking initially showed only one user

  * Fixed by using different UserAuthorizationKey values.

## Results

* Successfully recreated the BIClass star schema.
* All dimension and fact tables were populated correctly.
* Workflow tracking procedures worked as expected.
* Master procedure executed without errors.
* Data integrity and relationships were verified.

## Conclusion

This project demonstrates the implementation of a complete data warehouse system, including schema design, ETL processing, workflow tracking, and application integration.

