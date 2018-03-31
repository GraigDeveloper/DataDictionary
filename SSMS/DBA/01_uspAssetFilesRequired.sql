
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'uspAssetFilesRequired')
DROP PROCEDURE SSIS.uspAssetFilesRequired

GO

CREATE PROCEDURE SSIS.uspAssetFilesRequired
@CustomerShortName varchar(10),@FileReq bit
AS

WITH FilesRequired
AS
(
SELECT CustomerShortName, FileType,FileReq
FROM 
   (SELECT 
		CustomerShortName,
		[ITSMFileReq],
		[ERACENTFileReq],
		[SCCMFileReq],
		[ADFileReq],
		[WYSEFileReq],
		[SEPFileReq]
   FROM [MngData].[CustomerDataFileMatrix]
   WHERE CustomerShortName = @CustomerShortName ) p
UNPIVOT
   (FileReq FOR FileType IN 
      ([ITSMFileReq],
		[ERACENTFileReq],
		[SCCMFileReq],
		[ADFileReq],
		[WYSEFileReq],
		[SEPFileReq])
)AS unpvt
)
SELECT 
	CASE 
		WHEN FileType='ITSMFileReq' THEN @CustomerShortName + 'Full Inventory.xlsx'
		WHEN FileType='ERACENTFileReq' THEN @CustomerShortName + 'Eracent.xlsx'
		WHEN FileType='SCCMFileReq' THEN @CustomerShortName + 'SSCMEU.xlsx'
		WHEN FileType='ADFileReq' THEN @CustomerShortName + 'ADEU.xlsx'
		WHEN FileType='WYSEFileReq' THEN @CustomerShortName + 'WYSE.xlsx'
		WHEN FileType='SEPFileReq' THEN @CustomerShortName + 'SEPStatus.xlsx'
	END FileReq
FROM 
	FilesRequired
WHERE
	FileReq=@FileReq