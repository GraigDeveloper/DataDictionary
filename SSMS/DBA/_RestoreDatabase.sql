USE [master]
ALTER DATABASE [GIO_Asset_DEV] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [GIO_Asset_DEV] FROM  DISK = N'N:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\PQRD_GIO_DEV_Asset_250817..bak' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [GIO_Asset_DEV] SET MULTI_USER