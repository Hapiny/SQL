DROP FUNCTION dbo.get_total_payment
GO

CREATE FUNCTION get_total_payment(@Counter numeric(8,2),@Service int)  
RETURNS numeric(8,2)  
AS   
BEGIN  
    DECLARE @result numeric(8,2);  
    SELECT @result = Price_Unit * Indication_of_counter   
    FROM Receipt
    JOIN Price ON Receipt.Service_ID = Price.Service_ID  
    JOIN Period ON Period.ID = Receipt.Period_ID 
    WHERE Receipt.Service_ID = @Service   
    AND Receipt.Indication_of_counter = @Counter
    AND End_Date IS NULL OR Period.Start BETWEEN Start_date AND End_date ;    
    RETURN @result;  
END; 
GO