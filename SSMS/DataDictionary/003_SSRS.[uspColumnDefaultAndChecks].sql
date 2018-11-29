DROP PROCEDURE IF EXISTS SSRS.[uspColumnDefaultAndChecks]

GO

CREATE PROCEDURE SSRS.[uspColumnDefaultAndChecks]
	@DatabaseName VARCHAR(120),
	@TableSchema VARCHAR(120),
	@TableName VARCHAR(120)

AS

BEGIN

SELECT 
	COLUMN_NAME,
	ConstraintName,
	DefaultValue,
	CheckValue 
FROM 
	[DBA].[ColumnDefaultAndChecks]
WHERE
DatabaseName = @DatabaseName
AND TABLE_SCHEMA = @TableSchema
AND TABLE_NAME = @TableName

END