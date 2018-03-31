GO

/****** Object:  StoredProcedure [PQRD].[uspConstraintsCheckDefault]    Script Date: 05/14/2015 12:48:20 ******/
IF  EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[SSRS].[uspStaticData]') 
	AND type in (N'P', N'PC'))
	
		DROP PROCEDURE [SSRS].[uspStaticData]

GO

SET QUOTED_IDENTIFIER ON

GO


CREATE PROCEDURE [SSRS].[uspStaticData]

	@Table_Schema varchar(120) = NULL,
	@Table_Name varchar(120) = NULL
	
AS
BEGIN
	
SELECT
   TABLE_SCHEMA,
   TABLE_NAME,
   type [Type],
   description,
   version,
   0 AS SSRSOrder
FROM 
	DBA.DataDictionaryStaticData
WHERE	
	TABLE_CATALOG ='PECS'
	AND TABLE_SCHEMA  = COALESCE (@Table_Schema,TABLE_SCHEMA)
	AND TABLE_NAME = COALESCE (@Table_Name,TABLE_NAME)	
UNION --Blank row so sub-report header shows when no data rows
SELECT
	'',
	'',
	-1,
	'',
	-1,
1 AS SSRSOrder
ORDER BY
	SSRSOrder,
	TABLE_SCHEMA,
	TABLE_NAME
		
END

GO