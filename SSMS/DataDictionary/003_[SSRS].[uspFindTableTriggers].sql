USE DBA
/****** Object:  StoredProcedure [PQRD].[uspFindTableTriggers]    Script Date: 05/19/2015 17:03:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SSRS].[uspFindTableTriggers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SSRS].[uspFindTableTriggers]
GO

/****** Object:  StoredProcedure [PQRD].[uspFindTableTriggers]    Script Date: 05/19/2015 17:03:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSRS].[uspFindTableTriggers]
	@TableSchema varchar(128), 
	@TableName varchar(128)
AS
	BEGIN
	
	SELECT
		0 SSRSOrder, 
		object_schema_name(Triggers.parent_obj) SchemaName,
		Tables.Name TableName,
		Triggers.name TriggerName,
		Triggers.crdate TriggerCreatedDate,
		Comments.Text TriggerText
	 FROM
			sysobjects Triggers
			Inner Join sysobjects Tables 
				On Triggers.parent_obj = Tables.id
			Inner Join syscomments Comments 
				On Triggers.id = Comments.id
	 WHERE
			object_schema_name(Triggers.parent_obj) = @TableSchema
			AND Tables.Name	= @TableName
			AND Triggers.xtype = 'TR'
			And Tables.xtype = 'U'
	UNION --Blank row so sub-report header shows when no data rows
SELECT
	1 SSRSOrder,
	'',
	'',
	'',
	'',
	''
ORDER BY
	SSRSOrder		
	
	END
	
	


GO


