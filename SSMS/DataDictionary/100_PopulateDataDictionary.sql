
USE UKIPMembers

go
Declare @DatabaseName varchar(128)

SELECT @DatabaseName = DB_Name()

DELETE 
FROM 
	DBA.DBA.DataDictionary
WHERE
	DatabaseName = @DatabaseName

DELETE 
FROM 
	DBA.DBA.ColumnDefaultAndChecks
WHERE
	DatabaseName = @DatabaseName


----------------DROP FOREIGN KEYS

--[FK_DataDictionary_DataDictionaryTableDesc]

--IF  EXISTS (SELECT * FROM sys.foreign_keys 
--      WHERE object_id = OBJECT_ID(N'[DBA].[FK_DataDictionary_DataDictionaryColumnDesc]') 
--      AND parent_object_id = OBJECT_ID(N'[DBA].[DataDictionary]'))
      
--      ALTER TABLE [DBA].[DataDictionary] 
--            DROP CONSTRAINT [FK_DataDictionary_DataDictionaryColumnDesc]

--IF  EXISTS (SELECT * FROM sys.foreign_keys 
--      WHERE object_id = OBJECT_ID(N'[DBA].[FK_DataDictionary_DataDictionaryTableDesc]') 
--      AND parent_object_id = OBJECT_ID(N'[DBA].[DataDictionary]'))

--      ALTER TABLE [DBA].[DataDictionary] 
--            DROP CONSTRAINT [FK_DataDictionary_DataDictionaryTableDesc]

--Store all table names and column nsmes using system view
-- "INFORMATION_SCHEMA.COLUMNS"
--All stores many column properties

