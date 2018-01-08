USE [House_Managment]
GO

DROP TABLE [Replenishment]
DROP TABLE [Price]
DROP TABLE [Report]
DROP TABLE [Debt_report]
DROP TABLE [Quality_of_service]
DROP TABLE [Payment]
DROP TABLE [Debt_payment]
DROP TABLE [Receipt]
DROP TABLE [Debt]
DROP TABLE [Service] 
DROP TABLE [Purse]
DROP TABLE [Period]
DROP TABLE [Account]
DROP TABLE [Privileges]
DROP TABLE [Ownership]
DROP TABLE [Owner]
DROP TABLE [Flat]

DROP FUNCTION dbo.get_total_payment
GO

DROP FUNCTION dbo.get_debt_rest
GO

DROP FUNCTION dbo.counter
GO 

DROP FUNCTION dbo.get_description
GO

DROP FUNCTION dbo.get_current_period
GO

CREATE FUNCTION get_current_period()
RETURNS int
AS
BEGIN
	DECLARE @result int;
	SET @result = 0;
	SELECT @result = [ID]
	FROM Period
	WHERE GETDATE() BETWEEN [Start] AND [END]
	IF @result = 0 SET @result = -1;
	RETURN @result
END;
GO

CREATE FUNCTION get_description(@id int)
RETURNS nvarchar(30)
AS 
BEGIN
	DECLARE @result nvarchar(30);
	SELECT @result = [Description]
	FROM [Service]
	WHERE [Service].ID = @id
	RETURN @result
END;
GO 

CREATE FUNCTION counter(@type nvarchar(20))
RETURNS varchar(5)
AS
BEGIN
	DECLARE @result varchar(5);
	IF @type = 'по счетчику' OR @type = 'по тарифу'
	( 
		SELECT @result = 'TRUE'
	);
	ELSE 
	( 
		SELECT @result = 'FALSE'
	);
	RETURN @result;
END;
GO

CREATE TABLE [Replenishment]
(
	Account_of_charge int NOT NULL,
	Sum numeric(8,2) NOT NULL,
	Source_of_replenishment nvarchar(20) NOT NULL,
	Date_of_replenishment datetime NOT NULL
)

CREATE TABLE [Price]
(
	Service_ID int NOT NULL,
	Start_Date datetime NOT NULL,
	End_Date datetime NULL,
	Price_Unit numeric(8,2) NOT NULL
)

CREATE TABLE [Service] 
(
	ID int identity(1,1) NOT NULL,
	Description nvarchar(30) NOT NULL,
	Charge_Type nvarchar(20) NOT NULL,
	Measure_Unit nvarchar(20) NULL,
	CONSTRAINT [PK_Service] PRIMARY KEY ([ID] ASC)
)
GO

CREATE FUNCTION get_total_payment(@Counter numeric(8,2),@Service int)  
RETURNS numeric(8,2)  
AS   
BEGIN  
	DECLARE @result numeric(8,2);  
	IF @Service = 5
	(
		SELECT @result = Price_Unit * (Share * Area / 100) * ((100 - Discount) / 100.0)  
		FROM Receipt
		JOIN Price AS p1 ON Receipt.Service_ID = p1.Service_ID 
		JOIN Account ON Account.ID = Receipt.Account_ID
		JOIN Privileges ON Account.Privilege_ID = Privileges.ID
		JOIN Ownership ON Account.Ownership_ID = Ownership.ID
		JOIN Flat ON Flat.ID = Ownership.Flat_ID 
		JOIN Period ON Period.ID = Receipt.Period_ID 
		WHERE Receipt.Service_ID = @Service   
			AND Receipt.Indication_of_counter = @Counter
			AND p1.End_Date IS NULL OR Period.Start BETWEEN p1.Start_date AND p1.End_Date
	);
	ELSE
	(
		SELECT @result = Price_Unit * Indication_of_counter * ((100 - Discount) / 100.0)
		FROM Receipt
		JOIN Account ON Account.ID = Receipt.Account_ID
		JOIN Privileges ON Privileges.ID = Account.Privilege_ID
		JOIN Price AS p2 ON Receipt.Service_ID = p2.Service_ID  
		JOIN Period ON Period.ID = Receipt.Period_ID 
		WHERE Receipt.Service_ID = @Service   
			AND Receipt.Indication_of_counter = @Counter
			AND p2.End_Date IS NULL OR Period.Start BETWEEN p2.Start_date AND p2.End_Date     
	);
	RETURN @result;
END; 
GO

CREATE TABLE [Receipt] 
(
	ID int identity(1,1) NOT NULL,
	Account_ID int NOT NULL,
	Service_ID int NOT NULL,
	Period_ID int NOT NULL,
	Indication_of_counter numeric(8,2) NOT NULL,
	CONSTRAINT [PK_Receipt] PRIMARY KEY ([ID] ASC)
)

