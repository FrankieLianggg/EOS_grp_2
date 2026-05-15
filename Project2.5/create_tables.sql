USE [PrestigeCars];
GO

/*
 *  idk what kind of information this represents, besides the obvious.
 *  1.
 */

CREATE TABLE [Normalized].[SalesRegion]
(
    SalesRegionId [UserDefinedTypes].[SurrogateIntKey] IDENTITY(1,1) NOT NULL,
    SalesRegion   [UserDefinedTypes].[MediumName] NOT NULL,

    CONSTRAINT [PK_SalesRegion_SalesRegionId]
        PRIMARY KEY CLUSTERED (SalesRegionId),

    CONSTRAINT [UQ_SalesRegion_SalesRegion]
        UNIQUE ([SalesRegion])
);

/*
 *  2.
 */

CREATE TABLE [Normalized].[Country]
(
    CountryId     [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    CountryName   [UserDefinedTypes].[LongName] NOT NULL,
    CountryISO2   [UserDefinedTypes].[ISOAlpha2] NOT NULL,
    CountryISO3   [UserDefinedTypes].[ISOAlpha3] NOT NULL,
    SalesRegionId [UserDefinedTypes].[SurrogateIntKey] NOT NULL,

    CONSTRAINT [PK_Country]
        PRIMARY KEY CLUSTERED ([CountryId]),

    CONSTRAINT [UQ_Country_CountryName]
        UNIQUE ([CountryName]),

    CONSTRAINT [UQ_Country_CountryISO2]
        UNIQUE ([CountryISO2]),

    CONSTRAINT [UQ_Country_CountryISO3]
        UNIQUE ([CountryISO3]),

    CONSTRAINT [FK_Country_SalesRegion]
        FOREIGN KEY ([SalesRegionId])
        REFERENCES [Normalized].[SalesRegion]([SalesRegionId]),

    CONSTRAINT [CK_Country_CountryISO2]
        CHECK (CountryISO2 LIKE N'[A-Z][A-Z]'),

    CONSTRAINT [CK_Country_CountryISO3]
        CHECK (CountryISO3 LIKE N'[A-Z][A-Z][A-Z]')
);

/*
 *  3.
 */

CREATE TABLE [Normalized].[Customer]
(
    CustomerId  [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    CustomerName [UserDefinedTypes].[LongName] NOT NULL,
    Address1     [UserDefinedTypes].[AddressLine] NOT NULL,
    Address2     [UserDefinedTypes].[AddressLine] NULL,
    Town         [UserDefinedTypes].[TownName] NOT NULL,
    PostalCode   [UserDefinedTypes].[PostalCode] NULL,
    CountryId    [UserDefinedTypes].[SurrogateBigIntKey] NOT NULL,
    IsReseller   [UserDefinedTypes].[BooleanFlag] NOT NULL,
    IsCreditRisk [UserDefinedTypes].[BooleanFlag] NOT NULL,

    CONSTRAINT [PK_Customer]
        PRIMARY KEY CLUSTERED ([CustomerId]),

    CONSTRAINT [FK_Customer_Country]
        FOREIGN KEY ([CountryId])
        REFERENCES [Normalized].[Country]([CountryId]),

    CONSTRAINT [DF_Customer_IsReseller]
        DEFAULT (0) FOR IsReseller,

    CONSTRAINT [DF_Customer_IsCreditRisk]
        DEFAULT (0) FOR IsCreditRisk
);

/*
 *  4.
 */

CREATE TABLE [Normalized].[Make]
(
    MakeId    [UserDefinedTypes].[SurrogateSmallIntKey] IDENTITY(1,1) NOT NULL,
    MakeName  [UserDefinedTypes].[LongName] NOT NULL,
    CountryId [UserDefinedTypes].[SurrogateBigIntKey] NOT NULL,

    CONSTRAINT [PK_Make]
        PRIMARY KEY CLUSTERED ([MakeId]),

    CONSTRAINT [UQ_Make_MakeName]
        UNIQUE ([MakeName]),

    CONSTRAINT [FK_Make_Country]
        FOREIGN KEY ([CountryId])
        REFERENCES [Normalized].[Country]([CountryId])
);

CREATE TABLE [Normalized].[Model]
(
    ModelId           [UserDefinedTypes].[SurrogateSmallIntKey] IDENTITY(1,1) NOT NULL,
    MakeId            [UserDefinedTypes].[SurrogateSmallIntKey] NOT NULL,
    ModelName         [UserDefinedTypes].[LongName] NOT NULL,
    ModelVariant      [UserDefinedTypes].[LongName] NULL,
    YearFirstProduced [UserDefinedTypes].[YearNumber] NULL,
    YearLastProduced  [UserDefinedTypes].[YearNumber] NULL,

    CONSTRAINT [PK_Model]
        PRIMARY KEY CLUSTERED ([ModelId]),

    CONSTRAINT [FK_Model_Make]
        FOREIGN KEY ([MakeId])
        REFERENCES [Normalized].[Make]([MakeId]),

    CONSTRAINT [CK_Model_YearFirstProduced]
        CHECK (
            YearFirstProduced IS NULL
            OR YearFirstProduced BETWEEN 1885 AND 2100
        ),

    CONSTRAINT [CK_Model_YearLastProduced]
        CHECK (
            YearLastProduced IS NULL
            OR YearLastProduced BETWEEN 1885 AND 2100
        ),

    CONSTRAINT [CK_Model_YearRange]
        CHECK (
            YearFirstProduced IS NULL
            OR YearLastProduced IS NULL
            OR YearLastProduced >= YearFirstProduced
        )
);

CREATE TABLE [Normalized].[Stock]
(
    StockId         [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    StockCode       [UserDefinedTypes].[MediumCode] NOT NULL,
    ModelId         [UserDefinedTypes].[SurrogateSmallIntKey] NOT NULL,
    Cost            [UserDefinedTypes].[MoneyAmount] NOT NULL,
    RepairsCost     [UserDefinedTypes].[MoneyAmount] NOT NULL,
    PartsCost       [UserDefinedTypes].[MoneyAmount] NOT NULL,
    TransportInCost [UserDefinedTypes].[MoneyAmount] NOT NULL,
    IsRHD           [UserDefinedTypes].[BooleanFlag] NOT NULL,
    Color           [UserDefinedTypes].[MediumName] NOT NULL,
    BuyerComments   [UserDefinedTypes].[Comment] NULL,
    DateBought      [UserDefinedTypes].[DateValue] NOT NULL,
    TimeBought      [UserDefinedTypes].[TimeValue] NOT NULL,

    CONSTRAINT [PK_Stock]
        PRIMARY KEY CLUSTERED ([StockId]),

    CONSTRAINT [UQ_Stock_StockCode]
        UNIQUE ([StockCode]),

    CONSTRAINT [FK_Stock_Model]
        FOREIGN KEY ([ModelId])
        REFERENCES [Normalized].[Model]([ModelId]),

    CONSTRAINT [CK_Stock_CostsNonnegative]
        CHECK (
            Cost >= 0
            AND RepairsCost >= 0
            AND PartsCost >= 0
            AND TransportInCost >= 0
        ),

    CONSTRAINT [DF_Stock_RepairsCost]
        DEFAULT (0) FOR RepairsCost,

    CONSTRAINT [DF_Stock_PartsCost]
        DEFAULT (0) FOR PartsCost,

    CONSTRAINT [DF_Stock_TransportInCost]
        DEFAULT (0) FOR TransportInCost
);

/*
 * 4. Sales tables
 */

CREATE TABLE [Normalized].[Sales]
(
    SalesId         [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    CustomerId      [UserDefinedTypes].[SurrogateBigIntKey] NOT NULL,
    InvoiceNumber   [UserDefinedTypes].[TinyCode] NOT NULL,
    TotalSalePrice  [UserDefinedTypes].[MoneyAmount] NOT NULL,
    SaleDate        [UserDefinedTypes].[DateTimeValue] NOT NULL,

    CONSTRAINT [PK_Sales]
        PRIMARY KEY CLUSTERED ([SalesId]),

    CONSTRAINT [UQ_Sales_InvoiceNumber]
        UNIQUE ([InvoiceNumber]),

    CONSTRAINT [FK_Sales_Customer]
        FOREIGN KEY ([CustomerId])
        REFERENCES [Normalized].[Customer]([CustomerId]),

    CONSTRAINT [CK_Normalized_Sales_TotalSalePriceNonnegative]
        CHECK (TotalSalePrice >= 0)
);

CREATE TABLE [Normalized].[SalesDetails]
(
    SalesDetailsId    [UserDefinedTypes].[SurrogateBigIntKey] IDENTITY(1,1) NOT NULL,
    SalesId           [UserDefinedTypes].[SurrogateBigIntKey] NOT NULL,
    LineItemNumber    [UserDefinedTypes].[LineItemNumber] NOT NULL,
    StockId           [UserDefinedTypes].[SurrogateBigIntKey] NOT NULL,
    SalePrice         [UserDefinedTypes].[MoneyAmount] NOT NULL,
    LineItemDiscount  [UserDefinedTypes].[MoneyAmount] NOT NULL,

    CONSTRAINT [PK_SalesDetails]
        PRIMARY KEY CLUSTERED ([SalesDetailsId]),

    CONSTRAINT [FK_SalesDetails_Sales]
        FOREIGN KEY ([SalesId])
        REFERENCES [Normalized].[Sales]([SalesId]),

    CONSTRAINT [FK_SalesDetails_Stock]
        FOREIGN KEY ([StockId])
        REFERENCES [Normalized].[Stock]([StockId]),

    CONSTRAINT [UQ_SalesDetails_Sales_LineItem]
        UNIQUE (SalesId, LineItemNumber),

    CONSTRAINT [CK_SalesDetails_AmountsNonnegative]
        CHECK (
            SalePrice >= 0
            AND LineItemDiscount >= 0
        ),

    CONSTRAINT [DF_SalesDetails_LineItemDiscount]
        DEFAULT (0) FOR LineItemDiscount
);
