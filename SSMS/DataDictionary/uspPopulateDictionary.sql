USE [DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspPopulateDictionary]    Script Date: 14/02/2015 15:18:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Peter Davies
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uspPopulateDictionary] 
	-- Add the parameters for the stored procedure here
	@Database varchar(64)
AS
BEGIN
	DECLARE @sql nvarchar(4000)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert stat--USE AdventureWorks2008R2;

--Remove all Datadictionary Records
DELETE FROM dbo.DATADICTIONARY where DatabaseName = @Database;

--CTE obtains a list of user tables [UserTables]
--Then [UserTables] joined with system view [INFORMATION_SCHEMA].[COLUMNS]
--and this will retrieve all columns in user tables
--Note: The join is on both TableName & SchemaName
--Note: It will not retrieve columns in views

SET @SQL =
	'WITH [UserTables] AS
	(
		SELECT 
			TABLE_NAME,
			TABLE_SCHEMA 
		FROM 
			[' + @Database + '].INFORMATION_SCHEMA.TABLES 
		WHERE 
			TABLE_TYPE = ''BASE TABLE''
	)
INSERT INTO
	dbo.DATADICTIONARY(
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
      ''' + @Database + ''',
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
	[' + @Database + '].[INFORMATION_SCHEMA].[COLUMNS] ISC
	INNER JOIN UserTables UT 
		ON UT.TABLE_SCHEMA = ISC.TABLE_SCHEMA
		AND UT.TABLE_NAME = ISC.TABLE_NAME;'
  
  EXEC sp_Executesql @SQL;
      
--CTE Obtains a unique list of extended properties for tables in
--Data Dictionary. These are then passed to a system table function for extended propreties
--as parameters via a CROSS APPLY mechanism. 
--
--The above data set now updates the [DataDictionary].[TableDescription] but we only use
--extended properties with a name of 'MS_Description'
SET @SQL =

'WITH TableDescriptions as
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
			dbO.DATADICTIONARY DD
			CROSS APPLY [' + @Database + '].sys.fn_listextendedproperty (
													NULL, 
													''schema'', table_schema, 
													''tablE'', table_name, 
													NULL, NULL) CA
												)
UPDATE 
	dbO.DATADICTIONARY
SET 
	TableDescription = TD.value
FROM
	TableDescriptions TD
	INNER JOIN DBA.dbO.DATADICTIONARY DD
		ON TD.Table_Schema = DD.Table_Schema
		AND TD.Table_Name = DD.Table_Name
WHERE
	TD.Name = ''MS_Description'';'

 EXEC sp_Executesql @SQL;

--CTE Obtains a unique list of extended properties for columns in
--Data Dictionary. These are then passed to a system table function for extended propreties
--as parameters via a CROSS APPLY mechanism. 
--
--The above data set now updates the [DataDictionary].[ColumnDescription] but we only use
--extended properties with a name of 'MS_Description'

SET @SQL =
	
'WITH ColumnDescriptions as
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
			dbO.DATADICTIONARY DD
			CROSS APPLY  [' + @Database + '].sys.fn_listextendedproperty (
													NULL, 
													''schema'', DD.table_schema, 
													''table'', DD.table_name, 
													''column'', DD.Column_Name) CA
		WHERE
			CA.name = ''MS_Description''
												)
UPDATE 
	dbO.DATADICTIONARY
SET 
	ColumnDEscription = CD.value
FROM
	ColumnDescriptions CD
	INNER JOIN DBA.dbO.DATADICTIONARY DD
	ON CD.Table_Schema = DD.Table_Schema
	AND CD.Table_Name = DD.Table_Name
	AND CD.Column_Name = DD.Column_Name;'


 EXEC sp_Executesql @SQL;

--All 
--[Datadictionary].[TAbleDescription]  
--[Datadictionary].[ColumnDescription] 
--values have now been updated if they have an extended propert called 'MS_description

--Flag Columns thast are used in PrimaryKeys

SET @SQL =

