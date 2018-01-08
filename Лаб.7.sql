USE House_Managment
GO

DROP USER [test]
GO
DROP USER [test1]
GO
DROP ROLE [test_role]
GO


DROP LOGIN [test]
GO
DROP LOGIN [test1]
GO

CREATE LOGIN [test] WITH PASSWORD = 'test', 
DEFAULT_DATABASE = [House_Managment]
GO

CREATE USER [test] FOR LOGIN [test]
--CREATE USER [error] FOR LOGIN [test]
GO

CREATE LOGIN [test1] WITH PASSWORD = 'test1', DEFAULT_DATABASE = [House_Managment]
GO

CREATE USER [test1] FOR LOGIN [test1]
GO
GRANT CREATE TABLE TO [test]
GRANT SELECT, INSERT, UPDATE 
	ON [Service] TO [test]

GRANT SELECT (Account_ID), UPDATE (Score)
	ON [Quality_of_service] TO [test]

GRANT SELECT 
	ON Flat TO [test]
WITH GRANT OPTION

--REVOKE SELECT ON Flat TO [test] CASCADE

--SELECT * FROM [Quality_of_service]

GRANT SELECT
	ON [Houses_and_Services] TO test

DENY SELECT ON Debt TO [test] 
GRANT SELECT ON Debt TO [test]

CREATE ROLE test_role 
GRANT UPDATE (service)
	ON [Houses_and_Services]
	TO test_role
EXEC sp_addrolemember 'test_role', 'test'
