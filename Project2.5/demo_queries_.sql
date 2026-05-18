/*
  demo_queries_.sql
  CSCI-331 Project 2.5 | KJS
*/

use [PrestigeCars]
go

set ansi_nulls on
go

set quoted_identifier on
go


/* ============================================================================
  1 — User-defined types (UDT)
  Our normalized database stores column types in the UserDefinedTypes schema.
    Each UDT is defined once and reused on many tables, like the Northwinds example
    from class.
   ============================================================================ */

select
    schema_name(schema_id) as UdtSchema,
    name                   as UdtName
from sys.types
where is_user_defined = 1
order by UdtSchema, UdtName
go


/* ============================================================================
  2 — UDTs on a real table (INFORMATION_SCHEMA)
   Same idea as the professor Utils/metadata scripts: DOMAIN_SCHEMA + DOMAIN_NAME
   show which UDT is on each column.
    On Normalized.Country, every column uses a UDT. For example CountryISO2 uses
    ISOAlpha2, and the table has CHECK constraints on the ISO columns.
   ============================================================================ */

select
    table_schema as SchemaName,
    table_name   as TableName,
    column_name  as ColumnName,
    domain_schema,
    domain_name,
    data_type,
    is_nullable
from information_schema.columns
where table_schema = N'Normalized'
  and table_name   = N'Country'
order by ordinal_position
go


/* ============================================================================
   STEP 3 — CHECK constraints 
   Example rule from class: CountryISO2 like two uppercase letters.

    CHECK constraints enforce business rules. Our Country table uses the same
    pattern as the class example: ISO2 and ISO3 format checks.
   ============================================================================ */

select
    object_schema_name(parent_object_id) as SchemaName,
    object_name(parent_object_id)       as TableName,
    name                                as CheckConstraintName,
    definition
from sys.check_constraints
where object_schema_name(parent_object_id) = N'Normalized'
  and object_name(parent_object_id)        = N'Country'
order by CheckConstraintName
go


/* ============================================================================
   STEP 4 — Process.WorkflowSteps (Project 2.5 required table)
   Process.WorkflowSteps tracks each major step in our group project.
   ============================================================================ */

select
    WorkflowStepId,
    StepName,
    StepOrder,
    StepStatus,
    AssignedTo,
    CompletedBy,
    StepNotes
from [Process].[WorkflowSteps]
order by StepOrder
go


/* ============================================================================
   STEP 5 — Views 
    We created views in schema Normalized instead of keeping duplicate report tables.
    This query lists them; then we sample vw_StockPrices.
   ============================================================================ */

select
    s.name as SchemaName,
    v.name as ViewName
from sys.views as v
inner join sys.schemas as s
    on v.schema_id = s.schema_id
where s.name = N'Normalized'
order by v.name
go

select top 10 *
from [Normalized].[vw_StockPrices]
go


/* ============================================================================
   STEP 6 — Inline table-valued function (ITVF)
   Class topic: parameterized query you call like a table.
    Subroutines.itvf_SalesByYear is an inline table-valued function. We pass a year
    and it returns the sales rows for that year.
   ============================================================================ */

select top 10 *
from [Subroutines].[itvf_SalesByYear](2018)
go


/* ============================================================================
   7 Row counts on normalized tables (verification)
   Same style as Final_Project2_5_PrestigeCars.sql Section 10.
      This confirms data loaded into our normalized tables.
   ============================================================================ */

select N'Normalized.SalesRegion' as TableName, count(*) as RowCount from [Normalized].[SalesRegion]
union all select N'Normalized.Country',      count(*) from [Normalized].[Country]
union all select N'Normalized.Customer',     count(*) from [Normalized].[Customer]
union all select N'Normalized.Make',         count(*) from [Normalized].[Make]
union all select N'Normalized.Model',        count(*) from [Normalized].[Model]
union all select N'Normalized.Stock',        count(*) from [Normalized].[Stock]
union all select N'Normalized.Sales',        count(*) from [Normalized].[Sales]
union all select N'Normalized.SalesDetails', count(*) from [Normalized].[SalesDetails]
union all select N'Process.WorkflowSteps',   count(*) from [Process].[WorkflowSteps]
order by TableName
go