'WITH PrimaryKeys  AS
(
SELECT SS.NAME AS [TABLE_SCHEMA], ST.NAME AS [TABLE_NAME]
     , SKC.NAME AS [CONSTRAINT_NAME], SC.NAME AS [CONSTRAINT_COLUMN_NAME],
     CAST(STY.NAME AS VARCHAR(20)) +''(''+
     CAST(CASE ST.NAME
     WHEN ''NVARCHAR'' THEN (SELECT SC.MAX_LENGTH/2)
     ELSE (SELECT SC.MAX_LENGTH)
     END AS VARCHAR(20)) +'')'' AS [DATA_TYPE]
  FROM [' + @Database + '].SYS.KEY_CONSTRAINTS AS SKC
  INNER JOIN [' + @Database + '].SYS.TABLES AS ST
    ON ST.OBJECT_ID = SKC.PARENT_OBJECT_ID
  INNER JOIN [' + @Database + '].SYS.SCHEMAS AS SS
    ON SS.SCHEMA_ID = ST.SCHEMA_ID
  INNER JOIN [' + @Database + '].SYS.INDEX_COLUMNS AS SIC
    ON SIC.OBJECT_ID = ST.OBJECT_ID
   AND SIC.INDEX_ID = SKC.UNIQUE_INDEX_ID
  INNER JOIN [' + @Database + '].SYS.COLUMNS AS SC
    ON SC.OBJECT_ID = ST.OBJECT_ID
   AND SC.COLUMN_ID = SIC.COLUMN_ID
  INNER JOIN [' + @Database + '].SYS.TYPES AS STY
      ON SC.USER_TYPE_ID = STY.USER_TYPE_ID
  )
  UPDATE dbO.DATADICTIONARY 
		SET IsKeyColumn = 1
  FROM PrimaryKeys PK
  INNER jOIN DBA.dbO.DATADICTIONARY DD
  ON PK.TABLE_SCHEMA COLLATE Latin1_General_CI_AS = DD.TABLE_SCHEMA
  AND PK.TABLE_NAME COLLATE Latin1_General_CI_AS =  DD.TABLE_NAME
  AND PK.CONSTRAINT_COLUMN_NAME COLLATE Latin1_General_CI_AS = DD.COLUMN_NAME;'

EXEC sp_Executesql @SQL;

SET @SQL =
'WITH 
	ForeignKeys	
AS
	(
	SELECT
		FK_Table = FK.TABLE_NAME,
		FK_Schema = FK.TABLE_SCHEMA,
		FK_Column = CU.COLUMN_NAME,
		PK_Table = PK.TABLE_NAME,
		PK_Schema = PK.TABLE_SCHEMA,
		PK_Column = PT.COLUMN_NAME,
		Constraint_Name = C.CONSTRAINT_NAME
	FROM 
		[' + @Database + '].INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
		INNER JOIN [' + @Database + '].INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK 
			ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
		INNER JOIN [' + @Database + '].INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK 
			ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
		INNER JOIN [' + @Database + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU 
			ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
		INNER JOIN (
					SELECT 
						i1.TABLE_NAME, 
						i2.COLUMN_NAME
					FROM 
						[' + @Database + '].INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1
						INNER JOIN [' + @Database + '].INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2 
							ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
					WHERE 
						i1.CONSTRAINT_TYPE = ''PRIMARY KEY''
					) PT 
			ON PT.TABLE_NAME = PK.TABLE_NAME
	)
UPDATE 
	dba.DBO.DATADICTIONARY 
SET 
	IsForeignKey = 1
FROM
	ForeignKeys FK
	INNER jOIN DBO.DATADICTIONARY DD
		ON FK.FK_Schema COLLATE Latin1_General_CI_AS = DD.TABLE_SCHEMA
		AND FK.FK_Table COLLATE Latin1_General_CI_AS =  DD.TABLE_NAME
		AND FK.FK_Column COLLATE Latin1_General_CI_AS = DD.COLUMN_NAME'

EXEC sp_Executesql @SQL; 

--Set column to required if NOT NULL is column property
UPDATE
	dbo.DATADICTIONARY
SET
	IsRequired = 1
WHERE
	IS_NULLABLE = 'NO'

END
















GO


