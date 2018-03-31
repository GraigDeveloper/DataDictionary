GO

/****** Object:  StoredProcedure [PQRD].[uspConstraintsCheckDefault]    Script Date: 05/14/2015 12:48:20 ******/
IF  EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[SSRS].[uspConstraintsCheckDefault]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SSRS].[uspConstraintsCheckDefault]
GO

GO

/****** Object:  StoredProcedure [PQRD].[uspConstraintsCheckDefault]    Script Date: 05/14/2015 12:48:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSRS].[uspConstraintsCheckDefault]

	@TableSchema varchar(120) = NULL,
	@TableName varchar(120) = NULL
	
AS
BEGIN
	
SELECT
	0 SSRSOrder, 
    TableName = t.Name,
    ColumnName = c.Name,
    dc.Name,
    dc.definition DefaultVale,
    cc.definition CheckValue,
    S.name SchemaName
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
WHERE	
		S.name = COALESCE (@TableSchema,S.name)
		AND t.name  = COALESCE (@TableName,t.name)
UNION --Blank row so sub-report header shows when no data rows
SELECT
	1 SSRSOrder,
	'',
	'',
	'',
	'',
	'',
	''
ORDER BY
	SSRSOrder	
	
END

GO


