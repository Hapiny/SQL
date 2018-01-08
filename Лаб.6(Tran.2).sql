USE [House_Managment]
GO
SELECT @@TRANCOUNT AS 'Qty of transactions'
--�������������� ������� ������ �������� � ����� �� ������, 
--��������� � ������������ ������� �3.
---------------------------------------------------------------------
--�1.���������� � ����� ������� ������� �������� READ UNCOMMITTED. 
--��������� �������� �������� ������� 
--�������� ���������� ��������� � ������� ������.
--1)���������� ��������� (�� �����������)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
UPDATE [Privileges] SET [Discount] = 10 WHERE [ID] = 1
ROLLBACK
--2)������� ������ (�����������)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
ROLLBACK

---------------------------------------------------------------------
--�2.���������� � ����� ������� ������� �������� READ COMMITTED. 
--��������� �������� �������� ������� 
--�������� ������� ������ � ��������������� ������.
--1)������� ������ (�� �����������)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
ROLLBACK

--2)��������������� ������ (�����������)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
COMMIT

---------------------------------------------------------------------
--�3.���������� � ����� ������� ������� �������� REPEATABLE READ. 
--��������� �������� �������� 
--������� �������� ��������������� ������ � ��������.
--1)��������������� ������ (�� �����������)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
UPDATE [Privileges] SET [Discount] = 8 WHERE [ID] = 1
ROLLBACK

--2)������ (�����������)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
INSERT INTO [Privileges] ([Description],[Discount]) VALUES ('�����',14)
COMMIT

---------------------------------------------------------------------
--�4.���������� � ����� ������� ������� �������� SERIALIZABLE. 
--��������� �������� �������� ������� ��������.
--1)������ (�� �����������)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
INSERT INTO [Privileges] ([Description],[Discount]) VALUES ('�����',14)
COMMIT

---------------------------------------------------------------------
--�5. Deadlock
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 2
UPDATE [Privileges] SET [Discount] = 88 WHERE [ID] = 1
COMMIT
---------------------------------------------------------------------

