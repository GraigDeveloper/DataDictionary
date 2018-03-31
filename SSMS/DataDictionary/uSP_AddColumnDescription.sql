USE DBA
go
--============================================
-- Author:		PQRD
-- Create date: 20140721
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[uSP_AddColumnDescription] 
	-- Add the parameters for the stored procedure here
	@SchemaName nvarchar(128),
	@TableName nvarchar(128),
	@ColumnName nvarchar (128), 
	@ColumnDescription nvarchar(128) -- Max allowed by function below
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC sys.sp_addextendedproperty 
		@name = N'MS_Description', 
		@value = @ColumnDescription, 
		@level0type = N'SCHEMA', @level0name = @SchemaName, 
		@level1type = N'TABLE',  @level1name = @TableName,
		@level2type = N'COLUMN',  @level2name = @ColumnName
END





GO


