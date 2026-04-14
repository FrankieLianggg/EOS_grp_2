/* Exercise 1
 * Run the following code to create the dbo.Customers table in the TSQLV6 database:
 */ 
USE Northwinds2024Student;
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.[Orders];
CREATE TABLE dbo.Customers
(
  custid INT NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country NVARCHAR(15) NOT NULL,
  region NVARCHAR(15) NULL,
  city NVARCHAR(15) NOT NULL
);
/* 
 * Exercise 1-1
 * Insert into the dbo.Customers table a row with the following information:
 * ■ custid: 100
 * ■ companyname: &oho Winery
 * ■ country: USA
 * ■ region: WA
 * ■ city: Redmond
 */
INSERT INTO
  dbo.Customers (custid, companyname, country, region, city)
VALUES
  (100, 'Soho Winery', 'USA', 'WA', 'Redmond')
;
go
  


/*
 * Exercise 1-2
 * Insert into the dbo.Customers table all customers from Sales.Customers who placed orders.
 */
 --select top(1) * from Sales.Customer
 ;with CustomersWithOrders as
 (
	select
		C.CustomerId,
		C.CustomerCompanyName,
		C.CustomerContactName,
		C.CustomerContactTitle,
		C.CustomerAddress,
		C.CustomerCity,
		C.CustomerRegion,
		C.CustomerPostalCode,
		C.CustomerCountry,
		C.CustomerPhoneNumber,
		C.CustomerFaxNumber
	from
		Sales.[Customer] as C
	inner join	
		Sales.[Order] as O
	on 
		C.CustomerId = O.CustomerId
	group by
		C.CustomerId,
		C.CustomerCompanyName,
		C.CustomerContactName,
		C.CustomerContactTitle,
		C.CustomerAddress,
		C.CustomerCity,
		C.CustomerRegion,
		C.CustomerPostalCode,
		C.CustomerCountry,
		C.CustomerPhoneNumber,
		C.CustomerFaxNumber
 )
 INSERT INTO
	dbo.Customers (custid, companyname, country, region, city)
SELECT
	CustomerId, CustomerCompanyName, CustomerCountry, CustomerRegion, CustomerCity
FROM
	CustomersWithOrders;
go
	

/* 
 * Exercise 1-3
 * Use a SELECT INTO statement to create and populate the dbo.Orders table with orders from the Sales.
 * Orders table that were placed in the years 2020 through 2022.
 */
 --select TOP(1) * from Sales.[Order];
 ;WITH Orders2020to2022 as
 (
	SELECT
		*
	FROM
		Sales.[Order] as O
	WHERE
		O.OrderDate >= '20200101' 
	AND
		O.OrderDate < '20230101'
 )
 SELECT
	*
INTO
	dbo.Orders
FROM
	Orders2020to2022;
GO

/* Exercise 2
 * Delete from the dbo.Orders table orders that were placed before August 2020. Use the OUTPUT clause
 * to return the orderid and orderdate values of the deleted orders:
 * ■ Desired output:
 * orderid orderdate
 * ----------- -----------
 * 10248 2020-07-04
 * 10249 2020-07-05
 * 10250 2020-07-08
 * 10251 2020-07-08
 * 10252 2020-07-09
 * 10253 2020-07-10
 * 10254 2020-07-11
 * 10255 2020-07-12
 * 10256 2020-07-15
 * 10257 2020-07-16
 * 10258 2020-07-17
 * 10259 2020-07-18
 * 10260 2020-07-19
 * 10261 2020-07-19
 * 10262 2020-07-22
 * 10263 2020-07-23
 * 10264 2020-07-24
 * 10265 2020-07-25
 * 10266 2020-07-26
 * 10267 2020-07-29
 * 10268 2020-07-30
 * 10269 2020-07-31
 * (22 rows affected)
 */

;WITH PreAugOrders as
(
	SELECT
		O.OrderId,
		O.OrderDate
	FROM
		dbo.[Orders] as O
	WHERE
		O.OrderDate < '20200801'
)
DELETE FROM 
	PreAugOrders
OUTPUT
	deleted.OrderId,
	deleted.OrderDate;
GO

/*
 * Exercise 3
 * Delete from the dbo.Orders table orders placed by customers from Brazil
 */
 --select TOP (1) * from dbo.Orders
 --select TOP (1) * from dbo.Customer
 ;WITH BrOrders as
 (
	SELECT
		'apple' as apple
	FROM
		dbo.Orders as O
	WHERE
	EXISTS	(
			SELECT	
				'Banana' as Banana
			FROM
				dbo.Customer as C
			WHERE
				C.CustomerID = O.CustomerId
			AND
				C.Country = 'Brazil'
			)
 )
 DELETE FROM 
	BrOrders;
GO

/*
 * Exercise 4
 * Run the following query against dbo.Customers, and notice that some rows have a NULL in the region
 * column:
 */
 SELECT * FROM dbo.Customers;
