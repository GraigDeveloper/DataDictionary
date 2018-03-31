

USE DBA
go
-- =============================================
-- Author:		PQRD
-- Create date: 20140721
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uSP_AddTableDescription] 
	-- Add the parameters for the stored procedure here
	@SchemaName nvarchar(128),
	@TableName nvarchar(128), 
	@TableDescription nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC sys.sp_addextendedproperty 
		@name = N'MS_Description', 
		@value = @TableDescription, 
		@level0type = N'SCHEMA', @level0name = @SchemaName, 
		@level1type = N'TABLE',  @level1name = @TableName

END


GO


