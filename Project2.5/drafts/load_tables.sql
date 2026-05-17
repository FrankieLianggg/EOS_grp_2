USE [PrestigeCars];
GO

SET NOCOUNT ON;
GO

/*
 * load_normalized_tables.sql
 *
 * Purpose:
 *   Load cleaned data from the preserved _Original_* tables
 *   into the normalized working tables.
 *
 * Assumptions:
 *   1. preserve_original_tables.sql has already been run.
 *   2. create_UDT.sql has already been run.
 *   3. create_tables.sql has already been run.
 *   4. The normalized tables currently exist in the Normalized schema.
 *
 * Notes:
 *   - CustomerId is regenerated as a surrogate key.
 *   - MakeId, ModelId, SalesId, and SalesDetailsId are preserved from the source
 *     because the original relationships already use those values.
 *   - StockId is regenerated as a surrogate key.
 *   - StockCode is preserved as an alternate/business key.
 *   - Bad Stock rows with missing/invalid ModelId are excluded by the INNER JOIN.
 */


/*
 * 0. Clear normalized tables so this script can be rerun.
 *    Delete child tables before parent tables.
 */

DELETE FROM [Normalized].[SalesDetails];
DELETE FROM [Normalized].[Sales];
DELETE FROM [Normalized].[Stock];
DELETE FROM [Normalized].[Model];
DELETE FROM [Normalized].[Make];
DELETE FROM [Normalized].[Customer];
DELETE FROM [Normalized].[Country];
DELETE FROM [Normalized].[SalesRegion];
GO

/*
 * Reset identity seeds.
 */

DBCC CHECKIDENT ('[Normalized].[SalesDetails]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Sales]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Stock]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Model]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Make]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Customer]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[Country]', RESEED, 0);
DBCC CHECKIDENT ('[Normalized].[SalesRegion]', RESEED, 0);
GO


/*
 * 1. Load SalesRegion.
 *
 * Original problem:
 *   SalesRegion was repeated inside Data.Country.
 *
 * Normalized fix:
 *   Store each SalesRegion once.
 */

INSERT INTO [Normalized].[SalesRegion]
(
    [SalesRegion]
)
SELECT DISTINCT
    TRIM([SalesRegion]) AS SalesRegion
FROM [Normalized].[_Original_Data_Country]
WHERE [SalesRegion] IS NOT NULL;
GO


/*
 * 2. Load Country.
 *
 * Cleansing:
 *   - Trim padded ISO code values.
 *   - Fix Switzerland ISO3 from CHF to CHE.
 *     CHF is a currency code, not the country ISO3 code.
 */

INSERT INTO [Normalized].[Country]
(
    [CountryName],
    [CountryISO2],
    [CountryISO3],
    [SalesRegionId]
)
SELECT
    TRIM(C.[CountryName]) AS CountryName,
    TRIM(C.[CountryISO2]) AS CountryISO2,
    CASE
        WHEN TRIM(C.[CountryName]) = N'Switzerland'
             AND TRIM(C.[CountryISO3]) = N'CHF'
        THEN N'CHE'
        ELSE TRIM(C.[CountryISO3])
    END AS CountryISO3,
    SR.[SalesRegionId]
FROM [Normalized].[_Original_Data_Country] AS C
INNER JOIN [Normalized].[SalesRegion] AS SR
    ON SR.[SalesRegion] = TRIM(C.[SalesRegion]);
GO


/*
 * 3. Load Customer.
 *
 * CustomerId is regenerated.
 * Since the final Customer table does not keep the original CustomerID string,
 * we create a temporary mapping table:
 *
 *   Old CustomerID string -> New CustomerId surrogate key
 */

DROP TABLE IF EXISTS #MapCustomer;
GO

CREATE TABLE #MapCustomer
(
    OldCustomerID nvarchar(5) NOT NULL,
    NewCustomerId bigint NOT NULL
);
GO

MERGE [Normalized].[Customer] AS Target
USING
(
    SELECT
        TRIM([CustomerID]) AS OldCustomerID,
        TRIM([CustomerName]) AS CustomerName,
        ISNULL(TRIM([Address1]), N'Unknown') AS Address1,
        NULLIF(TRIM([Address2]), N'') AS Address2,
        ISNULL(TRIM([Town]), N'Unknown') AS Town,
        NULLIF(TRIM([PostCode]), N'') AS PostalCode,
        TRIM([Country]) AS CountryISO2,
        ISNULL([IsReseller], 0) AS IsReseller,
        ISNULL([IsCreditRisk], 0) AS IsCreditRisk
    FROM [Normalized].[_Original_Data_Customer]
) AS Source
ON 1 = 0
WHEN NOT MATCHED THEN
    INSERT
    (
        [CustomerName],
        [Address1],
        [Address2],
        [Town],
        [PostalCode],
        [CountryId],
        [IsReseller],
        [IsCreditRisk]
    )
    VALUES
    (
        Source.[CustomerName],
        Source.[Address1],
        Source.[Address2],
        Source.[Town],
        Source.[PostalCode],
        (
            SELECT C.[CountryId]
            FROM [Normalized].[Country] AS C
            WHERE C.[CountryISO2] = Source.[CountryISO2]
        ),
        Source.[IsReseller],
        Source.[IsCreditRisk]
    )
