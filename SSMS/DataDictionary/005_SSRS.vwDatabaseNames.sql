CREATE VIEW SSRS.vwDatabaseNames
AS
SELECT DISTINCT 
	DatabaseName 
FROM 
	[DBA].[DataDictionary]