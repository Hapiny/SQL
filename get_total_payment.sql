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