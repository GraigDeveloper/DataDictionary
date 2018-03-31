
IF  EXISTS (SELECT * FROM sys.objects 
			WHERE object_id = OBJECT_ID(N'[SSRS].[uspListAllIndexes]') 
			AND type in (N'P', N'PC'))
DROP PROCEDURE [SSRS].[uspListAllIndexes]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		PQR Davies
-- Create date: 10-Jul-2015
-- Description:	Data Dictionary Dataset
-- =============================================
CREATE PROCEDURE [SSRS].[uspListAllIndexes]

	@TableSchema varchar(120) = NULL,
	@TableName varchar(120) = NULL
	   
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

       
SELECT
	0 SSRSOrder,
	SCHEMA_NAME(T.schema_id) SchemaName, 
	T.NAME TableName,
	I.name IndexName,
	c.name ColumnName,
	I.is_primary_key [Primary],
	I.is_unique [Unique],
	I.TYPE_DESC IndexType
FROM 
	sys.tables T
	INNER JOIN SYS.indexes I
		ON T.object_id = I.object_id
	INNER JOIN sys.index_columns IC
		ON IC.object_id = I.object_id
	INNER JOIN SYS.columns C
		ON IC.object_id = C.object_id
		AND ic.column_id = c.column_id
		AND IC.index_id = I.index_id
WHERE
	SCHEMA_NAME(T.schema_id) = @TableSchema
	AND T.NAME = @TableName
UNION --Blank row so sub-report header shows when no data rows
SELECT
	1 SSRSOrder,
	'',
	'',
	'',
	'',
	0,
	0,
	''
ORDER BY
	SSRSOrder, 
	SchemaName,
	T.NAME,
	I.is_primary_key DESC,
	C.name,
	I.NAME
		
END