INSERT INTO
     DBA.DBA.DataDictionary(
	 [DatabaseName],
     [TABLE_SCHEMA]
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
	@DatabaseName,
     [TABLE_SCHEMA]
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
    ,[DOMAIN_NAME]  
  FROM 
      INFORMATION_SCHEMA.COLUMNS

--Update DataDictionary Table to flag columns as Primary Key

;WITH PrimaryKeys
AS
(SELECT
TAB.TABLE_SCHEMA, 
tab.TABLE_NAME,
Col.Column_Name from 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
    INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
WHERE 
    Col.Constraint_Name = Tab.Constraint_Name
    AND Col.Table_Name = Tab.Table_Name
    AND COL.TABLE_SCHEMA = TAB.TABLE_SCHEMA
    AND Constraint_Type = 'PRIMARY KEY'
)
UPDATE
      DBA.DBA.DataDictionary
SET 
      IsPrimaryKey = 1
FROM
      DBA.DBA.DataDictionary DD
      INNER JOIN PrimaryKeys PK
      ON PK.TABLE_SCHEMA COLLATE Latin1_General_CI_AS = DD.TABLE_SCHEMA
      AND PK.TABLE_NAME COLLATE Latin1_General_CI_AS = DD.TABLE_NAME
      AND PK.COLUMN_NAME COLLATE Latin1_General_CI_AS = DD.COLUMN_NAME 

--Update DataDictionary Table to flag columns as Foreign Key
;WITH ForeignKeys 
AS
(SELECT RC.CONSTRAINT_NAME FK_Name
, KF.TABLE_SCHEMA FK_Schema
, KF.TABLE_NAME FK_Table
, KF.COLUMN_NAME FK_Column
, RC.UNIQUE_CONSTRAINT_NAME PK_Name
, KP.TABLE_SCHEMA PK_Schema
, KP.TABLE_NAME PK_Table
, KP.COLUMN_NAME PK_Column
, RC.MATCH_OPTION MatchOption
, RC.UPDATE_RULE UpdateRule
, RC.DELETE_RULE DeleteRule
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME)
UPDATE
      DBA.DBA.DataDictionary
SET 
      IsForeignKey = 1
FROM
      DBA.DBA.DataDictionary DD
      INNER JOIN ForeignKeys FK
            ON FK_Schema COLLATE Latin1_General_CI_AS= DD.TABLE_SCHEMA
            AND FK.FK_Table COLLATE Latin1_General_CI_AS= DD.TABLE_NAME
            AND FK.FK_Column COLLATE Latin1_General_CI_AS= DD.COLUMN_NAME
            
--Table And Column descriptions are held in tables
--    DBA.DBA.DataDictionaryTableDesc
--    DBA.DBA.DataDictionaryColumnDesc
--
--The decriptions are entered into these tables manually or by script
--
--But the populations controls of the two tables
--is controlled by the script below.

--Table Descriptions
--Add new Records to DBA.DBA.DataDictionaryTableDesc
INSERT INTO
      DBA.DBA.DataDictionaryTableDesc
      (DatabaseName,
	  TABLE_SCHEMA,
      TABLE_NAME)
SELECT
      @DatabaseName,	
      DD.TABLE_SCHEMA,
      DD.TABLE_NAME
FROM
      DBA.DBA.DataDictionary      DD
      LEFT JOIN DBA.DBA.DataDictionaryTableDesc DDTD
            ON DD.DatabaseName = DDTD.DatabaseName
				AND DD.TABLE_SCHEMA = DDTD.TABLE_SCHEMA
				AND DD.TABLE_NAME = DDTD.TABLE_NAME
WHERE
	DDTD.DatabaseName IS NULL
    AND DDTD.TABLE_SCHEMA IS NULL
    AND DDTD.TABLE_NAME IS NULL
GROUP BY
	DD.DatabaseName,
    DD.TABLE_SCHEMA,
    DD.TABLE_NAME
      
--Update DBA.DBA.DataDictionaryTableDesc and set [ObjectType] to View
--Default value for [ObjectType]  is Table

UPDATE DBA.DBA.DataDictionaryTableDesc
SET [ObjectType] ='View'
FROM DBA.DBA.DataDictionaryTableDesc DDTD
INNER JOIN INFORMATION_SCHEMA.VIEWS V
      ON  DDTD.TABLE_SCHEMA = V.TABLE_SCHEMA COLLATE Latin1_General_CI_AS
            AND DDTD.TABLE_NAME =V.TABLE_NAME COLLATE Latin1_General_CI_AS
WHERE
	DDTD.DatabaseName = @DatabaseName
--Update DBA.DBA.DataDictionaryColumnDesc and set [ObjectType] to View
--Default value for [ObjectType]  is Table

UPDATE DBA.DBA.DataDictionaryColumnDesc
SET [ObjectType] ='View'
FROM DBA.DBA.DataDictionaryColumnDesc DDCD
INNER JOIN INFORMATION_SCHEMA.VIEWS V
      ON	DDCD.TABLE_SCHEMA = V.TABLE_SCHEMA COLLATE Latin1_General_CI_AS
            AND DDCD.TABLE_NAME =V.TABLE_NAME COLLATE Latin1_General_CI_AS
WHERE
	DDCD.DatabaseName = @DatabaseName
--Remove old Records from DBA.DBA.DataDictionaryTableDesc
DELETE 
      DBA.DBA.DataDictionaryTableDesc
FROM
      DBA.DBA.DataDictionaryTableDesc DDTD
      LEFT JOIN DBA.DBA.DataDictionary DD
            ON DDTD.DatabaseName= DD.DatabaseName
			AND DDTD.TABLE_SCHEMA = DD.TABLE_SCHEMA
            AND DDTD.TABLE_NAME = DD.TABLE_NAME
WHERE
	  DD.DatabaseName IS NULL	
      AND DD.TABLE_SCHEMA IS NULL
      AND DD.TABLE_NAME IS NULL
      
--  Descriptions
--Add new Records to DBA.DBA.DataDictionaryColumnDesc
INSERT INTO
      DBA.DBA.DataDictionaryColumnDesc
      (DatabaseName,
	  TABLE_SCHEMA,
      TABLE_NAME,
      COLUMN_NAME)
SELECT
	  @DatabaseName,
      DD.TABLE_SCHEMA,
      DD.TABLE_NAME,
      dd.COLUMN_NAME
FROM
      DBA.DBA.DataDictionary      DD
      LEFT JOIN DBA.DBA.DataDictionaryColumnDesc DDCD
            ON DD.DatabaseName = DDCD.DatabaseName
			AND DD.TABLE_SCHEMA = DDCD.TABLE_SCHEMA
            AND DD.TABLE_NAME = DDCD.TABLE_NAME
            AND DD.COLUMN_NAME = DDCD.COLUMN_NAME
WHERE
	  DDCD.DatabaseName IS NULL
      AND DDCD.TABLE_SCHEMA IS NULL
      AND DDCD.TABLE_NAME IS NULL
      AND DDCD.COLUMN_NAME IS NULL
      
--Remove old Records from DBA.DBA.DataDictionaryColumnDesc
DELETE 
      DBA.DBA.DataDictionaryColumnDesc
FROM
      DBA.DBA.DataDictionaryColumnDesc DDCD
      LEFT JOIN DBA.DBA.DataDictionary DD
            ON DDCD.TABLE_SCHEMA = DD.TABLE_SCHEMA
            AND DDCD.TABLE_NAME = DD.TABLE_NAME
            AND DDCD.COLUMN_NAME = DD.COLUMN_NAME
WHERE
	  DD.DatabaseName IS NULL
      AND DD.TABLE_SCHEMA IS NULL
      AND DD.TABLE_NAME IS NULL
      AND DD.COLUMN_NAME IS NULL
      
--Add table row counts
;WITH CountRowsInTables (Table_Name, Table_Schema, Row_Counts) AS
(
SELECT
TableName = t.Name,
TableSchema = s.Name,
RowCounts = p.Rows
    FROM 
        sys.tables t
    INNER JOIN 
        sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN      
        sys.indexes i ON t.OBJECT_ID = i.object_id
    INNER JOIN 
        sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
    WHERE 
        t.is_ms_shipped = 0
    GROUP BY
        s.Name, t.Name, p.Rows
)
UPDATE
      DBA.DBA.DataDictionaryTableDesc
SET
      TableRowCount = CRT.Row_Counts
FROM 
      CountRowsInTables CRT
      INNER JOIN DBA.DBA.DataDictionaryTableDesc DDTD
      ON CRT.Table_Schema COLLATE Latin1_General_CI_AS= DDTD.TABLE_SCHEMA
      AND CRT.Table_Name COLLATE Latin1_General_CI_AS= DDTD.TABLE_NAME

---------------CREATE FOREIGN KEYS

----[FK_DataDictionary_DataDictionaryTableDesc]
--ALTER TABLE DBA.DBA.DataDictionary  
--      WITH CHECK ADD  CONSTRAINT [FK_DataDictionary_DataDictionaryTableDesc] 
--      FOREIGN KEY([TABLE_SCHEMA] ,
--                        [TABLE_NAME])
--      REFERENCES [DBA].[DataDictionaryTableDesc] 
--                        ([TABLE_SCHEMA] ,
--                        [TABLE_NAME])

--ALTER TABLE [DBA].[DataDictionary] 
--  CHECK CONSTRAINT [FK_DataDictionary_DataDictionaryTableDesc]

--ALTER TABLE DBA.DBA.DataDictionary  
--      WITH CHECK ADD  CONSTRAINT [FK_DataDictionary_DataDictionaryColumnDesc] 
--      FOREIGN KEY([TABLE_SCHEMA] ,
--                        [TABLE_NAME],
--                        [COLUMN_NAME])
--      REFERENCES [DBA].[DataDictionaryColumnDesc] 
--                        ([TABLE_SCHEMA] ,
--                        [TABLE_NAME],                 [COLUMN_NAME])

--ALTER TABLE [DBA].[DataDictionary] 
-- CHECK CONSTRAINT [FK_DataDictionary_DataDictionaryColumnDesc] 

INSERT INTO 
	DBA.DBA.ColumnDefaultAndChecks(
	[DatabaseName],
    [TABLE_SCHEMA],
    [TABLE_NAME] ,
    [COLUMN_NAME],
	ConstraintName,
	DefaultValue, 
	CheckValue )
SELECT
	@DatabaseName,
	S.name TableSchema,
    TableName = t.Name ,
    ColumnName = c.Name ,
	dc.Name ConstraintName,
    dc.definition DefaultVale,
    Null CheckValue
FROM 
	sys.tables t
	INNER JOIN sys.default_constraints dc 
		ON t.object_id = dc.parent_object_id
	INNER JOIN sys.columns c 
		ON dc.parent_object_id = c.object_id 
		AND c.column_id = dc.parent_column_id
	LEFT JOIN sys.check_constraints cc
		ON t.object_id =cc.parent_OBJECT_id
		AND cc.parent_column_id = dc.parent_column_id
	INNER JOIN sys.schemas s
		ON S.schema_id = T.schema_id
UNION
SELECT
	@DatabaseName, 
	TABLE_NAME,
	COLUMN_NAME,
	cc.CONSTRAINT_SCHEMA,
	cc.CONSTRAINT_NAME,
	null DefaultVale,
    CHECK_CLAUSE CheckValue    
FROM     INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
         INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c
			   ON cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME

      
--Result Set for Report
USE DBA

SELECT
      *
FROM
      [dba].[DataDictionary]
	WHERE
	DatabaseName = @DatabaseName
	
ORDER BY
    [TABLE_SCHEMA],
    [TABLE_NAME],
    [COLUMN_NAME]
	
