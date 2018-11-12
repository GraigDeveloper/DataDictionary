USE DBA

DROP PROCEDURE IF EXISTS dba.usp_TableSchema 


GO

Create Procedure dba.usp_TableSchema 
@DatabaseName varchar(64)
as
begin
Declare @SQL nvarchar(1000)

set @SQL ='SELECT ''%'' AS [Schema] UNION ALL select distinct TABLE_SCHEMA from [' + @DatabaseName + '].INFORMATION_SCHEMA.TABLES '

exec sp_executesql @SQL

end