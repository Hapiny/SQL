USE [House_Managment]
GO
------------------------------------------------------------------------------------------------
--1)Год, дом, квартира, задолженность по оплате.
DROP VIEW [Arrears of payment]
GO
CREATE VIEW [Arrears of payment] AS
	SELECT YEAR(Start) [Year],Flat.House_Number [House Number],Flat.Flat_Number [Flat Number],SUM(Debt_rest) [Debt]
	FROM Flat
	JOIN Ownership ON Ownership.Flat_ID = Flat.ID
	JOIN Account ON Account.Ownership_ID = Ownership.ID 
	JOIN Debt ON Debt.Account_ID = Account.ID
	JOIN Period ON Period.ID = Debt.Period_ID
	JOIN Debt_Report ON Debt_Report.ID_of_debt = Debt.ID
	WHERE Debt_rest != 0
	GROUP BY YEAR(Start), House_Number, Flat_Number
	WITH CHECK OPTION;
GO
SELECT * FROM [Arrears of payment]
--Нельзя обновлять данные через представление, потому что оно является НЕ модифицируемым, 
--так как содержит в себе агрегатные функции и предложение GROUP BY
--НЕ СРАБОТАЕТ
UPDATE [Arrears of payment] SET [Flat Number] = 10 WHERE [Flat Number] = 30
UPDATE [Arrears of payment] SET [House Number] = 25 WHERE [House Number] = 50
UPDATE [Arrears of payment] SET  Debt = 0.0 WHERE  Debt = 110.0
UPDATE [Arrears of payment] SET Year = 2000 WHERE Year = 2006

DELETE FROM [Arrears of payment] WHERE Debt <= 10.0
INSERT INTO [Arrears of payment] ([Year],[House Number],[Flat Number], Debt) VALUES (2010, 50, 30, 500)
------------------------------------------------------------------------------------------------
--2)Вид услуг, наличие счетчика, внесенная сумма оплаты за год, количество человек, оплативших услугу.
DROP VIEW [Total for each service]
GO
CREATE VIEW [Total for each service] AS
	SELECT dbo.get_description(Service.ID) AS [Service], 
		dbo.counter(Service.Charge_Type) AS [Counter],
        SUM(Payment.Paid) AS Total, 
        COUNT(DISTINCT Receipt.Account_ID) AS [NUM],
		YEAR(Date_of_payment) AS [YEAR]
	FROM [Service]
	JOIN Receipt ON Service.ID = Receipt.Service_ID
	JOIN Payment ON Receipt.ID = Payment.Receipt_ID
	GROUP BY [Service].ID, Service.Charge_Type, YEAR(Date_of_payment)
GO
SELECT * FROM [Total for each service]

UPDATE [Total for each service] SET [Service] = 'Уборка мусорв' WHERE [Service] = 'Вывоз мусора'
UPDATE [Total for each service] SET [Counter] = 'TRUE'
------------------------------------------------------------------------------------------------
--3)Владелец, услуга, затраты на услугу в год, средняя сумма оплаты за услугу в месяц.
DROP VIEW [Owners and Services]
GO
CREATE VIEW [Owners and Services] AS
	SELECT [Surname], [Name], [Patronymic],
		dbo.get_description([Service].ID) AS 'Service',
		SUM(Receipt.Total_for_payment) AS [Expenses for the year],
		AVG(Payment.Paid) AS [Monthly average],
		YEAR(Payment.Date_of_payment) AS YEAR
	FROM Account
	JOIN Receipt ON Receipt.Account_ID = Account.ID
	JOIN Service ON Receipt.Service_ID = Service.ID
	JOIN Payment ON Payment.Receipt_ID = Receipt.ID
	JOIN Ownership ON Ownership.ID = Account.Ownership_ID
	JOIN Owner ON Owner.ID = Ownership.Owner_ID
	GROUP BY Account.ID, [Surname], [Name], [Patronymic], [Service].ID, YEAR(Payment.Date_of_payment)
GO
SELECT * FROM [Owners and Services]

UPDATE [Owners and Services] SET [Name] = SUBSTRING([Name], 1, 1),
	[Patronymic] = SUBSTRING([Patronymic], 1, 1)
------------------------------------------------------------------------------------------------
--4)Улица, номер дома, услуга, суммарная стоимость за месяц.
DROP VIEW [Houses_and_Services]
GO
CREATE VIEW [Houses_and_Services] AS
	SELECT Street, House_Number,
		dbo.get_description([Service].ID) AS 'Service',
		SUM(Receipt.Total_for_payment) AS [Cost per month],
		DATENAME(MM, Period.Start) AS [Month]
	FROM Account
	JOIN Receipt ON Receipt.Account_ID = Account.ID
	JOIN [Service] ON Service.ID = Receipt.Service_ID
	JOIN Period ON Period.ID = Receipt.Period_ID
	JOIN Ownership ON Ownership.ID = Account.Ownership_ID
	JOIN Flat ON Ownership.Flat_ID = Flat.ID
	GROUP BY Street, House_Number, [Service].ID, DATENAME(MM, Period.Start)
GO
SELECT * FROM [Houses_and_Services]
------------------------------------------------------------------------------------------------
DROP VIEW [Test]
GO
CREATE VIEW [Test] AS
	SELECT Service.ID [ID], [Description] 'Service', [Price_Unit] 'Price'  
	FROM [Service]
	JOIN Price ON [Service].ID = Price.Service_ID
	--GROUP BY Service.ID, Price_Unit
GO

SELECT * FROM [Test]
--СРАБОТАЕТ
UPDATE [Test] SET Price = 100.0 WHERE Price <= 100.0
--НЕ СРАБОТАЕТ
DELETE FROM [Test] WHERE Price <= 10.0
--СРАБОТАЕТ
UPDATE [Test] SET [Service] = 'Update'
--НЕ СРАБОТАЕТ ИЗ-ЗА ССЫЛОЧНОЙ ЦЕЛОСТНОСТИ
SET IDENTITY_INSERT [Test] ON
INSERT [Test] ([ID],[Service], [Price]) VALUES (11,'Доставка почты на дом', 1000000)
SET IDENTITY_INSERT [Test] OFF
------------------------------------------------------------------------------------------------

DROP VIEW [Test2]
GO
CREATE VIEW [Test2] AS
	SELECT s.ID [ID], s.Description
	FROM [Service] s
GO

SELECT * FROM [Test2]
SELECT * FROM [Service]

UPDATE [Test2] SET [Description] = 'Empty'
INSERT [Test2] (Description) VALUES ('Доставка пиццы')
------------------------------------------------------------------------------------------------
DROP VIEW [Test3]
GO
CREATE VIEW [Test3] AS
	SELECT Start [Year],Flat.House_Number [House Number],Flat.Flat_Number [Flat Number]
	FROM Flat
	JOIN Ownership ON Ownership.Flat_ID = Flat.ID
	JOIN Account ON Account.Ownership_ID = Ownership.ID 
	JOIN Debt ON Debt.Account_ID = Account.ID
	JOIN Period ON Period.ID = Debt.Period_ID
	JOIN Debt_Report ON Debt_Report.ID_of_debt = Debt.ID
	WHERE Debt_rest != 0 AND Flat_Number < 1000
	WITH CHECK OPTION;
GO
SELECT * FROM [Test3]
UPDATE [Test3] SET [Flat Number] = 1000 
UPDATE [Test3] SET [Year] = '21-02-2100'