ALTER TABLE [Receipt]
ADD Total_for_payment AS dbo.get_total_payment(Indication_of_counter,Service_ID)

GO

CREATE FUNCTION get_debt_rest(@D_ID int,@P_ID int)  
RETURNS numeric(8,2)  
AS   
BEGIN  
	DECLARE @result numeric(8,2);  
	IF @P_ID IS NULL
	BEGIN
		SELECT @result = Underpaid 
		FROM Debt
		WHERE Debt.ID = @D_ID
	END;
	ELSE
	BEGIN	
		SELECT @result = (Underpaid + Penalty_fee) - Repayment_sum   
		FROM Debt
		JOIN Debt_payment ON Debt_payment.Debt_ID = Debt.ID
		WHERE Debt_payment.ID = @P_ID AND Debt.ID = @D_ID
		IF @result < 0
		BEGIN
			--UPDATE Purse SET Balance = (Balance - @result) WHERE Purse.ID = Debt_report.Monetary_account;
			SET @result = 0
		END;
	END;
	RETURN @result;
END; 
GO

CREATE TABLE [Debt_report]
(
	ID_of_debt int NOT NULL,
	Debt_payment_ID int NULL,
	Monetary_account int NOT NULL
)

ALTER TABLE [Debt_report]
ADD Debt_rest AS dbo.get_debt_rest(ID_of_debt, Debt_payment_ID)

CREATE TABLE [Debt_payment]
(
	ID int identity(1,1) NOT NULL,
	Debt_ID int NOT NULL,
	Type_of_payment nvarchar(20) NOT NULL,
	Repayment_date datetime NOT NULL,
	Repayment_sum numeric(8,2) NOT NULL,
	CONSTRAINT [PK_Debt_payment] PRIMARY KEY ([ID] ASC)
)


CREATE TABLE [Debt](
	ID int identity(1,1) NOT NULL,
	Account_ID int NOT NULL,
	Service_ID int NOT NULL,
	Underpaid numeric(8,2) NOT NULL,
	Period_ID int NOT NULL,
	Status_of_debt bit NOT NULL,
	Penalty_fee numeric(8,2) NOT NULL,
	CONSTRAINT [PK_Debt] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Payment]
(
	ID int identity(1,1) NOT NULL,
	Receipt_ID int NOT NULL,
	Type_of_payment nvarchar(20) NOT NULL,
	Date_of_payment datetime NOT NULL,
	Paid numeric(8,2) NOT NULL,
	CONSTRAINT [PK_Payment] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Report]
(
	Payment_ID int NOT NULL,
	Overpaid numeric(8,2) NULL,
	Underpaid numeric(8,2) NULL,
	Monetary_account int NOT NULL
)

CREATE TABLE [Purse]
(
	ID int identity(1,1) NOT NULL,
	Account_ID int NOT NULL,
	Balance numeric(8,2) NULL,
	CONSTRAINT [PK_Purse] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Period]
(
	ID int identity(1,1) NOT NULL,
	Start datetime NOT NULL,
	[End] datetime NOT NULL
	CONSTRAINT [PK_Period] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Account]
(
	ID int identity(1,1) NOT NULL,
	Password nvarchar(18) NOT NULL,
	Email nvarchar (30) NOT NULL,
	Privilege_ID int NOT NULL,
	Registration_Date datetime NOT NULL,
	Ownership_ID int NOT NULL,
	CONSTRAINT [PK_Account] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Quality_of_service]
(
	Account_ID int NOT NULL,
	Period_ID int NOT NULL,
	Score tinyint NOT NULL,
	Description nvarchar(50) NULL
)

CREATE TABLE [Flat]
(
	ID int identity(1,1) NOT NULL,
	Flat_Number smallint NOT NULL,
	Entrance_Number tinyint NULL,
	House_Number nvarchar(20) NOT NULL,
	Street nvarchar(30) NOT NULL,
	Area numeric(8,2) NOT NULL,
	Number_of_residents tinyint NOT NULL,
	Number_of_owners tinyint NOT NULL,
	CONSTRAINT [PK_Flat] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Privileges]
(
	ID int identity(1,1) NOT NULL,
	Description nvarchar(30) NOT NULL,
	Discount tinyint NOT NULL,
	CONSTRAINT [PK_Privileges] PRIMARY KEY ([ID] ASC)
)

CREATE TABLE [Ownership]
(
	ID int identity(1,1) NOT NULL,
	Flat_ID int NOT NULL,
	Owner_ID int NOT NULL,
	Share tinyint NOT NULL,
	Start_Date datetime NOT NULL,
	End_Date datetime NULL,
	Status nvarchar(20) NOT NULL,
	CONSTRAINT [PK_Ownership] PRIMARY KEY ([ID] ASC)
)


CREATE TABLE [Owner] 
(
	ID int identity(1,1) NOT NULL,
	Surname nvarchar(20) NOT NULL,
	Name nvarchar(20) NOT NULL,
	Patronymic nvarchar(30) NULL,
	CONSTRAINT [PK_Owner] PRIMARY KEY ([ID] ASC)
)


