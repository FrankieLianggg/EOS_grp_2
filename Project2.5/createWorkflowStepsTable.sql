--created schema
CREATE SCHEMA [Process];
--created table
CREATE TABLE [Process].[WorkflowSteps] (
    ID INT PRIMARY KEY
);

--add columns to the table
ALTER TABLE [Process].[WorkflowSteps]
ADD AssignedTo NVARCHAR(100) NULL,
    CompletedBy NVARCHAR(100) NULL;

---backup tables before normalization
SELECT * INTO Data.Country_Backup FROM Data.Country;
SELECT * INTO Data.Customer_Backup FROM Data.Customer;


----ADD/REMOVE COLUMNS For Normalization

ALTER TABLE Data.Country ADD SalesRegionId INT NULL;
ALTER TABLE Data.Country DROP COLUMN SalesRegion;
ALTER TABLE Data.Country DROP COLUMN CountryFlag;
ALTER TABLE Data.Country DROP COLUMN FlagFileName;
ALTER TABLE Data.Country DROP COLUMN FlagFileType;

ALTER TABLE Data.Customer ADD CountryId INT NULL;
ALTER TABLE Data.Customer DROP COLUMN Country;

--create new table for sales region to fill the sales region data and link to country table
CREATE TABLE Data.SalesRegion (
    SalesRegionId INT IDENTITY(1,1) NOT NULL,
    SalesRegion NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_SalesRegion PRIMARY KEY (SalesRegionId)
);
--insert distinct sales region data into the new table
INSERT INTO Data.SalesRegion (SalesRegion)
SELECT DISTINCT SalesRegion 
FROM Data.Country_Backup
WHERE SalesRegion IS NOT NULL;
--update the country table to link to the sales region table using the backup data
UPDATE c
SET c.SalesRegionId = sr.SalesRegionId
FROM Data.Country c
INNER JOIN Data.Country_Backup cb 
    ON c.CountryName = cb.CountryName
INNER JOIN Data.SalesRegion sr 
    ON sr.SalesRegion = cb.SalesRegion;

---check the data after normalization
select * from Data.Country;
select * from Data.Country_Backup;
select* from Data.SalesRegion;

---Add PK to Data.Country first
ALTER TABLE Data.Country 
ADD CountryId INT IDENTITY(1,1) NOT NULL;
ALTER TABLE Data.Country 
ADD CONSTRAINT PK_Country PRIMARY KEY (CountryId);

-- Update CountryId in Customer using ISO2 code from backup
UPDATE c
SET c.CountryId = co.CountryId
FROM Data.Customer c
INNER JOIN Data.Customer_Backup cb 
    ON c.CustomerID = cb.CustomerID
INNER JOIN Data.Country co 
    ON co.CountryISO2 = cb.Country;

-- Verify
select * from Data.Customer;
select * from Data.Customer_Backup;

/*Created by Prabjot, Edited by Frankie and verified by Brandon*/