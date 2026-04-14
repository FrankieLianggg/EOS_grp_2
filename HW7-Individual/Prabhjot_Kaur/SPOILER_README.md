# HW 7 — Chapter 8: Data Modification

**Course:** CS331 – Database Systems  
**Group:** EOS_grp_2  
**Author:** Prabhjot Kaur  
**Database:** Northwinds2024Student  
**Date:** April 13, 2026  

---

## Project Overview

This project demonstrates data modification techniques in SQL, including:

- INSERT  
- UPDATE  
- DELETE  
- TRANSACTIONS  

Each operation is applied to real-world business scenarios using the Northwinds2024Student database.

---

## Objectives

- Build 10 business propositions  
- Solve each using SQL queries  
- Modify real database records  
- Ensure data integrity using transactions  
- Create Excel reports using Power Query  

---

## Database Used

**Northwinds2024Student**

### Key Tables

| Table | Description |
|---|---|
| `Sales.Customer` | Customer records |
| `Sales.Order` | Order headers |
| `Sales.OrderDetail` | Line-level order data |
| `HumanResources.Employee` | Employee information |
| `Production.Product` | Product catalog |

---

## Propositions Summary

| # | Type | Description |
|---|---|---|
| 1 | INSERT | Adds a new customer into the system |
| 2 | INSERT + TRANSACTION | Creates a new employee and assigns an order |
| 3 | UPDATE | Promotes employees based on performance |
| 4 | UPDATE | Increases shipping cost for international orders |
| 5 | UPDATE | Syncs customer location with latest order |
| 6 | UPDATE | Applies discount to high-volume purchases |
| 7 | DELETE | Removes outdated records for discontinued products |
| 8 | DELETE | Deletes customers with no order history |
| 9 | TRANSACTION | Reassigns orders before removing an employee |
| 10 | TRANSACTION + ROLLBACK | Simulates discount impact without saving changes |

---

## Why These Queries Are Special

These queries are important because they:

- Modify real database records  
- Maintain data integrity using transactions  
- Reflect real-world business operations  
- Prevent issues like orphan records  

---

## Excel Power Query Reports

Five reports were created using SQL and Excel:

1. Employee Revenue Contribution  
2. Monthly Revenue Trend  
3. Top Customers by Revenue  
4. Revenue by Country  
5. Customer Lifetime Value  

### Power Query Transformations Applied

- Renamed columns for clarity  
- Sorted revenue values descending  
- Formatted currency fields  
- Created bar and line charts for visualization  

---

## Tools Used

| Tool | Purpose |
|---|---|
| DBeaver | SQL query execution |
| Microsoft Excel | Data visualization |
| Power Query | Data transformation |
| GitHub | Submission and version control |

---

## Presentation Video

Watch the full walkthrough here:  
▶️ [https://youtu.be/mX75gSSVr7c](https://youtu.be/mX75gSSVr7c)

Each group member explained their 10 propositions, executed queries live, and demonstrated results and reports.

---

## NACE Competencies Developed

- **Technology** — SQL, Excel, Power Query  
- **Critical Thinking** — Problem-solving using data  
- **Communication** — Explaining technical concepts  
- **Teamwork** — Collaborating with group members  
- **Professionalism** — Meeting deadlines and requirements  

---

## Use of AI Tools

AI tools such as ChatGPT were used to assist in structuring propositions, improve query understanding, and enhance documentation.

---

## Files Included

```
HW7/
├── notebook.ipynb       # SQL queries and explanations


---

## Conclusion

This project demonstrates how SQL data modification techniques are used to manage and maintain databases in real-world applications. It also shows how raw data can be transformed into meaningful insights using Excel and Power Query.

```
Data → Query → Modify → Analyze → Present
```
