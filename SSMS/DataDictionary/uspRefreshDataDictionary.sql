--USE AdventureWorks2008R2;
use CQSD


--Remove all Datadictionary Records
DELETE FROM DBA.dbo.DATADICTIONARY WHERE DatabaseName ='CQSD'

--CTE obtains a list of user tables [UserTables]
--Then [UserTables] joined with system view [INFORMATION_SCHEMA].[COLUMNS]
--and this will retrieve all columns in user tables
--Note: The join is on both TableName & SchemaName
--Note: It will not retrieve columns in views
GO

WITH [UserTables] AS
	(
		SELECT 
			TABLE_NAME,
			TABLE_SCHEMA 
		FROM 
			INFORMATION_SCHEMA.TABLES 
		WHERE 
			TABLE_TYPE = 'BASE TABLE'
	)
INSERT INTO
	DBA.dbo.DATADICTIONARY(
	DatabaseName
	,[TABLE_SCHEMA]
	,[TABLE_NAME]
	,[COLUMN_NAME]
	,[ORDINAL_POSITION]
	,[COLUMN_DEFAULT]
	,[IS_NULLABLE]
	,[DATA_TYPE]
	,[CHARACTER_MAXIMUM_LENGTH]
	,[CHARACTER_OCTET_LENGTH]
	,[NUMERIC_PRECISION]
	,[NUMERIC_PRECISION_RADIX]
	,[NUMERIC_SCALE]
	,[DATETIME_PRECISION]
	,[CHARACTER_SET_CATALOG]
	,[CHARACTER_SET_SCHEMA]
	,[CHARACTER_SET_NAME]
	,[COLLATION_CATALOG]
	,[COLLATION_SCHEMA]
	,[COLLATION_NAME]
	,[DOMAIN_CATALOG]
	,[DOMAIN_SCHEMA]
	,[DOMAIN_NAME])	
SELECT  
      DB_NAME(),
      UT.[TABLE_SCHEMA]
      ,ISC.[TABLE_NAME]
      ,[COLUMN_NAME]
      ,[ORDINAL_POSITION]
      ,[COLUMN_DEFAULT]
      ,[IS_NULLABLE]
      ,[DATA_TYPE]
      ,[CHARACTER_MAXIMUM_LENGTH]
      ,[CHARACTER_OCTET_LENGTH]
      ,[NUMERIC_PRECISION]
      ,[NUMERIC_PRECISION_RADIX]
      ,[NUMERIC_SCALE]
      ,[DATETIME_PRECISION]
      ,[CHARACTER_SET_CATALOG]
      ,[CHARACTER_SET_SCHEMA]
      ,[CHARACTER_SET_NAME]
      ,[COLLATION_CATALOG]
      ,[COLLATION_SCHEMA]
      ,[COLLATION_NAME]
      ,[DOMAIN_CATALOG]
      ,[DOMAIN_SCHEMA]
      ,[DOMAIN_NAME]
  FROM 
	[INFORMATION_SCHEMA].[COLUMNS] ISC
	INNER JOIN UserTables UT 
		ON UT.TABLE_SCHEMA = ISC.TABLE_SCHEMA
		AND UT.TABLE_NAME = ISC.TABLE_NAME;
    
--CTE Obtains a unique list of extended properties for tables in
--Data Dictionary. These are then passed to a system table function for extended propreties
--as parameters via a CROSS APPLY mechanism. 
--
--The above data set now updates the [DataDictionary].[TableDescription] but we only use
--extended properties with a name of 'MS_Description'

WITH TableDescriptions as
	(
		SELECT DISTINCT 
			DD.table_schema,
			DD.table_name, 
			Null as ColumnNAme,
			CA.objtype, 
			CA.objname, 
			CA.name, 
			Convert(nvarchar(128),CA.value) as [Value]
		FROM
			DBA.dbO.DATADICTIONARY DD
			CROSS APPLY fn_listextendedproperty (
													NULL, 
													'schema', table_schema, 
													'table', table_name, 
													NULL, NULL) CA
												)
