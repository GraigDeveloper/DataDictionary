--==============================================================================
-- Author:        Peter QR Davies
-- Create date: 01-Sep-2015
-- Description:   Part of DataDictionary Application consiting of 
--                      SQL Server Stored Procedures
--                      SQL Server Scripts
--                      SSRS Report DataDictionary & Sub-Reports
--                      Visual Studio DataDictionary Application
-- 
-- Creates three schemas/Object grouping within target database
--
--
-- Script Version: 1.0 (01-Sep-2015)
-- Report Spec:         DataDictionary Report_v1.0_01-Sep-2015 
-- ===========================================================================

USE DBA
--Data Base Administrator
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DBA')

      exec('exec sp_executesql N''create schema DBA'' ')

--SSRS Reports    
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'SSRS')

      exec('exec sp_executesql N''create schema SSRS'' ')

--Visual Studio
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'VS')

      exec('exec sp_executesql N''create schema VS'' ')
