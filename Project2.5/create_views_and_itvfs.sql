USE [PrestigeCars];
GO

/*
 * create_views_and_itvfs.sql
 *
 * Purpose:
 *   Create reporting views and inline table-valued functions over the
 *   normalized PrestigeCars tables.
 *
 * Notes:
 *   - Views replace derived/reporting physical tables where possible.
 *   - Inline table-valued functions allow parameterized reusable queries.
 *   - This script assumes normalized tables have already been created
 *     and loaded with data.
 */


/*
 * Drop dependent objects first.
 * Drop functions before views only if they depend on views.
 * Here, functions and views both query base tables directly, so order is simple.
 */

DROP FUNCTION IF EXISTS [Subroutines].[itvf_SalesByYear];
GO

DROP FUNCTION IF EXISTS [Subroutines].[itvf_SalesByCountryISO2];
GO

DROP FUNCTION IF EXISTS [Subroutines].[itvf_SalesByMake];
GO

DROP VIEW IF EXISTS [Normalized].[vw_SalesByCountry];
GO

DROP VIEW IF EXISTS [Normalized].[vw_StockPrices];
GO

DROP VIEW IF EXISTS [Normalized].[vw_YearlySales];
GO

DROP VIEW IF EXISTS [Normalized].[vw_SalesPivotByColorYear];
GO


/*
 * 1. Replacement for the original Data.SalesByCountry-style view.
 *
 * Original idea:
 *   Join stock -> model -> make -> sales details -> sales -> customer -> country.
 *
 * Purpose:
 *   Provides a denormalized reporting view without physically storing
 *   duplicate report data.
 */

CREATE VIEW [Normalized].[vw_SalesByCountry]
AS
SELECT
    CO.CountryName,
    CO.CountryISO2,
    CO.CountryISO3,
    SR.SalesRegion,
    MK.MakeName,
    MD.ModelName,
    MD.ModelVariant,
    ST.StockCode,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    ST.Color,
    SD.SalePrice,
    SD.LineItemDiscount,
    SA.InvoiceNumber,
    SA.TotalSalePrice,
    SA.SaleDate,
    CS.CustomerName,
    SD.SalesDetailsId,
    SA.SalesId,
    ST.StockId,
    MD.ModelId,
    MK.MakeId,
    CS.CustomerId,
    CO.CountryId
FROM [Normalized].[SalesDetails] AS SD
    INNER JOIN [Normalized].[Sales] AS SA
        ON SD.SalesId = SA.SalesId
    INNER JOIN [Normalized].[Customer] AS CS
        ON SA.CustomerId = CS.CustomerId
    INNER JOIN [Normalized].[Country] AS CO
        ON CS.CountryId = CO.CountryId
    INNER JOIN [Normalized].[SalesRegion] AS SR
        ON CO.SalesRegionId = SR.SalesRegionId
    INNER JOIN [Normalized].[Stock] AS ST
        ON SD.StockId = ST.StockId
    INNER JOIN [Normalized].[Model] AS MD
        ON ST.ModelId = MD.ModelId
    INNER JOIN [Normalized].[Make] AS MK
        ON MD.MakeId = MK.MakeId;
GO


/*
 * 2. Replacement for Output.StockPrices.
 *
 * Original Output.StockPrices is report-like:
 *   MakeName, ModelName, Cost
 *
 * This view calculates that result from the normalized vehicle tables.
 */

CREATE VIEW [Normalized].[vw_StockPrices]
AS
SELECT
    MK.MakeName,
    MD.ModelName,
    MD.ModelVariant,
    ST.StockCode,
    ST.Color,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    ST.DateBought,
    ST.TimeBought
FROM [Normalized].[Stock] AS ST
    INNER JOIN [Normalized].[Model] AS MD
        ON ST.ModelId = MD.ModelId
    INNER JOIN [Normalized].[Make] AS MK
        ON MD.MakeId = MK.MakeId;
GO


/*
 * 3. Replacement for Reference.YearlySales-style reporting.
 *
 * This returns sale rows with their descriptive reporting columns.
 * The year can be filtered by querying YEAR(SaleDate), or by using
 * the itvf_SalesByYear function below.
 */