/*
 * CHAPTER 8 Data PRdifiFatiRn 335
 * The output from this query is as follows:
 * custid companyname country region city
 * ----------- ---------------- --------------- ---------- ---------------
 * 1 Customer NRZBB Germany NULL Berlin
 * 2 Customer MLTDN Mexico NULL México D.F.
 * 3 Customer KBUDE Mexico NULL México D.F.
 * 4 Customer HFBZG UK NULL London
 * 5 Customer HGVLZ Sweden NULL Luleå
 * 6 Customer XHXJV Germany NULL Mannheim
 * 7 Customer QXVLA France NULL Strasbourg
 * 8 Customer QUHWH Spain NULL Madrid
 * 9 Customer RTXGC France NULL Marseille
 * 10 Customer EEALV Canada BC Tsawassen
 * ...
 * (90 rows affected)
 * Update the dbo.Customers table, and change all NULL region values to <None>. Use the OUTPUT
 * clause to show the custid, oldregion, and newregion:
 * ■ Desired output:
 * custid oldregion newregion
 * ----------- --------------- ---------------
 * 1 NULL <None>
 * 2 NULL <None>
 * 3 NULL <None>
 * 4 NULL <None>
 * 5 NULL <None>
 * 6 NULL <None>
 * 7 NULL <None>
 * 8 NULL <None>
 * 9 NULL <None>
 * 11 NULL <None>
 * 12 NULL <None>
 * 13 NULL <None>
 * 14 NULL <None>
 * 16 NULL <None>
 * 17 NULL <None>
 * 18 NULL <None>
 * 19 NULL <None>
 * 20 NULL <None>
 * 23 NULL <None>
 * 24 NULL <None>
 * 25 NULL <None>
 * 26 NULL <None>
 * 27 NULL <None>
 * 28 NULL <None>
 * 29 NULL <None>
 * 30 NULL <None>
 * 39 NULL <None>
 * 40 NULL <None>
 * 41 NULL <None>
 * 44 NULL <None>
 * 49 NULL <None>
 * 50 NULL <None>
 * 52 NULL <None>
 * 53 NULL <None>
 * 54 NULL <None>
 * 56 NULL <None>
 * 58 NULL <None>
 * 336 CHAPTER 8 Data PRdifiFatiRn
 * 59 NULL <None>
 * 60 NULL <None>
 * 63 NULL <None>
 * 64 NULL <None>
 * 66 NULL <None>
 * 68 NULL <None>
 * 69 NULL <None>
 * 70 NULL <None>
 * 72 NULL <None>
 * 73 NULL <None>
 * 74 NULL <None>
 * 76 NULL <None>
 * 79 NULL <None>
 * 80 NULL <None>
 * 83 NULL <None>
 * 84 NULL <None>
 * 85 NULL <None>
 * 86 NULL <None>
 * 87 NULL <None>
 * 90 NULL <None>
 * 91 NULL <None>
 * (58 rows affected)
 */
 --select TOP(1) * from dbo.Customer
 ;WITH NullRegions as
 (
	SELECT
		C.custid,
		C.region
	FROM
		dbo.Customers as C
	WHERE
		C.Region IS NULL
 )
 UPDATE 
	NullRegions
SET
	Region = '<None>'
OUTPUT
	inserted.custid as custid,
	deleted.Region as 'OldRegion',
	inserted.Region as 'NewRegion';
GO

/* 
 * Exercise 5
 * Update all orders in the dbo.Orders table that were placed by United Kingdom customers, and set their
 * shipcountry, shipregion, and shipcity values to the country, region, and city values of the corresponding
 * customers.
 */
 SELECT TOP(1) * from dbo.Orders
 SELECT TOP(1) * from dbo.Customers
 ;WITH UKOrders as
 (
	SELECT
		*
	FROM
		dbo.Orders as O
	INNER JOIN	
		dbo.Customers as C
	ON
		O.CustomerId = C.custid
	WHERE
		C.country = 'UK'
 )
 -- select *  from UKOrders
 UPDATE 
	UKOrders
SET
	ShipToCountry = country,
	ShipToRegion = region,
	ShipToCity = city

/*
 * Exercise 6
 * Run the following code to create the tables dbo.Orders and dbo.OrderDetails and populate them with
 * data:
 * USE TSQLV6;
 */
DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL,
custid INT NULL,
empid INT NOT NULL,
orderdate DATE NOT NULL,
requireddate DATE NOT NULL,
shippeddate DATE NULL,
shipperid INT NOT NULL,
freight MONEY NOT NULL
CONSTRAINT DFT_Orders_freight DEFAULT(0),
shipname NVARCHAR(40) NOT NULL,
shipaddress NVARCHAR(60) NOT NULL,
shipcity NVARCHAR(15) NOT NULL,
shipregion NVARCHAR(15) NULL,
shippostalcode NVARCHAR(10) NULL,
shipcountry NVARCHAR(15) NOT NULL,
CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);
CREATE TABLE dbo.OrderDetails
(
orderid INT NOT NULL,
productid INT NOT NULL,
unitprice MONEY NOT NULL
CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
qty SMALLINT NOT NULL
CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
discount NUMERIC(4, 3) NOT NULL
CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
REFERENCES dbo.Orders(orderid),
CONSTRAINT CHK_discount CHECK (discount BETWEEN 0 AND 1),
CONSTRAINT CHK_qty CHECK (qty > 0),
CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO
INSERT INTO dbo.Orders SELECT * FROM Sales.[Order];
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetail;

/*
 * Write and test the TS4/ code that is required to truncate both tables, and maNe sure your code runs
 * successfully.
 * When you·re done, run the following code for cleanup:
 * DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders, dbo.Customers;
 */

 /*
  * Queries
  */

BEGIN TRY
    BEGIN TRAN;

    INSERT INTO dbo.Customers
        (custid, companyname, country, region, city)
    VALUES
        (101, N'Blue Sky Foods', N'USA', N'NY', N'New York');

    INSERT INTO dbo.Orders
        (
            orderid,
            custid,
            empid,
            orderdate,
            requireddate,
            shippeddate,
            shipperid,
            freight,
            shipname,
            shipaddress,
            shipcity,
            shipregion,
            shippostalcode,
            shipcountry
        )
    VALUES
        (
            30001,
            101,
            3,
            '20260413',
            '20260420',
            NULL,
            2,
            25.00,
            N'Blue Sky Foods',
            N'123 Main Street',
            N'New York',
            N'NY',
            N'10001',
            N'USA'
        );

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;
