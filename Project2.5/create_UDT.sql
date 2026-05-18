/*
 *  Trying to make this script reuseable.
 *  For example, if I've already made a copy of the old database,
 *    then do not make another copy.
 */
USE PrestigeCars;
/*
 *  Create the schemas
 *  Note: schemas cannot be dropped and recreated if they own objects.
 */
GO
  CREATE SCHEMA [Normalized];
GO
  CREATE SCHEMA [UserDefinedTypes];
GO
  CREATE SCHEMA [Subroutines];
GO
  CREATE SCHEMA [Process];
GO

/*
 *  Create the User-Defined Types (UDT)
 *  DROP then CREATE pattern.
 */

/*
 *  (1) Keys
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[SurrogateIntKey];
CREATE TYPE [UserDefinedTypes].[SurrogateIntKey]
  FROM INT NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[SurrogateSmallIntKey];
CREATE TYPE [UserDefinedTypes].[SurrogateSmallIntKey]
  FROM SMALLINT NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[SurrogateBigIntKey];
CREATE TYPE [UserDefinedTypes].[SurrogateBigIntKey]
  FROM BIGINT NOT NULL;
GO

/*
 *  (2) Identifiers and codes
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[TinyCode];
CREATE TYPE [UserDefinedTypes].[TinyCode]
  FROM NVARCHAR(8) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[SmallCode];
CREATE TYPE [UserDefinedTypes].[SmallCode]
  FROM NVARCHAR(16) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[MediumCode];
CREATE TYPE [UserDefinedTypes].[MediumCode]
  FROM NVARCHAR(64) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[ISOAlpha2];
CREATE TYPE [UserDefinedTypes].[ISOAlpha2]
  FROM NCHAR(2) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[ISOAlpha3];
CREATE TYPE [UserDefinedTypes].[ISOAlpha3]
  FROM NCHAR(3) NOT NULL;
GO

/*
 *  (3) Names and descriptions
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[ShortName];
CREATE TYPE [UserDefinedTypes].[ShortName]
  FROM NVARCHAR(32) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[MediumName];
CREATE TYPE [UserDefinedTypes].[MediumName]
  FROM NVARCHAR(64) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[LongName];
CREATE TYPE [UserDefinedTypes].[LongName]
  FROM NVARCHAR(256) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[Comment];
CREATE TYPE [UserDefinedTypes].[Comment]
  FROM NVARCHAR(4000) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[LongComment];
CREATE TYPE [UserDefinedTypes].[LongComment]
  FROM NVARCHAR(MAX) NOT NULL;
GO

/*
 *  (4) Address and locations
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[AddressLine];
CREATE TYPE [UserDefinedTypes].[AddressLine]
  FROM NVARCHAR(256) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[TownName];
CREATE TYPE [UserDefinedTypes].[TownName]
  FROM NVARCHAR(64) NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[PostalCode];
CREATE TYPE [UserDefinedTypes].[PostalCode]
  FROM NVARCHAR(32) NOT NULL;
GO

/*
 *  (5) Numbers
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[YearNumber];
CREATE TYPE [UserDefinedTypes].[YearNumber]
  FROM SMALLINT NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[MonthNumber];
CREATE TYPE [UserDefinedTypes].[MonthNumber]
  FROM TINYINT NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[LineItemNumber];
CREATE TYPE [UserDefinedTypes].[LineItemNumber]
  FROM TINYINT NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[MoneyAmount];
CREATE TYPE [UserDefinedTypes].[MoneyAmount]
  FROM MONEY NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[Percentage];
CREATE TYPE [UserDefinedTypes].[Percentage]
  FROM TINYINT NOT NULL;
GO

/*
 *  (6) Time
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[DateValue];
CREATE TYPE [UserDefinedTypes].[DateValue]
  FROM DATE NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[DateTimeValue];
CREATE TYPE [UserDefinedTypes].[DateTimeValue]
  FROM DATETIME NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[TimeValue];
CREATE TYPE [UserDefinedTypes].[TimeValue]
  FROM TIME(7) NOT NULL;
GO

/*
 *  (7) Etc.
 */
DROP TYPE IF EXISTS [UserDefinedTypes].[BooleanFlag];
CREATE TYPE [UserDefinedTypes].[BooleanFlag]
  FROM BIT NOT NULL;
GO

DROP TYPE IF EXISTS [UserDefinedTypes].[ImageBinary];
CREATE TYPE [UserDefinedTypes].[ImageBinary]
  FROM VARBINARY(MAX) NOT NULL;
GO

/*
 *  Verification: list all UDTs just created.
 */
SELECT
    name           AS TypeName,
    system_type_id,
    max_length,
    is_nullable
FROM sys.types
WHERE is_user_defined = 1
ORDER BY name;
GO

/*Created by Salvador, Edited by Frankie and Prabjot*/