CREATE VIEW [Normalized].[vw_YearlySales]
AS
SELECT
    DATEPART(YEAR, SA.SaleDate) AS SaleYear,
    MK.MakeName,
    MD.ModelName,
    MD.ModelVariant,
    CS.CustomerName,
    CO.CountryName,
    CO.CountryISO2,
    ST.Cost,
    ST.RepairsCost,
    ST.PartsCost,
    ST.TransportInCost,
    SD.SalePrice,
    SD.LineItemDiscount,
    SA.SaleDate,
    SA.InvoiceNumber,
    ST.Color,
    SA.SalesId,
    SD.SalesDetailsId
FROM [Normalized].[SalesDetails] AS SD
    INNER JOIN [Normalized].[Sales] AS SA
        ON SD.SalesId = SA.SalesId
    INNER JOIN [Normalized].[Customer] AS CS
        ON SA.CustomerId = CS.CustomerId
    INNER JOIN [Normalized].[Country] AS CO
        ON CS.CountryId = CO.CountryId
    INNER JOIN [Normalized].[Stock] AS ST
        ON SD.StockId = ST.StockId
    INNER JOIN [Normalized].[Model] AS MD
        ON ST.ModelId = MD.ModelId
    INNER JOIN [Normalized].[Make] AS MK
        ON MD.MakeId = MK.MakeId;
GO


/*
 * 4. Replacement for Data.PivotTable-style reporting.
 *
 * Original PivotTable stores one row per color and columns for years.
 * This view calculates those totals from normalized sales data.
 *
 * NOTE:
 *   I am using SalePrice - LineItemDiscount as the reported sales amount.
 *   If your professor expects raw SalePrice instead, change the SUM expressions.
 */

CREATE VIEW [Normalized].[vw_SalesPivotByColorYear]
AS
SELECT
    ST.Color,

    SUM(
        CASE
            WHEN DATEPART(YEAR, SA.SaleDate) = 2015
            THEN SD.SalePrice - SD.LineItemDiscount
            ELSE 0
        END
    ) AS [2015],

    SUM(
        CASE
            WHEN DATEPART(YEAR, SA.SaleDate) = 2016
            THEN SD.SalePrice - SD.LineItemDiscount
            ELSE 0
        END
    ) AS [2016],

    SUM(
        CASE
            WHEN DATEPART(YEAR, SA.SaleDate) = 2017
            THEN SD.SalePrice - SD.LineItemDiscount
            ELSE 0
        END
    ) AS [2017],

    SUM(
        CASE
            WHEN DATEPART(YEAR, SA.SaleDate) = 2018
            THEN SD.SalePrice - SD.LineItemDiscount
            ELSE 0
        END
    ) AS [2018]
FROM [Normalized].[SalesDetails] AS SD
    INNER JOIN [Normalized].[Sales] AS SA
        ON SD.SalesId = SA.SalesId
    INNER JOIN [Normalized].[Stock] AS ST
        ON SD.StockId = ST.StockId
GROUP BY
    ST.Color;
GO


/*
 * 5. Inline table-valued function:
 *    Sales by year.
 *
 * Use:
 *   SELECT *
 *   FROM [Subroutines].[itvf_SalesByYear](2018);
 */

CREATE FUNCTION [Subroutines].[itvf_SalesByYear]
(
    @SaleYear [UserDefinedTypes].[YearNumber]
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        DATEPART(YEAR, SA.SaleDate) AS SaleYear,
        MK.MakeName,
        MD.ModelName,
        MD.ModelVariant,
        CS.CustomerName,
        CO.CountryName,
        CO.CountryISO2,
        SR.SalesRegion,
        ST.StockCode,
        ST.Color,
        ST.Cost,
        ST.RepairsCost,
        ST.PartsCost,
        ST.TransportInCost,
        SD.SalePrice,
        SD.LineItemDiscount,
        SA.TotalSalePrice,
        SA.InvoiceNumber,
        SA.SaleDate,
        SA.SalesId,
        SD.SalesDetailsId
    FROM [Normalized].[SalesDetails] AS SD
        INNER JOIN [Normalized].[Sales] AS SA
            ON SD.SalesId = SA.SalesId
        INNER JOIN [Normalized].[Customer] AS CS
            ON SA.CustomerId = CS.CustomerId
        INNER JOIN [Normalized].[Country] AS CO
            ON CS.CountryId = CO.CountryId
        INNER JOIN [Normalized].[SalesRegion] AS SR
            ON CO.SalesRegionId = SR.SalesRegionId
        INNER JOIN [Normalized].[Stock] AS ST
            ON SD.StockId = ST.StockId
        INNER JOIN [Normalized].[Model] AS MD
            ON ST.ModelId = MD.ModelId
        INNER JOIN [Normalized].[Make] AS MK
            ON MD.MakeId = MK.MakeId
    WHERE DATEPART(YEAR, SA.SaleDate) = @SaleYear
);
GO


