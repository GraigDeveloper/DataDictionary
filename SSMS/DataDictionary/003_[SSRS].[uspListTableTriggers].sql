USE [DBA]
GO

/****** Object:  StoredProcedure [SSRS].[uspListTableTriggers]    Script Date: 4/6/2018 12:18:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [SSRS].[uspListTableTriggers]
	@DatabaseName varchar(128),
	@TABLE_SCHEMA varchar(128), 
	@TABLE_NAME varchar(128)
AS
	BEGIN
	
	SELECT
		DatabaseName, 
		Table_Schema,
		Table_Name,
		TriggerName,
		TriggerCreateDate,
		TriggerText
	FROM
		DBA.SSRS.TableTriggers
	WHERE
		DatabaseName =@DatabaseName
		AND [Table_Schema] = @Table_Schema 
		AND [Table_Name]= @Table_Name 

	
	END
	
	


GO


