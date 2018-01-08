USE [House_Managment]
GO
-- SELECT DB_NAME() AS 'Curretn DataBase', USER_NAME() AS 'Current User'
-- SELECT * FROM INFORMATION_SCHEMA.tables
-- SELECT * FROM sys.tables
-- SELECT * FROM sys.schemas
-- SELECT * FROM sys.extended_properties
-- JOIN sys.tables ON sys.tables.object_id = sys.extended_properties.major_id
-- SELECT * FROM sys.objects
-- SELECT * FROM sys.types
-- SELECT * FROM sys.columns
-- SELECT * FROM sys.objects WHERE type = 'U' OR type = 'PK' OR type = 'F'
--------------------------------------------------------------------------------------------------------------

SELECT st.name AS 'Table Name'
FROM sys.tables st
JOIN sys.schemas ss ON ss.schema_id = st.schema_id
WHERE st.object_id NOT IN (SELECT major_id FROM sys.extended_properties) AND 
	USER_NAME(ss.principal_id) = 'dbo' AND
	st.is_ms_shipped = 0

--------------------------------------------------------------------------------------------------------------

SELECT so.name AS 'Table Name', sc.name AS 'Column Name', sc.is_nullable AS 'NULL',
	st.name AS 'Type Name', sc.max_length AS 'Size' 
FROM sys.objects so
JOIN sys.columns sc ON sc.object_id = so.object_id
JOIN sys.types st ON sc.user_type_id = st.user_type_id
JOIN sys.schemas ss ON ss.schema_id = so.schema_id
WHERE so.type = 'U' AND 
	USER_NAME(ss.principal_id) ='dbo' AND 
	so.object_id NOT IN (SELECT major_id FROM sys.extended_properties)

--------------------------------------------------------------------------------------------------------------

SELECT so1.name AS 'Key Name', 
	so2.name AS 'Table Name', 
	so1.type AS 'Constraint Type'
FROM sys.objects so1 
JOIN sys.objects so2 ON so1.parent_object_id = so2.object_id 
JOIN sys.schemas ss ON ss.schema_id = so2.schema_id
WHERE (so1.type = 'F' OR so1.type = 'PK' OR so1.type = 'C') AND 
	USER_NAME(ss.principal_id) = 'dbo' AND 
	so2.object_id NOT IN (SELECT major_id FROM sys.extended_properties) 
ORDER BY 'Constraint Type'

--------------------------------------------------------------------------------------------------------------

-- SELECT * FROM sys.foreign_keys
-- SELECT * FROM sys.foreign_key_columns

SELECT sfk.name AS 'Key Name', 
		so1.name AS 'Foreign Table Name', so2.name AS 'Primary Table Name',
		sc1.name AS 'Foreign Column',  sc2.name AS 'Primary Column'
FROM sys.foreign_keys sfk
JOIN sys.objects so1 ON sfk.parent_object_id = so1.object_id -- та таблица, в которой хранится ограничение внешнего ключа
JOIN sys.objects so2 ON sfk.referenced_object_id = so2.object_id -- та таблица, на которую ссылается внешний ключ
JOIN sys.foreign_key_columns sfkc ON sfkc.constraint_object_id = sfk.object_id
JOIN sys.columns sc1 ON sfkc.parent_object_id = sc1.object_id AND sfkc.parent_column_id = sc1.column_id
JOIN sys.columns sc2 ON sfkc.referenced_object_id = sc2.object_id AND sfkc.referenced_column_id = sc2.column_id
JOIN sys.schemas ss ON ss.schema_id = so1.schema_id
WHERE USER_NAME(ss.principal_id) = 'dbo'
ORDER BY 'Foreign Table Name'

--------------------------------------------------------------------------------------------------------------

SELECT TABLE_NAME AS 'View Name', VIEW_DEFINITION AS 'Code'
FROM INFORMATION_SCHEMA.VIEWS
JOIN sys.schemas ss ON SCHEMA_ID(TABLE_SCHEMA) = ss.schema_id
WHERE USER_NAME(ss.principal_id) = 'dbo'

--------------------------------------------------------------------------------------------------------------

-- SELECT * FROM sys.triggers

SELECT tr.name AS 'Trigger Name',st.name AS 'Table Name'
FROM sys.triggers tr
JOIN sys.tables st ON st.object_id = tr.parent_id
JOIN sys.schemas ss ON ss.schema_id = st.schema_id
WHERE USER_NAME(ss.principal_id) = 'dbo'

--------------------------------------------------------------------------------------------------------------
