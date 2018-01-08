USE [New]
GO

CREATE VIEW [Product_prices] AS
	SELECT [product].[product_id], [description], [list_price], [min_price]
	FROM [product] 
	JOIN [price] ON [price].[product_id] = [product].[product_id]
	WHERE [end_date] IS NULL
GO

SELECT * FROM [Product_prices]
UPDATE [Product_prices] SET [list_price] = 240.00-- WHERE product_id = 100860

DROP TRIGGER [Change_price]
GO

CREATE TRIGGER [Change_price] ON [Product_prices]
INSTEAD OF UPDATE 
AS
IF 1 = (
	SELECT COUNT(p.product_id)
	FROM [Product_prices] p
	JOIN [INSERTED] i ON p.product_id = i.product_id
	WHERE p.product_id = i.product_id AND
		p.description = i.description AND
		p.list_price = i.list_price AND
		p.min_price = i.min_price
)
BEGIN
	RAISERROR('Such row(s) exists!',16, 10)
END
ELSE
BEGIN 
		UPDATE [Price] SET [End_date] = GETDATE() WHERE end_date IS NULL AND
			product_id IN (
				SELECT p.product_id FROM [product_prices] p	
			)
		INSERT INTO [Price] ([product_id],[list_price],[min_price],[start_date]) 
		SELECT i.product_id, i.list_price, i.min_price, GETDATE()
		FROM [inserted] i
END
GO
