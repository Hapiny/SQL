USE [House_Managment]
GO
SELECT @@TRANCOUNT AS 'Qty of transactions'
--Подготовленные скрипты должны работать с одной из таблиц, 
--созданных в практическом задании №3.
---------------------------------------------------------------------
--№1.Установить в обоих сеансах уровень изоляции READ UNCOMMITTED. 
--Выполнить сценарии проверки наличия 
--аномалий потерянных изменений и грязных чтений.
--1)Потерянные изменения (не допускается)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
UPDATE [Privileges] SET [Discount] = 10 WHERE [ID] = 1
ROLLBACK
--2)Грязное чтение (допускается)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
ROLLBACK

---------------------------------------------------------------------
--№2.Установить в обоих сеансах уровень изоляции READ COMMITTED. 
--Выполнить сценарии проверки наличия 
--аномалий грязных чтений и неповторяющихся чтений.
--1)Грязное чтение (не допускается)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
ROLLBACK

--2)Неповторяющееся чтение (допускается)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
COMMIT

---------------------------------------------------------------------
--№3.Установить в обоих сеансах уровень изоляции REPEATABLE READ. 
--Выполнить сценарии проверки 
--наличия аномалий неповторяющихся чтений и фантомов.
--1)Неповторяющееся чтение (не допускается)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
ROLLBACK

--2)Фантом (допускается)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
INSERT INTO [Privileges] ([Description],[Discount]) VALUES ('Акция',14)
COMMIT

---------------------------------------------------------------------
--№4.Установить в обоих сеансах уровень изоляции SERIALIZABLE. 
--Выполнить сценарий проверки наличия фантомов.
--1)Фантом (не допускается)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
INSERT INTO [Privileges] ([Description],[Discount]) VALUES ('Акция',14)
COMMIT

---------------------------------------------------------------------
--№5. Deadlock
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 2
UPDATE [Privileges] SET [Discount] = 88 WHERE [ID] = 1
COMMIT
---------------------------------------------------------------------

