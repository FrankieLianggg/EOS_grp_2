use [PrestigeCars];
Go

/*
 *  Make a schema to test the changes, before moving everything to the original schema.
 */
if schema_id(N'Normalized') is null
  Begin
    exec(N'
      create schema [Normalized];
    ');
  End;
Go

/*
 *  Make a copy of each of the original tables.
 */

if object_id(N'Normalized._Original_Data_Country', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_Country]
    from
      [Data].[Country];
  End;
Go

if object_id(N'Normalized._Original_Data_Customer', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_Customer]
    from
      [Data].[Customer];
  End;
Go

if object_id(N'Normalized._Original_Data_Make', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_Make]
    from
      [Data].[Make];
  End;
Go

if object_id(N'Normalized._Original_Data_Model', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_Model]
    from
      [Data].[Model];
  End;
Go

IF OBJECT_ID(N'Normalized._Original_Data_Sales', N'U') IS NULL
BEGIN
    SELECT
        *
    INTO
        [Normalized].[_Original_Data_Sales]
    FROM
        [Data].[Sales];
END;
GO

if object_id(N'Normalized._Original_Data_SalesDetails', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_SalesDetails]
    from
      [Data].[SalesDetails];
  End;
Go

if object_id(N'Normalized._Original_Data_Stock', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_Stock]
    from
      [Data].[Stock];
  End;
Go

if object_id(N'Normalized._Original_Data_SalesByCountry', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_SalesByCountry]
    from
      [Data].[SalesByCountry];
  End;
Go

if object_id(N'Normalized._Original_Data_PivotTable', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Data_PivotTable]
    from
      [Data].[PivotTable];
  End;
Go

if object_id(N'Normalized._Original_DataTransfer_Sales2015', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_DataTransfer_Sales2015]
    from
      [DataTransfer].[Sales2015];
  End;
Go

if object_id(N'Normalized._Original_DataTransfer_Sales2016', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_DataTransfer_Sales2016]
    from
      [DataTransfer].[Sales2016];
  End;
Go

if object_id(N'Normalized._Original_DataTransfer_Sales2017', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_DataTransfer_Sales2017]
    from
      [DataTransfer].[Sales2017];
  End;
Go

if object_id(N'Normalized._Original_DataTransfer_Sales2018', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_DataTransfer_Sales2018]
    from
      [DataTransfer].[Sales2018];
  End;
Go

if object_id(N'Normalized._Original_Output_StockPrices', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Output_StockPrices]
    from
      [Output].[StockPrices];
  End;
Go

if object_id(N'Normalized._Original_Reference_Budget', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_Budget]
    from
      [Reference].[Budget];
  End;
Go

if object_id(N'Normalized._Original_Reference_Forex', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_Forex]
    from
      [Reference].[Forex];
  End;
Go

if object_id(N'Normalized._Original_Reference_MarketingCategories', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_MarketingCategories]
    from
      [Reference].[MarketingCategories];
  End;
Go

if object_id(N'Normalized._Original_Reference_MarketingInformation', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_MarketingInformation]
    from
      [Reference].[MarketingInformation];
  End;
Go

if object_id(N'Normalized._Original_Reference_SalesBudgets', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_SalesBudgets]
    from
      [Reference].[SalesBudgets];
  End;
Go

if object_id(N'Normalized._Original_Reference_SalesCategory', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_SalesCategory]
    from
      [Reference].[SalesCategory];
  End;
Go

if object_id(N'Normalized._Original_Reference_Staff', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_Staff]
    from
      [Reference].[Staff];
  End;
Go

if object_id(N'Normalized._Original_Reference_StaffHierarchy', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_StaffHierarchy]
    from
      [Reference].[StaffHierarchy];
  End;
Go

if object_id(N'Normalized._Original_Reference_YearlySales', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_Reference_YearlySales]
    from
      [Reference].[YearlySales];
  End;
Go

if object_id(N'Normalized._Original_SourceData_SalesInPounds', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_SourceData_SalesInPounds]
    from
      [SourceData].[SalesInPounds];
  End;
Go

if object_id(N'Normalized._Original_SourceData_SalesText', N'u') is null
  Begin
    select
      *
    into
      [Normalized].[_Original_SourceData_SalesText]
    from
      [SourceData].[SalesText];
  End;
Go
