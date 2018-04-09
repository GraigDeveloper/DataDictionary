USE DBA

/****** Object:  StoredProcedure [PQRD].[uspConstraintsCheckDefault]    Script Date: 05/14/2015 12:48:20 ******/
IF  EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[SSRS].[uspListConstraintsCheckDefault]') AND type in (N'P', N'PC'))
DROP PROCEDURE [SSRS].[uspListConstraintsCheckDefault]
GO

GO

/****** Object:  StoredProcedure [PQRD].[uspListConstraintsCheckDefault]    Script Date: 05/14/2015 12:48:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [SSRS].[uspListConstraintsCheckDefault]
	@DatabaseName varchar(128),
	@TABLE_SCHEMA varchar(120) = NULL,
	@TABLE_NAME varchar(120) = NULL
	
AS
BEGIN
	
SELECT
	DatabaseName,
	[COLUMN_NAME],
	[ConstraintName],
	[DefaultValue],
	[CheckValue]
FROM 
	SSRS.CheckConstraints
WHERE	
		DatabaseName=@DatabaseName
		AND [TABLE_SCHEMA] = @TABLE_SCHEMA
		AND TABLE_NAME  = @TABLE_NAME

END

GO


