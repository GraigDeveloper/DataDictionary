USE DBA
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
	@DatabaseName varchar(128) = NULL,
	@Table_Schema varchar(120) = NULL,
	@Table_Name varchar(120) = NULL
	   
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

       
SELECT
	[DatabaseName]
    ,[TABLE_SCHEMA]
    ,[TABLE_NAME]
    ,[IndexName]
    ,[COLUMN_NAME]
    ,[IsPrimary]
    ,[IsUnique]
    ,[IndexType]
FROM 
	[DBA].[SSRS].[Indexes]
WHERE
	[DatabaseName]= @DatabaseName
	AND [TABLE_SCHEMA] = @Table_Schema
	AND [TABLE_NAME]= @Table_Name
ORDER BY
	[TABLE_SCHEMA],
	[TABLE_NAME],
	[IsPrimary] DESC,
	[IsUnique],
    [IndexType]
		
END