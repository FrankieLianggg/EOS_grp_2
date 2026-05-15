# Architecture

This project uses a layered design:

- Config Layer: database configuration
- Connection Layer: connection creation
- Core Layer: query/update/transaction execution
- DAO Layer: database access operations
- Factory Layer: central DAO creation
- Model Layer: Java entity classes
- UI Layer: Swing demonstration interface

Data Flow:
UI -> DAO -> Core -> JDBC -> SQL Server
