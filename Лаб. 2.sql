CREATE DATABASE [House_Managment]
GO

USE [House_Managment]
GO 

CREATE TABLE [Owner](
	ID smallint IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	Surname nvarchar(30) NOT NULL,
	[Name] nvarchar(30) NOT NULL,
	[Patronymic] nvarchar(30) NULL
)

CREATE TABLE [Account](
	ID smallint IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Password] nvarchar(20) NOT NULL,
	Registration_Date DATETIME NOT NULL,
)


CREATE TABLE [Flat](
	ID smallint IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	Flat_Number smallint NOT NULL,
	Entrance_Number smallint NOT NULL,
	House_Number smallint NOT NULL,
	Street nvarchar(30) NOT NULL,
	Area smallint NOT NULL
)

CREATE TABLE [Ownership] (
	Flat_id smallint NOT NULL FOREIGN KEY REFERENCES [Flat] (ID),
	Owner_id smallint NOT NULL FOREIGN KEY REFERENCES [Owner] (ID),
	Share float NOT NULL,
	[Start_Date] DATETIME NOT NULL,
	[End_Date] DATETIME NULL,
	Account_ID smallint NOT NULL FOREIGN KEY REFERENCES [Account] (ID)
)

CREATE TABLE [Service] (
	ID smallint IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Description] nvarchar(50) NOT NULL,
	Counter bit NOT NULL,
	Measure_Unit nvarchar(10) NOT NULL 
)

CREATE TABLE [Price] (
	Service_ID smallint NOT NULL FOREIGN KEY REFERENCES [Service] (ID),
	[Start_Date] DATETIME NOT NULL,
	[End_Date] DATETIME NULL,
	Price_Unit numeric NOT NULL  
)

CREATE TABLE [Payment] (
	Service_ID smallint NOT NULL FOREIGN KEY REFERENCES [Service] (ID),
	Flat_ID smallint NOT NULL FOREIGN KEY REFERENCES [Flat] (ID), 
	Payment_Term DATETIME NOT NULL,
	Payment_Date DATETIME NULL,
	Quantity smallint NULL,
	Paid numeric(8,2),
	Total numeric(8,2)
)

CREATE TABLE [Debt] (
	Service_ID smallint NOT NULL FOREIGN KEY REFERENCES [Service] (ID),
	Flat_ID smallint NOT NULL FOREIGN KEY REFERENCES [Flat] (ID), 
	Total smallint NOT NULL,
	[Start_Date] DATETIME NOT NULL,
 	[End_Date] DATETIME NULL
)