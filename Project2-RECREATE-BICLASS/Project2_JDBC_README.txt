Project 2 JDBC Demo
===================

Files:
- DbConfig.java
- Project2DemoUI.java

What it does:
- Connects to SQL Server using JDBC
- Executes Project2.LoadStarSchemaData(?), passing a UserAuthorizationKey
- Executes Process.usp_ShowWorkflowSteps
- Displays the workflow result set in a JTable

Requirements:
1. Java JDK 8+ installed
2. Microsoft SQL Server JDBC driver JAR downloaded
   Example file name:
   mssql-jdbc-12.8.1.jre11.jar

3. SQL Server reachable with the values in DbConfig.java

How to compile (Windows cmd example):
-------------------------------------
javac -cp .;mssql-jdbc-12.8.1.jre11.jar DbConfig.java Project2DemoUI.java

How to run (Windows cmd example):
---------------------------------
java -cp .;mssql-jdbc-12.8.1.jre11.jar Project2DemoUI

How to use:
-----------
1. Start the program.
2. Enter a valid UserAuthorizationKey.
3. Click "Run Project2.LoadStarSchemaData".
4. After it finishes, click "Run Process.usp_ShowWorkflowSteps".
5. The workflow rows will appear in the JTable.

Notes:
------
- If your professor insists on the procedure name Project2.LoadStarSchema,
  create a wrapper procedure in SQL Server that calls Project2.LoadStarSchemaData.
- If the database password differs, change it in DbConfig.java.
