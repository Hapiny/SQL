USE [House_Managment]
GO
SELECT @@SPID AS 'Process ID'
SELECT @@TRANCOUNT AS 'Qty of transactions'

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ 
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1

---------------------------------------------------------------------
--�1.���������� � ����� ������� ������� �������� READ UNCOMMITTED. 
--��������� �������� �������� ������� 
--�������� ���������� ��������� � ������� ������.
--1)���������� ��������� (�� �����������)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
UPDATE [Privileges] SET [Discount] = 88 WHERE [ID] = 1
COMMIT
--2)������� ������ (�����������)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
---------------------------------------------------------------------
--�2.���������� � ����� ������� ������� �������� READ COMMITTED. 
--��������� �������� �������� ������� 
--�������� ������� ������ � ��������������� ������.
--1)������� ������ (�� �����������)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
--2)��������������� ������ (�����������)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
---------------------------------------------------------------------
--�3.���������� � ����� ������� ������� �������� REPEATABLE READ. 
--��������� �������� �������� 
--������� �������� ��������������� ������ � ��������.
--1)��������������� ������ (�� �����������)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [ID] = 1
COMMIT
--2)������ (�����������)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [Discount] BETWEEN 10 AND 15
COMMIT
---------------------------------------------------------------------
--�4.���������� � ����� ������� ������� �������� SERIALIZABLE. 
--��������� �������� �������� ������� ��������.
--1)������ (�� �����������)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
SELECT [Description],[Discount] FROM [Privileges] 
WHERE [Discount] BETWEEN 10 AND 15
COMMIT
---------------------------------------------------------------------
--�5. Deadlock
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

--����� ���������� � ������ ������������� ������
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