OUTPUT
    Source.[OldCustomerID],
    inserted.[CustomerId]
INTO #MapCustomer
(
    OldCustomerID,
    NewCustomerId
);
GO


/*
 * 4. Load Make.
 *
 * MakeId is preserved from the original because Model.MakeID references it.
 *
 * Cleansing:
 *   - Original MakeCountry uses GER.
 *   - Country table uses DEU for Germany.
 */

SET IDENTITY_INSERT [Normalized].[Make] ON;
GO

INSERT INTO [Normalized].[Make]
(
    [MakeId],
    [MakeName],
    [CountryId]
)
SELECT
    M.[MakeID] AS MakeId,
    TRIM(M.[MakeName]) AS MakeName,
    C.[CountryId]
FROM [Normalized].[_Original_Data_Make] AS M
INNER JOIN [Normalized].[Country] AS C
    ON C.[CountryISO3] =
        CASE
            WHEN TRIM(M.[MakeCountry]) = N'GER' THEN N'DEU'
            ELSE TRIM(M.[MakeCountry])
        END;
GO

SET IDENTITY_INSERT [Normalized].[Make] OFF;
GO


/*
 * 5. Load Model.
 *
 * ModelId is preserved from the original because Stock.ModelID references it.
 *
 * Cleansing:
 *   - Convert YearFirstProduced and YearLastProduced from char(4) to smallint.
 *   - Blank ModelVariant values become NULL.
 */

SET IDENTITY_INSERT [Normalized].[Model] ON;
GO

INSERT INTO [Normalized].[Model]
(
    [ModelId],
    [MakeId],
    [ModelName],
    [ModelVariant],
    [YearFirstProduced],
    [YearLastProduced]
)
SELECT
    MD.[ModelID] AS ModelId,
    MD.[MakeID] AS MakeId,
    TRIM(MD.[ModelName]) AS ModelName,
    NULLIF(TRIM(MD.[ModelVariant]), N'') AS ModelVariant,
    TRY_CONVERT(smallint, NULLIF(TRIM(MD.[YearFirstProduced]), N'')) AS YearFirstProduced,
    TRY_CONVERT(smallint, NULLIF(TRIM(MD.[YearLastProduced]), N'')) AS YearLastProduced
FROM [Normalized].[_Original_Data_Model] AS MD
INNER JOIN [Normalized].[Make] AS MK
    ON MK.[MakeId] = MD.[MakeID];
GO

SET IDENTITY_INSERT [Normalized].[Model] OFF;
GO


/*
 * 6. Load Stock.
 *
 * StockId is regenerated.
 * StockCode is preserved as a unique alternate/business key.
 *
 * Important:
 *   The INNER JOIN to Normalized.Model intentionally excludes stock rows
 *   whose original ModelID does not exist in the model table.
 */

INSERT INTO [Normalized].[Stock]
(
    [StockCode],
    [ModelId],
    [Cost],
    [RepairsCost],
    [PartsCost],
    [TransportInCost],
    [IsRHD],
    [Color],
    [BuyerComments],
    [DateBought],
    [TimeBought]
)
SELECT
    TRIM(ST.[StockCode]) AS StockCode,
    ST.[ModelID] AS ModelId,
    ISNULL(ST.[Cost], 0) AS Cost,
    ISNULL(ST.[RepairsCost], 0) AS RepairsCost,
    ISNULL(ST.[PartsCost], 0) AS PartsCost,
    ISNULL(ST.[TransportInCost], 0) AS TransportInCost,
    ISNULL(ST.[IsRHD], 0) AS IsRHD,
    ISNULL(TRIM(ST.[Color]), N'Unknown') AS Color,
    NULLIF(TRIM(ST.[BuyerComments]), N'') AS BuyerComments,
    ISNULL(ST.[DateBought], CONVERT(date, '19000101')) AS DateBought,
    ISNULL(ST.[TimeBought], CONVERT(time, '00:00:00')) AS TimeBought
FROM [Normalized].[_Original_Data_Stock] AS ST
INNER JOIN [Normalized].[Model] AS MD
    ON MD.[ModelId] = ST.[ModelID]
WHERE ST.[StockCode] IS NOT NULL;
GO


