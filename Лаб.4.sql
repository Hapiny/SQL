USE [House_Managment]
GO
--1)Определить задолженность по оплате "вывоз мусора" Константинова Романа Викторовича
SELECT [Surname], [Name], [Patronymic], Service.Description, SUM(Debt_rest) AS Total_Debt
FROM Owner
JOIN Ownership ON Owner.ID = Ownership.Owner_ID
JOIN Account ON Account.Ownership_ID = Ownership.ID
JOIN Debt ON Debt.Account_ID = Account.ID
JOIN Debt_payment ON Debt_payment.Debt_ID = Debt.ID  
JOIN Debt_report ON Debt_report.Debt_payment_ID = Debt_payment.ID
JOIN [Service] ON Debt.Service_ID = Service.ID
WHERE [Surname] = 'Константинов' AND [Name] = 'Роман' AND [Patronymic] = 'Викторович' 
								 AND Service.Description = 'вывоз мусора'
								 AND Status_of_Debt = 1
GROUP BY [Surname], [Name], [Patronymic], Service.Description
------------------------------------------------------------------------------------------------
--2)Определить среднюю сумму месячной оплаты для квартиры №50 в доме 302 бис по Садовой улице
SELECT AVG(Average_Payment) 
FROM (
SELECT Street, House_number, Flat_Number, Surname, [Name], Patronymic, SUM(Total_for_payment)/COUNT(DISTINCT Period_ID) AS Average_Payment
FROM Flat
JOIN Ownership ON Ownership.Flat_ID = Flat.ID
JOIN [Owner] ON [Owner].ID = Ownership.Owner_ID
JOIN Account ON Ownership.ID = Account.Ownership_ID
JOIN Receipt ON Receipt.Account_ID = Account.ID
JOIN Period ON Period.ID = Receipt.Period_ID
WHERE Street = 'ул. Садовая' AND House_Number = '302 бис' AND Flat_Number = 50
GROUP BY Street, House_number, Flat_Number, Surname, [Name], Patronymic
) AS q1

------------------------------------------------------------------------------------------------
--3)Определить общюю сумму выплат за "капитальный ремонт" для квартир по Первомайской улице
SELECT Street, House_Number,Flat_Number, SUM(Paid) AS Payment
FROM Receipt
JOIN [Service] ON [Service].ID = Receipt.Service_ID
JOIN Payment ON Receipt.ID = Payment.Receipt_ID
JOIN Account ON Account.ID = Receipt.Account_ID
JOIN Ownership ON Ownership.ID = Account.Ownership_ID
JOIN Flat ON Flat.ID = Ownership.Flat_ID
WHERE Street = 'ул. Первомайская' AND [Description] = 'Капитальный ремонт'
GROUP BY Street, House_Number, Flat_Number
------------------------------------------------------------------------------------------------
--4)Выбрать список владельцев, которые имеют задолженности более года.
SELECT Surname, [Name], Patronymic, Debt_rest,YEAR(getdate())-YEAR([End]) AS Debt_Period
FROM Debt
JOIN Debt_report ON Debt.ID = Debt_report.ID_of_debt
JOIN Account ON Account.ID = Debt.Account_ID
JOIN Ownership ON Ownership.ID = Account.Ownership_ID
JOIN Owner ON Owner.ID = Ownership.Owner_ID
JOIN Period ON Period.ID = Debt.Period_ID 
WHERE Status_of_Debt = 1 AND (YEAR(getdate())-YEAR([End])) > 1
------------------------------------------------------------------------------------------------

--1)Определить клиентов, потребивших наибольшее кол-во Мегабайт интернета когда-либо
SELECT Surname,[Name],Patronymic, Indication_of_counter AS Megabytes
FROM Owner
JOIN Ownership ON Owner.ID = Ownership.Owner_ID
JOIN Account ON Ownership.ID = Account.Ownership_ID
JOIN Receipt ON Receipt.Account_ID = Account.ID
WHERE Indication_of_counter = 
(
	SELECT MAX(Indication_of_counter) As max_consumption
	FROM Service
	JOIN Receipt ON Service.ID = Receipt.Service_ID
	WHERE [Description] = 'Интернет'
)
------------------------------------------------------------------------------------------------
--2)Определить ID тех клиентов, которые пользуются только банком для оплаты или только онлайн платежами
SELECT DISTINCT Account.ID, Payment.Type_of_payment
FROM Account 
JOIN Ownership ON Ownership.ID = Account.Ownership_ID
JOIN Owner ON Owner.ID  = Ownership.Owner_ID
JOIN Receipt ON Account.ID = Receipt.Account_ID
JOIN Payment ON Receipt.ID = Payment.Receipt_ID
JOIN Debt ON Account.ID = Debt.Account_ID
JOIN Debt_Payment ON Debt_payment.Debt_ID = Debt.ID
WHERE Payment.Type_of_payment = 'онлайн' AND Debt_payment.Type_of_payment = 'онлайн'
	OR Payment.Type_of_payment = 'банк' AND Debt_payment.Type_of_payment = 'банк'
ORDER BY Account.ID
------------------------------------------------------------------------------------------------
--3)Вывести все ФИО клиентов, которые пополняли свой кошелек больше чем на 1000 с помощью банка
SELECT Surname,[Name], Patronymic,Source_of_replenishment AS [Type],Replenishment.Sum
FROM Owner
JOIN Ownership ON Ownership.Owner_ID = Owner.ID
JOIN Account ON Account.Ownership_ID = Ownership.ID
JOIN Purse ON Purse.Account_ID = Account.ID
JOIN Replenishment ON Purse.ID = Replenishment.Account_of_charge
WHERE Source_of_replenishment = 'банк' AND Replenishment.Sum > 1000
ORDER BY Account.ID
------------------------------------------------------------------------------------------------
--не сработает из за ограничения уникальности поля Email
UPDATE [Account] SET Email = 'grayworld@gmail.com' WHERE ID = 1
------------------------------------------------------------------------------------------------
--не сработает так как ограничение на оценку >= 0 и <= 10
UPDATE [Quality_of_service] SET Score = 100 WHERE  Score <= 10
------------------------------------------------------------------------------------------------
UPDATE [Owner] 
SET [Name] = SUBSTRING([Name], 1, 1),
	[Patronymic] = SUBSTRING([Patronymic], 1, 1)

SELECT * FROM [Owner]
------------------------------------------------------------------------------------------------
--удалить те оценки качества, которые ниже 5 баллов
SELECT * FROM [Quality_of_service]

DELETE FROM [Quality_of_service]
WHERE Score <= 5
------------------------------------------------------------------------------------------------
--удалить те записи, где долг уже погашен
--не сработает из-за ссылочной целостности между таблицами Debt и Debt_payment
DELETE FROM [Debt]
WHERE Status_of_Debt = 1