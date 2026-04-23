# Project 2 - BIClass Star Schema Demo

## Overview
This project recreates the BIClass star schema in SQL Server database `G9_2`, adds workflow/security tracking, and provides a Java Swing UI to execute stored procedures and display results in JTable.

## Included files
- SQL setup scripts: `01_create_G9_2.sql` through `13_final_verification.sql`
- `DbConfig.java`
- `Project2DemoUI.java`
- `BIClass-Project 2 framework-20201029.bak`

## Requirements
- Java
- SQL Server running locally or in Docker
- Azure Data Studio or SSMS
- Microsoft SQL Server JDBC Driver

## Database setup
1. Restore the BIClass `.bak`
2. Run the SQL files in numeric order:
   - `01_create_G9_2.sql`
   - `02_copy_source_tables.sql`
   - ...
   - `13_final_verification.sql`

## Configure Java connection
Before running Java, edit `DbConfig.java` and update:
- SQL Server host
- port
- database name
- username
- password

## JDBC driver
Make sure the Microsoft SQL Server JDBC driver jar is on the classpath.

Example compile:
```powershell
javac -cp ".;C:\path\to\mssql-jdbc-12.6.1.jre11.jar" DbConfig.java Project2DemoUI.java