/*
 * 7. Load Sales.
 *
 * SalesId is preserved from the original because SalesDetails.SalesID references it.
 * CustomerId is mapped from old string CustomerID to new surrogate CustomerId.
 */

SET IDENTITY_INSERT [Normalized].[Sales] ON;
GO

INSERT INTO [Normalized].[Sales]
(
    [SalesId],
    [CustomerId],
    [InvoiceNumber],
    [TotalSalePrice],
    [SaleDate]
)
SELECT
    SA.[SalesID] AS SalesId,
    MC.[NewCustomerId] AS CustomerId,
    TRIM(SA.[InvoiceNumber]) AS InvoiceNumber,
    ISNULL(SA.[TotalSalePrice], 0) AS TotalSalePrice,
    ISNULL(SA.[SaleDate], CONVERT(datetime, '19000101')) AS SaleDate
FROM [Normalized].[_Original_Data_Sales] AS SA
INNER JOIN #MapCustomer AS MC
    ON MC.[OldCustomerID] = TRIM(SA.[CustomerID]);
GO

SET IDENTITY_INSERT [Normalized].[Sales] OFF;
GO


/*
 * 8. Load SalesDetails.
 *
 * SalesDetailsId is preserved from the original.
 * SalesId is preserved from original Sales.
 * StockId is mapped from original StockID/StockCode to new surrogate StockId.
 *
 * Rows whose StockID does not match a loaded stock row are excluded.
 */

SET IDENTITY_INSERT [Normalized].[SalesDetails] ON;
GO

INSERT INTO [Normalized].[SalesDetails]
(
    [SalesDetailsId],
    [SalesId],
    [LineItemNumber],
    [StockId],
    [SalePrice],
    [LineItemDiscount]
)
SELECT
    SD.[SalesDetailsID] AS SalesDetailsId,
    SD.[SalesID] AS SalesId,
    ISNULL(SD.[LineItemNumber], 1) AS LineItemNumber,
    ST.[StockId] AS StockId,
    ISNULL(SD.[SalePrice], 0) AS SalePrice,
    ISNULL(SD.[LineItemDiscount], 0) AS LineItemDiscount
FROM [Normalized].[_Original_Data_SalesDetails] AS SD
INNER JOIN [Normalized].[Sales] AS SA
    ON SA.[SalesId] = SD.[SalesID]
INNER JOIN [Normalized].[Stock] AS ST
    ON ST.[StockCode] = TRIM(SD.[StockID]);
GO

SET IDENTITY_INSERT [Normalized].[SalesDetails] OFF;
GO


/*
 * 9. Show load counts.
 */

SELECT 'Normalized.SalesRegion' AS TableName, COUNT(*) AS [RowCount] FROM [Normalized].[SalesRegion]
UNION ALL
SELECT 'Normalized.Country', COUNT(*) FROM [Normalized].[Country]
UNION ALL
SELECT 'Normalized.Customer', COUNT(*) FROM [Normalized].[Customer]
UNION ALL
SELECT 'Normalized.Make', COUNT(*) FROM [Normalized].[Make]
UNION ALL
SELECT 'Normalized.Model', COUNT(*) FROM [Normalized].[Model]
UNION ALL
SELECT 'Normalized.Stock', COUNT(*) FROM [Normalized].[Stock]
UNION ALL
SELECT 'Normalized.Sales', COUNT(*) FROM [Normalized].[Sales]
UNION ALL
SELECT 'Normalized.SalesDetails', COUNT(*) FROM [Normalized].[SalesDetails];
GO


/*
 * 10. Show excluded / anomaly counts.
 */

SELECT
    'Stock rows excluded because ModelID was missing or invalid' AS CheckName,
    COUNT(*) AS ProblemRows
FROM [Normalized].[_Original_Data_Stock] AS ST
LEFT JOIN [Normalized].[Model] AS MD
    ON MD.[ModelId] = ST.[ModelID]
WHERE MD.[ModelId] IS NULL

UNION ALL

SELECT
    'SalesDetails rows excluded because StockID was missing or invalid',
    COUNT(*)
FROM [Normalized].[_Original_Data_SalesDetails] AS SD
LEFT JOIN [Normalized].[Stock] AS ST
    ON ST.[StockCode] = TRIM(SD.[StockID])
WHERE ST.[StockId] IS NULL

UNION ALL

SELECT
    'Sales rows excluded because CustomerID was missing or invalid',
    COUNT(*)
FROM [Normalized].[_Original_Data_Sales] AS SA
LEFT JOIN #MapCustomer AS MC
    ON MC.[OldCustomerID] = TRIM(SA.[CustomerID])
WHERE MC.[NewCustomerId] IS NULL;
GO