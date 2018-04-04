GO
USE DBA
/****** Object:  StoredProcedure [PQRD].[uspConstraintsCheckDefault]    Script Date: 05/14/2015 12:48:20 ******/
IF  EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[SSRS].[uspForeignKeys]') 
	AND type in (N'P', N'PC'))
	
		DROP PROCEDURE [SSRS].[uspForeignKeys]

GO

SET QUOTED_IDENTIFIER ON

GO


CREATE PROCEDURE [SSRS].[uspForeignKeys]

	@Table_Schema varchar(120) = NULL,
	@Table_Name varchar(120) = NULL
	
AS
BEGIN
	
SELECT  
    KCU1.CONSTRAINT_NAME AS FKName,
    KCU2.CONSTRAINT_NAME AS ParentPKName,
    KCU1.TABLE_SCHEMA AS FKSchemaName,
    KCU2.TABLE_SCHEMA AS PKSchemaName,
    KCU1.TABLE_NAME AS FKTableName,
    KCU2.TABLE_NAME AS ParentTableName, 
    KCU1.COLUMN_NAME AS FKColunmName,
    KCU2.COLUMN_NAME AS ParaentColumn , 
    KCU1.ORDINAL_POSITION AS FKOrdinalPos,     
    KCU2.ORDINAL_POSITION AS PKOrdinalPos,
    RC.MATCH_OPTION MatchOption,
	RC.UPDATE_RULE UpdateRule,
	RC.DELETE_RULE DeleteRule,
	0 SSRSOrder 
FROM 
	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS RC 
	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU1 
		ON KCU1.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG  
		AND KCU1.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA 
		AND KCU1.CONSTRAINT_NAME = RC.CONSTRAINT_NAME 

	INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU2 
		ON KCU2.CONSTRAINT_CATALOG = RC.UNIQUE_CONSTRAINT_CATALOG  
		AND KCU2.CONSTRAINT_SCHEMA = RC.UNIQUE_CONSTRAINT_SCHEMA 
		AND KCU2.CONSTRAINT_NAME = RC.UNIQUE_CONSTRAINT_NAME 
		AND KCU2.ORDINAL_POSITION = KCU1.ORDINAL_POSITION
WHERE	
	KCU1.TABLE_SCHEMA  = COALESCE (@Table_Schema,KCU1.TABLE_SCHEMA)
	AND KCU1.TABLE_NAME = COALESCE (@Table_Name,KCU1.TABLE_NAME)
UNION --Blank row so sub-report header shows when no data rows
SELECT
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	-1,
	-1,
	'',
	'',
	'',
	1 SSRSOrder
ORDER BY
	SSRSOrder,
	KCU1.CONSTRAINT_NAME,
	KCU1.ORDINAL_POSITION
	
END

GO


