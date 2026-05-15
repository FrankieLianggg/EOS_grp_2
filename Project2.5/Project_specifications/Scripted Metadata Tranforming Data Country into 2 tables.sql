USE [PrestigeCars]
GO
/****** Object:  Schema [Udt]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE SCHEMA [Udt]
GO
/****** Object:  Schema [Utils]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE SCHEMA [Utils]
GO
/****** Object:  UserDefinedDataType [Udt].[CountryName]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE TYPE [Udt].[CountryName] FROM [nvarchar](15) NOT NULL
GO
/****** Object:  UserDefinedDataType [Udt].[ISO2]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE TYPE [Udt].[ISO2] FROM [nchar](2) NULL
GO
/****** Object:  UserDefinedDataType [Udt].[ISO3]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE TYPE [Udt].[ISO3] FROM [nchar](3) NULL
GO
/****** Object:  UserDefinedDataType [Udt].[SalesRegion]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE TYPE [Udt].[SalesRegion] FROM [nvarchar](15) NULL
GO
/****** Object:  UserDefinedDataType [Udt].[SurrogateKeyInt]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE TYPE [Udt].[SurrogateKeyInt] FROM [int] NULL
GO
/****** Object:  View [Utils].[uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint]    Script Date: 4/23/2021 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Utils].[uvw_FindColumnDefinitionPlusDefaultAndCheckConstraint]
as
select concat(tbl.TABLE_SCHEMA, '.', tbl.TABLE_NAME)   as FullyQualifiedTableName
     , tbl.TABLE_SCHEMA                                as SchemaName
     , tbl.TABLE_NAME                                  as TableName
     , col.COLUMN_NAME                                 as ColumnName
     , col.ORDINAL_POSITION                            as OrdinalPosition
     , concat(col.DOMAIN_SCHEMA, '.', col.DOMAIN_NAME) as FullyQualifiedDomainName
     , col.DOMAIN_NAME                                 as DomainName
     , case
           when col.DATA_TYPE = 'varchar' then
               concat('varchar(', CHARACTER_MAXIMUM_LENGTH, ')')
           when col.DATA_TYPE = 'char' then
               concat('char(', CHARACTER_MAXIMUM_LENGTH, ')')
           when col.DATA_TYPE = 'nvarchar' then
               concat('nvarchar(', CHARACTER_MAXIMUM_LENGTH, ')')
           when col.DATA_TYPE = 'nchar' then
               concat('nchar(', CHARACTER_MAXIMUM_LENGTH, ')')
           when col.DATA_TYPE = 'numeric' then
               concat('numeric(', NUMERIC_PRECISION_RADIX, ', ', NUMERIC_SCALE, ')')
           when col.DATA_TYPE = 'decimal' then
               concat('decimal(', NUMERIC_PRECISION_RADIX, ', ', NUMERIC_SCALE, ')')
           else
               col.DATA_TYPE
       end                                             as DataType
     , col.IS_NULLABLE                                 as IsNullable
     , dcn.DefaultName
     , col.COLUMN_DEFAULT                              as DefaultNameDefinition
     , cc.CONSTRAINT_NAME                              as CheckConstraintRuleName
     , cc.CHECK_CLAUSE                                 as CheckConstraintRuleNameDefinition
from
(
    select TABLE_CATALOG
         , TABLE_SCHEMA
         , TABLE_NAME
         , TABLE_TYPE
    from INFORMATION_SCHEMA.TABLES
    where (TABLE_TYPE = 'BASE TABLE')
)     as tbl
    inner join
    (
        select TABLE_CATALOG
             , TABLE_SCHEMA
             , TABLE_NAME
             , COLUMN_NAME
             , ORDINAL_POSITION
             , COLUMN_DEFAULT
             , IS_NULLABLE
             , DATA_TYPE
             , CHARACTER_MAXIMUM_LENGTH
             , CHARACTER_OCTET_LENGTH
             , NUMERIC_PRECISION
             , NUMERIC_PRECISION_RADIX
             , NUMERIC_SCALE
             , DATETIME_PRECISION
             , CHARACTER_SET_CATALOG
             , CHARACTER_SET_SCHEMA
             , CHARACTER_SET_NAME
             , COLLATION_CATALOG
             , COLLATION_SCHEMA
             , COLLATION_NAME
             , DOMAIN_CATALOG
             , DOMAIN_SCHEMA
             , DOMAIN_NAME
        from INFORMATION_SCHEMA.COLUMNS
    ) as col
        on col.TABLE_CATALOG = tbl.TABLE_CATALOG
           and col.TABLE_SCHEMA = tbl.TABLE_SCHEMA
           and col.TABLE_NAME = tbl.TABLE_NAME
    left outer join
    (
        select t.name                   as TableName
             , schema_name(s.schema_id) as SchemaName
             , ac.name                  as ColumnName
             , d.name                   as DefaultName
        from sys.all_columns                   as ac
            inner join sys.tables              as t
                on ac.object_id = t.object_id
            inner join sys.schemas             as s
                on t.schema_id = s.schema_id
            inner join sys.default_constraints as d
                on ac.default_object_id = d.object_id
    ) as dcn
        on dcn.SchemaName = tbl.TABLE_SCHEMA
           and dcn.TableName = tbl.TABLE_NAME
           and dcn.ColumnName = col.COLUMN_NAME
    left outer join
    (
        select cu.TABLE_CATALOG
             , cu.TABLE_SCHEMA
             , cu.TABLE_NAME
             , cu.COLUMN_NAME
             , c.CONSTRAINT_CATALOG
             , c.CONSTRAINT_SCHEMA
             , c.CONSTRAINT_NAME
             , c.CHECK_CLAUSE
        from INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE     as cu
            inner join INFORMATION_SCHEMA.CHECK_CONSTRAINTS as c
                on c.CONSTRAINT_NAME = cu.CONSTRAINT_NAME
    ) as cc
        on cc.TABLE_SCHEMA = tbl.TABLE_SCHEMA
           and cc.TABLE_NAME = tbl.TABLE_NAME
           and cc.COLUMN_NAME = col.COLUMN_NAME;


GO
/****** Object:  Table [Data].[Country]    Script Date: 4/23/2021 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[Country](
	[CountryId] [Udt].[SurrogateKeyInt] IDENTITY(1,1) NOT NULL,
	[CountryName] [Udt].[CountryName] NOT NULL,
	[CountryISO2] [Udt].[ISO2] NOT NULL,
	[CountryISO3] [Udt].[ISO3] NOT NULL,
	[SalesRegionId] [Udt].[SurrogateKeyInt] NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Data].[SalesRegion]    Script Date: 4/23/2021 9:21:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Data].[SalesRegion](
	[SalesRegionId] [Udt].[SurrogateKeyInt] IDENTITY(1,1) NOT NULL,
	[SalesRegion] [Udt].[SalesRegion] NOT NULL,
 CONSTRAINT [PK_SalesRegion] PRIMARY KEY CLUSTERED 
(
	[SalesRegionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueCoutryName_idx]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UniqueCoutryName_idx] ON [Data].[Country]
(
	[CountryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueCoutryNameISO2_idx]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE NONCLUSTERED INDEX [UniqueCoutryNameISO2_idx] ON [Data].[Country]
(
	[CountryISO2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueCoutryNameISO3_idx]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UniqueCoutryNameISO3_idx] ON [Data].[Country]
(
	[CountryISO3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UniqueSalesRegionName_idx]    Script Date: 4/23/2021 9:21:49 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UniqueSalesRegionName_idx] ON [Data].[SalesRegion]
(
	[SalesRegion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Data].[Country]  WITH CHECK ADD  CONSTRAINT [FK_Country_SalesRegion] FOREIGN KEY([SalesRegionId])
REFERENCES [Data].[SalesRegion] ([SalesRegionId])
GO
ALTER TABLE [Data].[Country] CHECK CONSTRAINT [FK_Country_SalesRegion]
GO
ALTER TABLE [Data].[Country]  WITH CHECK ADD  CONSTRAINT [CK_CountryISO2] CHECK  ((len([CountryISO2])=(2)))
GO
ALTER TABLE [Data].[Country] CHECK CONSTRAINT [CK_CountryISO2]
GO
ALTER TABLE [Data].[Country]  WITH CHECK ADD  CONSTRAINT [CK_CountryISo3] CHECK  ((len([CountryISO3])=(3)))
GO
ALTER TABLE [Data].[Country] CHECK CONSTRAINT [CK_CountryISo3]
GO
