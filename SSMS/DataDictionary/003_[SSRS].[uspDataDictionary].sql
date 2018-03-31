/****** Object:  StoredProcedure [DBA].[uspDataDictionary]    Script Date: 09/07/2015 16:31:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SSRS].[uspDataDictionary]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SSRS].[uspDataDictionary]
GO

/****** Object:  StoredProcedure [DBA].[uspDataDictionary]    Script Date: 09/07/2015 16:31:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		PQR Davies
-- Create date: 12-May-2015
-- Description:	Data Dictionary Dataset
-- =============================================
CREATE PROCEDURE [SSRS].[uspDataDictionary]
@DataBaseName VARCHAR(128) ,
@TABLE_SCHEMA VARCHAR(128) = '%',
@TableActiveStatus bit = 1
	   
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @TABLE_SCHEMA = 'ALL'
		SET @TABLE_SCHEMA ='%'
      
	SELECT 
		DD.*,
		DDTD.TableDescription,
		DDTD.TableRowCount,
		DDCD.ColumnDescription,
		DDTD.TableActive
	FROM 
		DBA.DataDictionary DD
		LEFT JOIN DBA.DataDictionaryTableDesc DDTD
			ON DD.DatabaseName = DDTD.DatabaseName
			AND DD.TABLE_SCHEMA = DDTD.TABLE_SCHEMA
			AND DD.TABLE_NAME = DDTD.TABLE_NAME
		LEFT JOIN DBA.DataDictionaryColumnDesc DDCD
			ON DD.DatabaseName = DDCD.DatabaseName
			AND DD.TABLE_SCHEMA = DDCD.TABLE_SCHEMA
			AND DD.TABLE_NAME = DDCD.TABLE_NAME
			AND DD.COLUMN_NAME = DDCD.COLUMN_NAME
	WHERE
		DD.DatabaseName = @DatabaseName
		AND DD.TABLE_SCHEMA LIKE @TABLE_SCHEMA
		AND (DDTD.TableActive =1					--If @TableActiveStaus = 1 only shows active tables
		OR DDTD.TableActive = @TableActiveStatus )--If @TableActiveStaus = 0 only shows active and non-active tables
		
END





GO


