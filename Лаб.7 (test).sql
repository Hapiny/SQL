USE House_Managment
GO

SELECT USER

SELECT * FROM Owner
SELECT * FROM [Service]

INSERT INTO [Service] ([Description], Charge_Type, Measure_Unit) VALUES ('Тест','Тест','Тест')

SELECT * FROM [Quality_of_service]

UPDATE [Quality_of_service]
	SET Score = 7 

SELECT * FROM Flat
SELECT * FROM [Houses_and_Services]

GRANT SELECT 
	ON Flat TO [test1]

REVOKE SELECT ON Flat FROM [test1]


SELECT * FROM Debt