CREATE UNIQUE INDEX [IX_Email] ON [Account]
(
	[Email] ASC
);

ALTER TABLE [Account]
	ADD CONSTRAINT [Ownership Account] FOREIGN KEY (Ownership_ID)
		REFERENCES [Ownership] ([ID]);

ALTER TABLE [Account]
	ADD CONSTRAINT [CK_Password]
		CHECK (LEN([Password]) >= 8 AND LEN([Password]) <= 16)

ALTER TABLE [Ownership]
	ADD CONSTRAINT [CK_Share]
		CHECK ([Share] > 0 AND [Share] <= 100)

ALTER TABLE [Privileges]
	ADD CONSTRAINT [CK_Discount]
		CHECK ([Discount] >= 0 AND [Discount] <= 90);

ALTER TABLE [Quality_of_service]
	ADD CONSTRAINT [CK_Score]
		CHECK ([Score] >= 0 AND [Score] <= 10);

ALTER TABLE [Replenishment]
	ADD CONSTRAINT [Purse Replenishment] FOREIGN KEY (Account_of_charge)
		REFERENCES [Purse] ([ID]); 

ALTER TABLE [Price]
	ADD CONSTRAINT [Service Price] FOREIGN KEY (Service_ID)
		REFERENCES [Service] ([ID]); 

ALTER TABLE [Receipt]
	ADD CONSTRAINT [Service Receipt] FOREIGN KEY (Service_ID)
		REFERENCES [Service] ([ID]); 

ALTER TABLE [Debt]
	ADD CONSTRAINT [Service Debt] FOREIGN KEY (Service_ID)
		REFERENCES [Service] ([ID]); 

ALTER TABLE [Debt_payment]
	ADD CONSTRAINT [Debt Debt_payment] FOREIGN KEY (Debt_ID)
		REFERENCES [Debt] ([ID]); 

ALTER TABLE [Debt_report]
	ADD CONSTRAINT [Debt_payment Debt_report] FOREIGN KEY (Debt_payment_ID)
		REFERENCES [Debt_payment] ([ID]);

ALTER TABLE [Debt_report]
	ADD CONSTRAINT [Debt Debt_report] FOREIGN KEY (ID_of_debt)
		REFERENCES [Debt] ([ID]); 

ALTER TABLE [Debt_report]
	ADD CONSTRAINT [Purse Debt_report] FOREIGN KEY (Monetary_account)
		REFERENCES [Purse] ([ID]); 

ALTER TABLE [Purse]
	ADD CONSTRAINT [Account Purse] FOREIGN KEY (Account_ID)
		REFERENCES [Account] ([ID]); 

ALTER TABLE [Debt]
	ADD CONSTRAINT [Account Debt] FOREIGN KEY (Account_ID)
		REFERENCES [Account] ([ID]); 

ALTER TABLE [Receipt]
	ADD CONSTRAINT [Account Receipt] FOREIGN KEY (Account_ID)
		REFERENCES [Account] ([ID]); 

ALTER TABLE [Payment]
	ADD CONSTRAINT [Receipt Payment] FOREIGN KEY (Receipt_ID)
		REFERENCES [Receipt] ([ID]); 

ALTER TABLE [Report]
	ADD CONSTRAINT [Payment Report] FOREIGN KEY (Payment_ID)
		REFERENCES [Payment] ([ID]); 

ALTER TABLE [Report]
	ADD CONSTRAINT [Purse Report] FOREIGN KEY (Monetary_account)
		REFERENCES [Purse] ([ID]); 

ALTER TABLE [Debt]
	ADD CONSTRAINT [Period Debt] FOREIGN KEY (Period_ID)
		REFERENCES [Period] ([ID]); 

ALTER TABLE [Receipt]
	ADD CONSTRAINT [Period Receipt] FOREIGN KEY (Period_ID)
		REFERENCES [Period] ([ID]); 

ALTER TABLE [Quality_of_service]
	ADD CONSTRAINT [Account Quality_of_service] FOREIGN KEY (Account_ID)
		REFERENCES [Account] ([ID]); 

ALTER TABLE [Quality_of_service]
	ADD CONSTRAINT [Period Quality_of_service] FOREIGN KEY (Period_ID)
		REFERENCES [Period] ([ID]); 

ALTER TABLE [Account]
	ADD CONSTRAINT [Privileges Account] FOREIGN KEY (Privilege_ID)
		REFERENCES [Privileges] ([ID]); 

ALTER TABLE [Ownership]
	ADD CONSTRAINT [Owner OwnershipW] FOREIGN KEY (Owner_ID)
		REFERENCES [Owner] ([ID]); 

ALTER TABLE [Ownership]
	ADD CONSTRAINT [Flat Ownershipw] FOREIGN KEY (Flat_ID)
		REFERENCES [Flat] ([ID]); 