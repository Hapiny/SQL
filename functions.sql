USE [House_Managment]
GO

IF EXISTS
(
	SELECT * FROM sys.objects so
	WHERE so.type = 'FN' AND so.name = 'get_current_period'
) 
	DROP FUNCTION [get_current_period]
ELSE 
	PRINT 'Function "get_current_period" does not exist'
GO


IF EXISTS
(
	SELECT * FROM sys.objects so
	WHERE so.type = 'FN' AND so.name = 'counter'
) 
	DROP FUNCTION [counter]
ELSE 
	PRINT 'Function "counter" does not exist'
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
