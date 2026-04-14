# HW 7 — Chapter 8: Data Modification

**Course:** CS331 – Database Systems  
**Group:** EOS_grp_2  
**Author:** Kanwal Jit Singh  
**Database:** Northwinds2024Student  
**Date:** April 13, 2026  

---

## Project Overview

This project demonstrates SQL data modification techniques, including:

- INSERT  
- UPDATE  
- DELETE  
- TRANSACTIONS / controlled updates  

Each operation is applied to business-style scenarios using the `Northwinds2024Student` database.

---
## Loom / Video Overview 
https://www.loom.com/share/b9034a0185b34b168709d24ff8751c04

## Objectives

- Build 10 business propositions  
- Solve each using SQL queries  
- Modify records safely through staging tables  
- Keep data integrity in mind while modifying data  
- Create Excel reports using Power Query  

---

## Database Used

**Northwinds2024Student**

### Key Tables

| Table | Description |
|---|---|
| `Sales.Customers` | Customer records |
| `Sales.Orders` | Order headers |
| `Sales.OrderDetails` | Line-level order data |
| `HR.Employees` | Employee information |
| `Production.Products` | Product catalog |

---

## Propositions Summary

| # | Type | Description |
|---|---|---|
| 1 | INSERT (`SELECT INTO`) | Creates `dbo.KS_Orders` staging table from `Sales.Orders` |
| 2 | INSERT (`VALUES`) | Adds a new customer record to `dbo.KS_Customers` |
| 3 | INSERT (`SELECT` + `EXISTS`) | Loads customers who placed orders |
| 4 | UPDATE + OUTPUT | Replaces `NULL` customer regions with `<None>` |
| 5 | DELETE + OUTPUT | Removes orders before Aug 2020 and outputs deleted rows |
| 6 | DELETE (JOIN) | Deletes staging orders for Brazil customers |
| 7 | UPDATE (JOIN) | Syncs UK shipping values from customer location data |
| 8 | INSERT + IDENTITY | Creates and tests an audit log table |
| 9 | UPDATE (`TOP` + CTE) | Applies a controlled freight update to 10 rows |
| 10 | TRUNCATE + FK handling | Truncates parent/child tables safely with FK drop/re-add |

---

## Why These Queries Are Special

These queries are important because they:

- Modify realistic business data scenarios  
- Demonstrate safe modification with staging tables (`dbo.KS_*`)  
- Use validation checks after operations (`COUNT`, `TOP`, outputs)  
- Show controlled handling of related-table constraints (FK + truncate)  

---

## Excel Power Query Reports

Five reports were created using SQL and Excel:

1. Employee Revenue Contribution  
2. Monthly Revenue Trend  
3. Top Customers by Revenue  
4. Revenue by Country  
5. Customer Lifetime Value  

### Power Query Transformations Applied

- Renamed columns for readability  
- Sorted revenue fields descending  
- Formatted money/revenue columns  
- Prepared outputs for charting in Excel  

---

## Tools Used

| Tool | Purpose |
|---|---|
| Azure Data Studio / DBeaver | SQL notebook and query execution |
| Microsoft Excel | Data export and report visuals |
| Power Query | Data transformation |
| Python (`pyodbc`, `pandas`, `openpyxl`) | Optional automated export to Excel |
| GitHub | Submission/version control |

---

## NACE Competencies Developed

- **Technology** — SQL, Excel, Power Query  
- **Critical Thinking** — Data-based problem solving  
- **Communication** — Explaining technical workflows clearly  
- **Teamwork** — Coordinating individual parts into one group submission  
- **Professionalism** — Meeting assignment format and deadlines  

---

## Use of AI Tools

AI tools (for example, Claude / ChatGPT) were used to help understand how to correctly structure propositions, clarify SQL syntax, and improve documentation. All queries were reviewed and validated against the named database.

---

## Files Included

```text
HW7-Individual/
├── Individual_Group2_HW7_KanwalJitSingh.ipynb   # Main SQL notebook (10 propositions + Excel query section)
├── KS_Excel_5Queries.sql                         # 5 SQL queries for Excel/Power Query
├── KS_Excel_Report.py                            
├── README.md                                     
```

---

## Conclusion

This project demonstrates how SQL data modification techniques can be applied to practical scenarios while maintaining control and clarity. It also shows how query results can be transformed into useful business-style reports using Excel and Power Query.
