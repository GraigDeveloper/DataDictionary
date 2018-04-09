-- ==============================================================================
-- Author:        Peter QR Davies
-- Create date: 01-Sep-2015
-- Description:   Part of DataDictionary Application consiting of 
--                      SQL Server Stored Procedures
--                      SQL Server Scripts
--                      SSRS Report DataDictionary & Sub-Reports
--                      Visual Studio DataDictionary Application
-- 
-- Drops then creates tables required to hold DataDictionary Information
--
-- All tables created held in schema DBA
--
--          DataDictionary: Meta data for table/view columns ( Used for SSRS Report)
--          DataDictionaryTableDesc: Table Descriptions (Used for SSRS Report & Updating SQl Server extended properties)
--          DataDictionaryColumnDesc: Column Descriptions (Used for SSRS Report & Updating SQl Server extended properties)
--    
-- Script Version: 1.0 (01-Sep-2015)
-- Report Spec:  DataDictionary Report_v1.0_01-Sep-2015 
-- ===========================================================================
USE DBA
/****** Object:  Table DBA.DataDictionary    Script Date: 07/09/2015 13:23:36 ******/
IF  EXISTS (SELECT * FROM sys.objects 
      WHERE object_id = OBJECT_ID(N'DBA.DataDictionary') AND type in (N'U'))

      DROP TABLE DBA.DataDictionary

IF  EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[DBA].[DataDictionaryTableDesc]') AND type in (N'U'))

      DROP TABLE [DBA].[DataDictionaryTableDesc]

IF  EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[DBA].[DataDictionaryColumnDesc]') AND type in (N'U'))

      DROP TABLE [DBA].[DataDictionaryColumnDesc]
 
DROP TABLE IF EXISTS [SSRS].[TableTriggers]

DROP TABLE IF EXISTS [SSRS].[CheckConstraints]

/****** Object:  Table DBA.DataDictionary    Script Date: 07/09/2015 13:23:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

----------------CREATE TABLES

--DBA.DataDictionary
CREATE TABLE DBA.DataDictionary(
	  [DatabaseName][VARCHAR](128) NOT NULL,
      [TABLE_SCHEMA] [VARCHAR](128) NOT NULL,
      [TABLE_NAME] [VARCHAR](128) NOT NULL,
      [COLUMN_NAME] [VARCHAR](128) NOT NULL,
      [ORDINAL_POSITION] [INT] NULL,
      [COLUMN_DEFAULT] [NVARCHAR](4000) NULL,
      [IS_NULLABLE] [VARCHAR](3) NULL,
      [DATA_TYPE] [VARCHAR](128) NULL,
      [CHARACTER_MAXIMUM_LENGTH] [INT] NULL,
      [CHARACTER_OCTET_LENGTH] [INT] NULL,
      [NUMERIC_PRECISION] [TINYINT] NULL,
      [NUMERIC_PRECISION_RADIX] [SMALLINT] NULL,
      [NUMERIC_SCALE] [INT] NULL,
      [DATETIME_PRECISION] [SMALLINT] NULL,
      [CHARACTER_SET_CATALOG] [sysname] NULL,
      [CHARACTER_SET_SCHEMA] [sysname] NULL,
      [CHARACTER_SET_NAME] [sysname] NULL,
      [COLLATION_CATALOG] [sysname] NULL,
      [COLLATION_SCHEMA] [sysname] NULL,
      [COLLATION_NAME] [sysname] NULL,
      [DOMAIN_CATALOG] [sysname] NULL,
      [DOMAIN_SCHEMA] [sysname] NULL,
      [DOMAIN_NAME] [sysname] NULL,
      [IsPrimaryKey] [BIT] DEFAULT(0) NOT NULL,
      [IsForeignKey] [BIT] DEFAULT(0)NOT NULL,
      [IsRequired] [BIT] DEFAULT(0) NOT NULL
CONSTRAINT [PK_DataDictionary] PRIMARY KEY CLUSTERED 
(	  [DatabaseName] ASC,
      [TABLE_SCHEMA] ASC,
      [TABLE_NAME] ASC,
      [COLUMN_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, 
IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--[DBA].[DataDictionaryTableDesc]
CREATE TABLE [DBA].[DataDictionaryTableDesc](
      [DatabaseName][VARCHAR](128) NOT NULL,
      [TABLE_SCHEMA] [varchar](128) NOT NULL,
      [TABLE_NAME] [varchar](128) NOT NULL,
      [ObjectType] [varchar](5) Default ('Table'),    
      [TableDescription] [varchar](1000) NULL,  
      [TableRowCount] [BIGINT],
      [TableActive] [bit] Default(1) NOT NULL,
	  [HasTriggers] [bit] Default(0) NOT NULL,
	  [HasCheckConstraints] [bit] Default(0) NOT NULL
CONSTRAINT [PK_DataDictionaryTableDesc] PRIMARY KEY CLUSTERED 
(
	  [DatabaseName] ASC,
      [TABLE_SCHEMA] ASC,
      [TABLE_NAME] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, 
IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--[DBA].[DataDictionaryColumnDesc]
CREATE TABLE [DBA].[DataDictionaryColumnDesc](
	  [DatabaseName][VARCHAR](128) NOT NULL,  
      [TABLE_SCHEMA] [varchar](128) NOT NULL,
      [TABLE_NAME] [varchar](128) NOT NULL,
      [ObjectType] [varchar](5) Default ('Table'),          
      [COLUMN_NAME] [VARCHAR](128) NOT NULL,
      [ColumnDescription] [varchar](1000) NULL
CONSTRAINT [PK_DataDictionaryColumnDesc] PRIMARY KEY CLUSTERED 
(     [DatabaseName] ASC,
      [TABLE_SCHEMA] ASC,
      [TABLE_NAME] ASC,
      [COLUMN_NAME]
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, 
IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

--[SSRS].[TableTriggers]
CREATE TABLE [SSRS].[TableTriggers](
	[DatabaseName] [varchar](128) NOT NULL,
	[TABLE_SCHEMA] [varchar](128) NOT NULL,
	[TABLE_NAME] [varchar](128) NOT NULL,
	[TriggerName] [varchar](128) NOT NULL,
	[TriggerCreateDate] [datetime] NOT NULL,
	[TriggerText] [varchar](max) NOT NULL,
 CONSTRAINT [PK_SSRS_TableTriggers] PRIMARY KEY CLUSTERED 
(
	[DatabaseName] ASC,
	[TABLE_SCHEMA] ASC,
	[TABLE_NAME] ASC,
	[TriggerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--[SSRS].[CheckConstraints]
CREATE TABLE [SSRS].[CheckConstraints](
	[DatabaseName] [varchar](128) NOT NULL,
	[TABLE_SCHEMA] [varchar](128) NOT NULL,
	[TABLE_NAME] [varchar](128) NOT NULL,
	[COLUMN_NAME] [varchar](128) NOT NULL,
	[ConstraintName] nvarchar(128) NOT NULL,
	[DefaultValue] nvarchar(max) NULL,
	[CheckValue] [varchar](max) NULL,
 CONSTRAINT [PK_SSRS_CheckConstraints] PRIMARY KEY CLUSTERED 
(
	[DatabaseName] ASC,
	[TABLE_SCHEMA] ASC,
	[TABLE_NAME] ASC,
	[COLUMN_NAME] ASC,
	[ConstraintName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

