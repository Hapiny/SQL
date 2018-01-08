USE [House_Managment]
GO
------------------------------------------------------------------------------------------------------------------
IF EXISTS
(
	SELECT * FROM sys.objects so
	WHERE so.type = 'TR' AND so.name = 'Test_Trigger'
) 
	DROP TRIGGER [Test_Trigger]
ELSE 
	PRINT 'Trigger "Test_Trigger" does not exist'
GO
------------------------------------------------------------------------------------------------------------------
IF EXISTS
(
	SELECT * FROM sys.objects so
	WHERE so.type = 'U' AND so.name = 'Test_Table'
) 
	DROP TABLE [Test_Table]
ELSE 
	PRINT 'Table "Test_Table" does not exist'
GO
------------------------------------------------------------------------------------------------------------------
CREATE TABLE Test_Table
(
	col1 int NOT NULL,
	col2 tinyint NOT NULL
)
GO
------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER Test_Trigger
ON Test_Table
FOR DELETE 
AS
PRINT 'WORK1'
GO

CREATE TRIGGER Test_Trigger2
ON Test_Table
FOR DELETE 
AS
PRINT 'WORK2'
GO

CREATE TRIGGER Test_Trigger3
ON Test_Table
AFTER DELETE 
AS
IF EXISTS
(	
	SELECT * 
	FROM sys.objects so
	WHERE so.name = 'abcde'
)
PRINT 'WORK3'
ELSE
	PRINT 'NOT'
GO

EXEC sp_settriggerorder @triggername= 'Test_Trigger3', @order='NONE', @stmttype = 'DELETE';

DROP TRIGGER Test_Trigger3
------------------------------------------------------------------------------------------------------------------
SELECT * FROM Test_Table

SELECT * FROM sys.triggers

DELETE Test_Table WHERE col1 = 10
DELETE Test_Table WHERE col1 = 10
DELETE Test_Table WHERE col1 = 10
GO

INSERT Test_Table (col1, col2) VALUES (1,1)
INSERT Test_Table (col1, col2) VALUES (2,2)
INSERT Test_Table (col1, col2) VALUES (3,3)
GO
------------------------------------------------------------------------------------------------------------------




