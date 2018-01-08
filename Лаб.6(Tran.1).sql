USE [House_Managment]
GO
SELECT @@SPID AS 'Process ID'
SELECT @@TRANCOUNT AS 'Qty of transactions'

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1

---------------------------------------------------------------------
--№1.Установить в обоих сеансах уровень изоляции READ UNCOMMITTED. 
--Выполнить сценарии проверки наличия 
--аномалий потерянных изменений и грязных чтений.
--1)Потерянные изменения (не допускается)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
UPDATE [Privileges] SET [Discount] = 88 WHERE [ID] = 1
COMMIT
--2)Грязное чтение (допускается)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
---------------------------------------------------------------------
--№2.Установить в обоих сеансах уровень изоляции READ COMMITTED. 
--Выполнить сценарии проверки наличия 
--аномалий грязных чтений и неповторяющихся чтений.
--1)Грязное чтение (не допускается)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
--2)Неповторяющееся чтение (допускается)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
---------------------------------------------------------------------
--№3.Установить в обоих сеансах уровень изоляции REPEATABLE READ. 
--Выполнить сценарии проверки 
--наличия аномалий неповторяющихся чтений и фантомов.
--1)Неповторяющееся чтение (не допускается)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
--2)Фантом (допускается)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [Discount] BETWEEN 10 AND 15
COMMIT
---------------------------------------------------------------------
--№4.Установить в обоих сеансах уровень изоляции SERIALIZABLE. 
--Выполнить сценарий проверки наличия фантомов.
--1)Фантом (не допускается)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [Discount] BETWEEN 10 AND 15
COMMIT
---------------------------------------------------------------------
--№5. Deadlock
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
UPDATE [Privileges] SET [Discount] = 88 WHERE [ID] = 2
COMMIT
---------------------------------------------------------------------

SELECT @@TRANCOUNT
BEGIN TRAN First
BEGIN TRAN Second
COMMIT TRAN SECOND
COMMIT TRAN FIRST

--Откат транзакции в случае возникновения ошибки
BEGIN TRY
	BEGIN TRAN With_Error
	--SELECT * FROM [Privileges]
	--WHERE [ID] = 9 
	DELETE FROM [Privileges]  WHERE [ID] = 9
	COMMIT TRAN With_Error
END TRY
BEGIN CATCH
	ROLLBACK TRAN With_Error;
	SELECT ERROR_MESSAGE() AS 'Error Message'
END CATCH;







