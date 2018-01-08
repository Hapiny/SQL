USE [House_Managment]
GO

IF EXISTS
(
	SELECT * FROM sys.objects so
	WHERE so.type = 'TR' AND so.name = 'Payment_Ahead'
) 
	DROP TRIGGER Payment_Ahead
ELSE 
	PRINT 'Trigger "Payment_Ahead" does not exist'
GO
--------------------------------------------------------------------------------------------------------------------------
-- ќплата не может производитс€ на срок более, чем 12 мес€цев вперед

CREATE TRIGGER Payment_Ahead  
ON [Receipt]
AFTER INSERT
AS
IF 2 = (
	SELECT COUNT(r.ID)
	FROM [Receipt] r, [INSERTED] i
	WHERE r.Account_ID = i.Account_ID AND
		r.Service_ID = i.Service_ID AND
		r.Period_ID = i.Period_ID  
)
BEGIN
	RAISERROR('Bad row: “ака€ запись уже существует.', 16, 10)
	ROLLBACK
END

DECLARE @is_counter varchar(5), @period int
SELECT @is_counter = dbo.counter(s.Charge_Type), @period = i.Period_ID
FROM [INSERTED] i
JOIN [Service] s ON i.Service_ID = s.ID 

IF (@is_counter = 'TRUE') AND (@period - dbo.get_current_period() > 0)
BEGIN
	RAISERROR('Bad service: Ќельз€ оплачивать эту услугу заранее.', 16, 10)
	ROLLBACK
END

IF (@period - dbo.get_current_period() > 12)
BEGIN
	RAISERROR('Bad period: Ќельз€ оплачивать более, чем на 12 мес€цев вперед .', 16, 10)
	ROLLBACK
END

--------------------------------------------------------------------------------------------------------------------------
-- SELECT * FROM [Receipt]
-- SELECT * FROM [Service]
-- SELECT * FROM [Period]
-- SELECT dbo.get_current_period()
-- INSERT [Receipt] (Account_ID, Service_ID, Period_ID, Indication_of_counter) VALUES (1,6,85,1)
-- INSERT [Receipt] (Account_ID, Service_ID, Period_ID, Indication_of_counter) VALUES (1,1,229,1)
-- INSERT [Receipt] (Account_ID, Service_ID, Period_ID, Indication_of_counter) VALUES (1,6,241,1)
-- INSERT [Receipt] (Account_ID, Service_ID, Period_ID, Indication_of_counter) VALUES (1,6,229,1)





