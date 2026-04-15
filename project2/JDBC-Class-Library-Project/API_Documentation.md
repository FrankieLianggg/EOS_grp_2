# API Documentation

## ConnectionFactory
Creates JDBC connections using `DbConfig`.

## QueryExecutor
Runs SELECT statements and returns rows as `List<Map<String,Object>>`.

## UpdateExecutor
Runs INSERT, UPDATE, and DELETE statements.

## TransactionManager
Wraps manual commit and rollback operations.

## DaoFactory
Creates DAO objects.