/*
 * 6. Inline table-valued function:
 *    Sales by country ISO2.
 *
 * Use:
 *   SELECT *
 *   FROM [Subroutines].[itvf_SalesByCountryISO2](N'GB');
 */

CREATE FUNCTION [Subroutines].[itvf_SalesByCountryISO2]
(
    @CountryISO2 [UserDefinedTypes].[ISOAlpha2]
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CO.CountryName,
        CO.CountryISO2,
        CO.CountryISO3,
        SR.SalesRegion,
        MK.MakeName,
        MD.ModelName,
        MD.ModelVariant,
        CS.CustomerName,
        ST.StockCode,
        ST.Color,
        SD.SalePrice,
        SD.LineItemDiscount,
        SA.TotalSalePrice,
        SA.InvoiceNumber,
        SA.SaleDate,
        SA.SalesId,
        SD.SalesDetailsId
    FROM [Normalized].[SalesDetails] AS SD
        INNER JOIN [Normalized].[Sales] AS SA
            ON SD.SalesId = SA.SalesId
        INNER JOIN [Normalized].[Customer] AS CS
            ON SA.CustomerId = CS.CustomerId
        INNER JOIN [Normalized].[Country] AS CO
            ON CS.CountryId = CO.CountryId
        INNER JOIN [Normalized].[SalesRegion] AS SR
            ON CO.SalesRegionId = SR.SalesRegionId
        INNER JOIN [Normalized].[Stock] AS ST
            ON SD.StockId = ST.StockId
        INNER JOIN [Normalized].[Model] AS MD
            ON ST.ModelId = MD.ModelId
        INNER JOIN [Normalized].[Make] AS MK
            ON MD.MakeId = MK.MakeId
    WHERE CO.CountryISO2 = @CountryISO2
);
GO


/*
 * 7. Inline table-valued function:
 *    Sales by vehicle make.
 *
 * Use:
 *   SELECT *
 *   FROM [Subroutines].[itvf_SalesByMake](N'Ferrari');
 */

CREATE FUNCTION [Subroutines].[itvf_SalesByMake]
(
    @MakeName [UserDefinedTypes].[LongName]
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        MK.MakeName,
        MD.ModelName,
        MD.ModelVariant,
        CO.CountryName AS CustomerCountry,
        CS.CustomerName,
        ST.StockCode,
        ST.Color,
        ST.Cost,
        SD.SalePrice,
        SD.LineItemDiscount,
        SA.TotalSalePrice,
        SA.InvoiceNumber,
        SA.SaleDate,
        SA.SalesId,
        SD.SalesDetailsId
    FROM [Normalized].[SalesDetails] AS SD
        INNER JOIN [Normalized].[Sales] AS SA
            ON SD.SalesId = SA.SalesId
        INNER JOIN [Normalized].[Customer] AS CS
            ON SA.CustomerId = CS.CustomerId
        INNER JOIN [Normalized].[Country] AS CO
            ON CS.CountryId = CO.CountryId
        INNER JOIN [Normalized].[Stock] AS ST
            ON SD.StockId = ST.StockId
        INNER JOIN [Normalized].[Model] AS MD
            ON ST.ModelId = MD.ModelId
        INNER JOIN [Normalized].[Make] AS MK
            ON MD.MakeId = MK.MakeId
    WHERE MK.MakeName = @MakeName
);
GO


/*
 * Verification queries.
 */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = N'Normalized'
ORDER BY TABLE_NAME;
GO

SELECT
    ROUTINE_SCHEMA,
    ROUTINE_NAME,
    ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = N'Subroutines'
ORDER BY ROUTINE_NAME;
GO