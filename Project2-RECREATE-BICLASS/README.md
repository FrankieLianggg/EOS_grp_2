# 📘 Project 2 — RECREATE THE BICLASS DATABASE STAR SCHEMA  

**Group Category:** EOS_grp  
**Group Name:** EOS_grp_2  

---

## 📖 Project Overview
This project recreates the **BIClass database star schema** using SQL Server. The goal is to design a data warehouse structure with dimension and fact tables, implement ETL processes using stored procedures, and track workflow execution.

The project also includes a **Java JDBC application** to demonstrate database connectivity and execution of stored procedures.

---

## 🎯 Objectives
- Recreate the BIClass star schema  
- Build dimension and fact tables  
- Implement ETL load procedures  
- Track workflow execution  
- Validate data integrity  
- Demonstrate execution using Java (JDBC)  

---

## 🗂️ Project Structure

### 🔹 SQL Files
- `01_create_G9_2.sql` — Create database and schemas  
- `02_copy_source_tables.sql` — Copy source data  
- `03_create_sequences.sql` — Create sequence objects  
- `04_create_security_and_workflow.sql` — Security + workflow tables  
- `05_create_core_tables_from_BIClass.sql` — Core dimension tables  
- `06_create_new_product_dimensions.sql` — Product hierarchy  
- `07_create_foreign_keys.sql` — Relationships (FK constraints)  
- `08_create_workflow_procedures.sql` — Workflow procedures  
- `09_create_load_procedures_part1.sql` — Dimension loads (Part 1)  
- `10_create_load_procedures_part2.sql` — Dimension + Fact loads (Part 2)  
- `11_create_master_load_procedure.sql` — Master ETL procedure  
- `12_test_queries.sql` — Step-by-step testing  
- `13_final_verification.sql` — Final validation  

---

### 🔹 Java Files
- `DbConfig.java` — Database connection setup  
- `Project2DemoUI.java` — User interface for execution  

---

### 🔹 Other Files
- BIClass database backup  
- Supporting project files  

---

## ⚙️ Technologies Used
- SQL Server  
- T-SQL (Stored Procedures, Sequences, Constraints)  
- Java (JDBC)  
- DBeaver / SQL Server Management Studio  

---

## 🚀 How to Run the Project

### 1️⃣ Run SQL Scripts in Order
