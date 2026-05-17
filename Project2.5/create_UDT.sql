/*
 *  Trying to make this script reuseable.
 *  For example, if I've already made a copy of the old database,
 *    then do not make another copy.
 */
USE PrestigeCars;
GO

/*
 *  Make a copy of the original table.
 */
IF OBJECT_ID(N'Data.Country_Original', N'U') IS NULL
  BEGIN
    SELECT
      *
    INTO
      [Data].[Country_Original]
    FROM
      [Data].[Country];
  END;
GO

/*
 *  Create the schemas
 */
IF SCHEMA_ID(N'UserDefinedTypes') IS NULL
  CREATE SCHEMA [UserDefinedTypes];
GO

IF SCHEMA_ID(N'Subroutines') IS NULL
  CREATE SCHEMA [Subroutines];
GO

IF SCHEMA_ID(N'Process') IS NULL
  CREATE SCHEMA [Process];
GO

/*
 *  Create the User-Defined Types (UDT)
 */

/*
 *  (1) Keys
 */
IF TYPE_ID(N'UserDefinedTypes.SurrogateIntKey') IS NULL
  CREATE TYPE [UserDefinedTypes].[SurrogateIntKey]
    FROM INT NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.SurrogateSmallIntKey') IS NULL
  CREATE TYPE [UserDefinedTypes].[SurrogateSmallIntKey]
    FROM SMALLINT NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.SurrogateBigIntKey') IS NULL
  CREATE TYPE [UserDefinedTypes].[SurrogateBigIntKey]
    FROM BIGINT NOT NULL;
GO

/*
 *  (2) Identifiers and codes
 */
IF TYPE_ID(N'UserDefinedTypes.TinyCode') IS NULL
  CREATE TYPE [UserDefinedTypes].[TinyCode]
    FROM NVARCHAR(8) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.SmallCode') IS NULL
  CREATE TYPE [UserDefinedTypes].[SmallCode]
    FROM NVARCHAR(16) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.MediumCode') IS NULL
  CREATE TYPE [UserDefinedTypes].[MediumCode]
    FROM NVARCHAR(64) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.ISOAlpha2') IS NULL
  CREATE TYPE [UserDefinedTypes].[ISOAlpha2]
    FROM NCHAR(2) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.ISOAlpha3') IS NULL
  CREATE TYPE [UserDefinedTypes].[ISOAlpha3]
    FROM NCHAR(3) NOT NULL;
GO

/*
 *  (3) Names and descriptions
 */
IF TYPE_ID(N'UserDefinedTypes.ShortName') IS NULL
  CREATE TYPE [UserDefinedTypes].[ShortName]
    FROM NVARCHAR(32) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.MediumName') IS NULL
  CREATE TYPE [UserDefinedTypes].[MediumName]
    FROM NVARCHAR(64) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.LongName') IS NULL
  CREATE TYPE [UserDefinedTypes].[LongName]
    FROM NVARCHAR(256) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.Comment') IS NULL
  CREATE TYPE [UserDefinedTypes].[Comment]
    FROM NVARCHAR(4000) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.LongComment') IS NULL
  CREATE TYPE [UserDefinedTypes].[LongComment]
    FROM NVARCHAR(MAX) NOT NULL;
GO

/*
 *  (4) Address and locations
 */
IF TYPE_ID(N'UserDefinedTypes.AddressLine') IS NULL
  CREATE TYPE [UserDefinedTypes].[AddressLine]
    FROM NVARCHAR(256) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.TownName') IS NULL
  CREATE TYPE [UserDefinedTypes].[TownName]
    FROM NVARCHAR(64) NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.PostalCode') IS NULL
  CREATE TYPE [UserDefinedTypes].[PostalCode]
    FROM NVARCHAR(32) NOT NULL;
GO

/*
 *  (5) Numbers
 */
IF TYPE_ID(N'UserDefinedTypes.YearNumber') IS NULL
  CREATE TYPE [UserDefinedTypes].[YearNumber]
    FROM SMALLINT NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.MonthNumber') IS NULL
  CREATE TYPE [UserDefinedTypes].[MonthNumber]
    FROM TINYINT NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.LineItemNumber') IS NULL
  CREATE TYPE [UserDefinedTypes].[LineItemNumber]
    FROM TINYINT NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.MoneyAmount') IS NULL
  CREATE TYPE [UserDefinedTypes].[MoneyAmount]
    FROM MONEY NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.Percentage') IS NULL
  CREATE TYPE [UserDefinedTypes].[Percentage]
    FROM TINYINT NOT NULL;
GO

/*
 *  (6) Time
 */
IF TYPE_ID(N'UserDefinedTypes.DateValue') IS NULL
  CREATE TYPE [UserDefinedTypes].[DateValue]
    FROM DATE NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.DateTimeValue') IS NULL
  CREATE TYPE [UserDefinedTypes].[DateTimeValue]
    FROM DATETIME NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.TimeValue') IS NULL
  CREATE TYPE [UserDefinedTypes].[TimeValue]
    FROM TIME(7) NOT NULL;
GO

/*
 *  (7) Etc.
 */
IF TYPE_ID(N'UserDefinedTypes.BooleanFlag') IS NULL
  CREATE TYPE [UserDefinedTypes].[BooleanFlag]
    FROM BIT NOT NULL;
GO

IF TYPE_ID(N'UserDefinedTypes.ImageBinary') IS NULL
  CREATE TYPE [UserDefinedTypes].[ImageBinary]
    FROM VARBINARY(MAX) NOT NULL;
GO