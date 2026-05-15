/*
 *  Trying to make this script reuseable.
 *  For example, if I've already made a copy of the old database,
 *    then do not make another copy.
 */
USE PrestigeCars; 
GO

/*
 *  Make a copy of the original table.
 *  Syntax for object_id:
 *
 *    OBJECT_ID(N'object_name', N'object_type')
 *
 */
if object_id(n'Data.Country_Original', n'u') is null
  Begin
    select 
      *
    into
      [Data].[Country_Original]
    from
      [Data].[Country];
  End;

/*
 *  Create the schemas
 *  Syntax for schema_id:
 *
 *    SCHEMA_ID(N'schema_name')
 *
 */
if schema_id(n'UserDefinedTypes') is null
  Begin

    -- I think create schema statements need to be the first in a batch.
    -- create schema [UserDefinedTypes];

    -- Think this creates a... dynamic sql context.
    exec(n'create schema [UserDefinedTypes];');
  End;
GO

if schema_id(n'Subroutines') is null
  Begin
    -- create schema [n'Subroutines'];

    exec(n'create schema [Subroutines];');
  End;
GO

if schema_id(n'Process') is null
  Begin
    -- create schema [n'Subroutines'];

    exec(n'create schema [Process];');
  End;
GO


/*
 *  Create the User-Defined Types(UDT)
 *  Syntax for type_id:
 *
 *    TYPE_ID(N'type_name')
 *
 */

/*
 *  (1) Keys
 */

if type_id(n'UserDefinedTypes.SurrogateIntKey') is null
  Begin
    exec(n'
      create type 
        [UserDefinedTypes].[SurrogateIntKey]
      from    
        int not null;
    ');
  End;

if type_id(n'UserDefinedTypes.SurrogateSmallIntKey') is null
  Begin
    exec(n'
      create type 
        [UserDefinedTypes].[SurrogateSmallIntKey]
      from    
        smallint not null;
    ');
  End;

if type_id(n'UserDefinedTypes.SurrogateBigIntKey') is null
  Begin
    exec(n'
      create type 
        [UserDefinedTypes].[SurrogateBigIntKey]
      from    
        bigint not null;
    ');
  End;

/*
 *  (2) Identifiers and code.
 */

if type_id(n'UserDefinedTypes.TinyCode') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[TinyCode]
      from
        nvarchar(8) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.SmallCode') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[SmallCode]
      from
        nvarchar(16) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.MediumCode') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[MediumCode]
      from
        nvarchar(64) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.ISOAlpha2') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[ISOAlpha2]
      from
        nchar(2) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.ISOAlpha3') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[ISOAlpha3]
      from
        nchar(3) not null;
    ');
  End;

/*
 *  (3) Names and descriptions.
 */

if type_id(n'UserDefinedTypes.ShortName') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[ShortName]
      from
        nvarchar(32) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.MediumName') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[MediumName]
      from
        nvarchar(64) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.LongName') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[LongName]
      from
        nvarchar(256) not null;
    ');
  End;
 
if type_id(n'UserDefinedTypes.Comment') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[Comment]
      from
        nvarchar(4000) not null;
    ');
  End;


if type_id(n'UserDefinedTypes.LongComment') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[LongComment]
      from
        nvarchar(max) not null;
    ');
  End;

/*
 *  (4) Address and locations.
 */

if type_id(n'UserDefinedTypes.AddressLine') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[AddressLine]
      from
        nvarchar(256) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.TownName') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[TownName]
      from
        nvarchar(64) not null;
    ');
  End;

if type_id(n'UserDefinedTypes.PostalCode') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[PostalCode]
      from
        nvarchar(32) not null;
    ');
  End;

/*
 *  (5) Numbers.
 */

if type_id(n'UserDefinedTypes.YearNumber') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[YearNumber]
      from
        smallint not null;
    ');
  End;

if type_id(n'UserDefinedTypes.MonthNumber') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[MonthNumber]
      from
        tinyint not null;
    ');
  End;

if type_id(n'UserDefinedTypes.LineItemNumber') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[LineItemNumber]
      from
        tinyint not null;
    ');
  End;

if type_id(n'UserDefinedTypes.MoneyAmount') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[MoneyAmount]
      from
        money not null;
    ');
  End;

if type_id(n'UserDefinedTypes.Percentage') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[Percentage]
      from
        tinyint not null;
    ');
  End;

/*
 *  (6) Time
 */

if type_id(n'UserDefinedTypes.DateValue') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[DateValue]
      from
        date not null;
    ');
  End;

if type_id(n'UserDefinedTypes.DateTimeValue') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[DateTimeValue]
      from
        datetime not null;
    ');
  End;
if type_id(n'UserDefinedTypes.TimeValue') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[TimeValue]
      from
        time(7) not null;
    ');
  End;

/*
 *  (7) etc.
 */

if type_id(n'UserDefinedTypes.BooleanFlag') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[BooleanFlag]
      from
        bit not null;
    ');
  End;

if type_id(n'UserDefinedTypes.ImageBinary') is null
  Begin
    exec(n'
      create type
        [UserDefinedTypes].[ImageBinary]
      from
        varbinary(max) not null;
    ');
  End;
