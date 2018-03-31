USE [GIO_Asset_DBA]
GO

/****** Object:  View [SSRS].[vDataBases]    Script Date: 11/09/2017 12:15:46 ******/
DROP VIEW [SSRS].[vDataBases]
GO

/****** Object:  View [SSRS].[vDataBases]    Script Date: 11/09/2017 12:15:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [SSRS].[vDataBases]
WITH SCHEMABINDING
AS
SELECT DD.DataBaseName,Count_Big(*) Count
FROM
	[DBA].[DataDictionary] DD
GROUP BY
	DD.DataBaseName


GO

CREATE UNIQUE CLUSTERED INDEX CIX_SSRS_vDataBases_DatabaseName
ON [SSRS].[vDataBases] (DataBaseName)