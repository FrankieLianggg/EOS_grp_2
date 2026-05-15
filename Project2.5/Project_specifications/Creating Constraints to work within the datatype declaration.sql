use [PrestigeCars]
go

/****** Object:  Table [Data].[Country]    Script Date: 4/27/2021 11:22:14 AM ******/
set ansi_nulls on
go

set quoted_identifier on
go

create table [Data].[Country](
	[CountryId] [Udt].[SurrogateKeyInt] identity(1,1) not null,
	[CountryName] [Udt].[CountryName] not null,
	[CountryISO2] [Udt].[ISO2] not null,
	[CountryISO3] [Udt].[ISO3] not null,
	[SalesRegionId] [Udt].[SurrogateKeyInt] not null,
 constraint [PK_Country] primary key clustered 
(
	[CountryId] asc
)with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on, optimize_for_sequential_key = off) on [PRIMARY]
) on [PRIMARY]
go

alter table [Data].[Country]  with check add  constraint [FK_Country_SalesRegion] foreign key([SalesRegionId])
references [Data].[SalesRegion] ([SalesRegionId])
go

alter table [Data].[Country] check constraint [FK_Country_SalesRegion]
go

alter table [Data].[Country]  with check add  constraint [CK_CountryISO2] check  (([CountryISO2] like '[A-Z][A-Z]'))
go

alter table [Data].[Country] check constraint [CK_CountryISO2]
go

alter table [Data].[Country]  with check add  constraint [CK_CountryISO3] check  (([CountryISO3] like '[A-Z][A-Z][A-Z]'))
go

alter table [Data].[Country] check constraint [CK_CountryISO3]
go


