# Project 2.5 - Prestige Cars Normalized Database

## Group Information
- **Group Category:** EOS_grp_2  
- **Group Name:** EOS_grp_2  
- **Course:** CSCI-331  

---

# Prestige Cars Database Project

## Project Overview
This project focused on improving and normalizing the Prestige Cars database by reducing redundant data, improving relational integrity, creating lookup tables, and implementing database design improvements using SQL Server.

The project included:
- User Defined Types (UDTs)
- Schema and normalized table creation
- Constraints and relational integrity improvements
- Views and TVFs
- GitHub collaboration and tracking
- Final submission organization

The goal was to redesign the database into a normalized, scalable, and maintainable relational database structure.

---

# Group Members & Work Distribution

| Member | Assigned Responsibilities |
|---|---|
| Frankie Liang | Project planning, GitHub setup, workflow coordination, editing SQL queries to follow updated syntax |
| Prabhjot Kaur | Project planning, reminders, add/remove columns, schema/table creation, backup tables |
| Salvador Cardoso | User Defined Data Types (UDTs), create tables, constraints, assisted and helped everyone |
| Kanwal Jit Singh | UDTs, constraints |
| Simran Singh | Views/TVFs, indexes, PDM diagram |
| Brandon Cho | Presentation, video, Views/TVFs, indexes |
| Amrina Qayyum | Data anomalies, documentation, backup preparation |
| Shuai Wang | PDM diagram, documentation, anomaly correction |

---

# Main Files

| File | Description |
|---|---|
| `create_UDT.sql` | Creates reusable User Defined Types and required schemas |
| `create_tables.sql` | Creates normalized tables using the UDTs |
| `create_views_and_itvfs.sql` | Creates Views and Inline Table-Valued Functions |
| `createWorkflowStepsTable.sql` | Creates the `Process.WorkflowSteps` table |
| ERD/PDM Files | Show database design, keys, relationships, and cardinality |
| Tracking File | Shows group task progress and revision notes |

---

# Project Tasks Completed

- Created `create_UDT.sql`
- Created `create_tables.sql`
- Created `create_views_and_itvfs.sql`
- Created `createWorkflowStepsTable.sql`
- Created `Process.WorkflowSteps` table
- Created normalized lookup tables
- Improved relational integrity
- Replaced repeated text values with relational IDs
- Created Views and TVFs
- Added indexes
- Added constraints and reusable UDTs
- Identified and corrected data anomalies
- Maintained GitHub repository for version control

---

# UDT Work

The project uses reusable User Defined Types (UDTs) for:
- Keys and IDs
- Codes and names
- Address fields
- Money values
- Date/time values
- Boolean fields

Using UDTs improved:
- Consistency
- Reusability
- Maintainability
- Standardization across the database

---

# Normalized Tables

The normalized tables include:
- SalesRegion
- Country
- Customer
- Make
- Model
- Stock
- Sales
- SalesDetails
- Process.WorkflowSteps

The design separates data into logical subject areas, reduces redundancy, improves scalability, and strengthens relational integrity by replacing repeated text values with relational IDs and lookup tables.

---

# Database Improvements

## Normalization
- Reduced redundant data
- Improved scalability and consistency
- Implemented relational lookup tables
- Organized data into logical subject areas

## Data Integrity
- Added primary keys and foreign keys
- Added unique constraints
- Added default constraints
- Added check constraints
- Improved table relationships
- Enforced business rules and data consistency

## Documentation
- Maintained GitHub repository for version control
- Organized final submission materials

---

# Technologies Used

- Microsoft SQL Server
- VS Code
- GitHub
- SQL

---

# Final Deliverables

The repository contains:
- SQL scripts
- Documentation files
- Project tracking file
- Final submission materials

---

# Conclusion

The Prestige Cars database was successfully improved through normalization, relational database design enhancements, reusable User Defined Types (UDTs), constraints, Views/TVFs, indexing, documentation, and data quality improvements. The project demonstrates proper database development practices, improved relational integrity, and effective collaborative team workflow using SQL Server, GitHub, and SQL.