UPDATE 
	DBA.dbO.DATADICTIONARY
SET 
	TableDescription = TD.value
FROM
	TableDescriptions TD
	INNER JOIN DBA.dbo.DATADICTIONARY DD
		ON TD.Table_Schema = DD.Table_Schema
		AND TD.Table_Name = DD.Table_Name
WHERE
	TD.Name = 'MS_Description';

--CTE Obtains a unique list of extended properties for columns in
--Data Dictionary. These are then passed to a system table function for extended propreties
--as parameters via a CROSS APPLY mechanism. 
--
--The above data set now updates the [DataDictionary].[ColumnDescription] but we only use
--extended properties with a name of 'MS_Description'
	
WITH TableDescriptions as
	(
		SELECT DISTINCT 
			DD.table_schema,
			DD.table_name, 
			DD.Column_Name,
			CA.objtype, 
			CA.objname, 
			CA.name, 
			Convert(nvarchar(128),CA.value) as [Value]
		FROM
			DBA.dbo.DATADICTIONARY DD
			CROSS APPLY  fn_listextendedproperty (
													NULL, 
													'schema', DD.table_schema, 
													'table', DD.table_name, 
													'column', DD.Column_Name) CA
		WHERE
			CA.name = 'MS_Description'
												)
UPDATE 
	DBA.dbo.DATADICTIONARY
SET 
	ColumnDEscription = TD.value
FROM
	TableDescriptions TD
	INNER JOIN DBA.dbo.DATADICTIONARY DD
	ON TD.Table_Schema = DD.Table_Schema
	AND TD.Table_Name = DD.Table_Name
	AND TD.Column_Name = DD.Column_Name
	

--All 
--[Datadictionary].[TAbleDescription]  
--[Datadictionary].[ColumnDescription] 
--values have now been updated if they have an extended propert called 'MS_description

--Flag Columns thast are used in PrimaryKeys
go

WITH PrimaryKeys  AS
(
SELECT SS.NAME AS [TABLE_SCHEMA], ST.NAME AS [TABLE_NAME]
     , SKC.NAME AS [CONSTRAINT_NAME], SC.NAME AS [CONSTRAINT_COLUMN_NAME],
     CAST(STY.NAME AS VARCHAR(20)) +'('+
     CAST(CASE ST.NAME
     WHEN 'NVARCHAR' THEN (SELECT SC.MAX_LENGTH/2)
     ELSE (SELECT SC.MAX_LENGTH)
     END AS VARCHAR(20)) +')' AS [DATA_TYPE]
  FROM SYS.KEY_CONSTRAINTS AS SKC
  INNER JOIN SYS.TABLES AS ST
    ON ST.OBJECT_ID = SKC.PARENT_OBJECT_ID
  INNER JOIN SYS.SCHEMAS AS SS
    ON SS.SCHEMA_ID = ST.SCHEMA_ID
  INNER JOIN SYS.INDEX_COLUMNS AS SIC
    ON SIC.OBJECT_ID = ST.OBJECT_ID
   AND SIC.INDEX_ID = SKC.UNIQUE_INDEX_ID
  INNER JOIN SYS.COLUMNS AS SC
    ON SC.OBJECT_ID = ST.OBJECT_ID
   AND SC.COLUMN_ID = SIC.COLUMN_ID
  INNER JOIN SYS.TYPES AS STY
      ON SC.USER_TYPE_ID = STY.USER_TYPE_ID
  )
  UPDATE DBA.DBO.DATADICTIONARY 
		SET IsKeyColumn = 1
  FROM PrimaryKeys PK
  INNER jOIN DBA.DBO.DATADICTIONARY DD
  ON PK.TABLE_SCHEMA COLLATE Latin1_General_CI_AS = DD.TABLE_SCHEMA
  AND PK.TABLE_NAME COLLATE Latin1_General_CI_AS =  DD.TABLE_NAME
  AND PK.CONSTRAINT_COLUMN_NAME COLLATE Latin1_General_CI_AS = DD.COLUMN_NAME


--