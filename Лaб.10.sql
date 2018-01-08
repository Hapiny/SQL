USE [House_Managment]
GO

DROP TABLE [Owner_Large]
DROP TABLE [Owner_Large_Index]

SELECT * INTO Owner_Large FROM [Owner]
SELECT * INTO Owner_Large_Index FROM [Owner]

INSERT INTO [Owner_Large] (Surname, [Name]) SELECT Surname, [Name] FROM [Owner]
GO 100000

INSERT INTO [Owner_Large_Index] (Surname, [Name]) SELECT Surname, [Name] FROM [Owner]
GO 100000

SELECT * FROM [Owner_Large]
SELECT * FROM [Owner_Large_Index]

SET STATISTICS TIME ON
SET STATISTICS IO ON

CREATE NONCLUSTERED INDEX [IX_Owner] ON [Owner_Large_Index]
(  
	Surname,
	[Name] 
)

SELECT Surname, [Name] FROM Owner_Large
WHERE Surname = 'Семенов' AND [Name] = 'Максим'

SELECT Surname, [Name] FROM Owner_Large_Index
WHERE Surname = 'Семенов' AND [Name] = 'Максим'
GO