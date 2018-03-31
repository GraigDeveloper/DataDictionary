USE GIO_Asset_DBA

GO

IF OBJECT_ID('tempdb..#CoulumnDescrptions') IS NOT NULL
/*Then it exists*/
   DROP TABLE #CoulumnDescrptions
   
CREATE TABLE #CoulumnDescrptions
      (DatabaseName varchar(128),
	  TABLE_SCHEMA varchar(128),
      TABLE_NAME varchar(128),
      COLUMN_NAME varchar(128),
      ColumnDescription varchar(1000))
      
------For Each User Table/View in Database
      
--Add Table/View Propertites to DBA.DataDictionaryTableDesc
--First populate the three supporting table for the DataDictionary App
--Then add the table and column descrip[tions for the user database

--DBA.DataDictionary
UPDATE DBA.DataDictionaryTableDesc
SET TableDescription ='Contains description of a table in the database.',     
      TableActive = 1
WHERE
TABLE_SCHEMA = 'DBA'
AND TABLE_NAME = 'DataDictionary'

INSERT INTO #CoulumnDescrptions
VALUES
      ('GIO_Asset_DBA','DBA','DataDictionary','CHARACTER_MAXIMUM_LENGTH','Maximum length, in characters, for binary data, character data, or text and image data.-1 for xml and large-value type data. Otherwise, NULL is returned. For more information, see Data Types (Transact-SQL).'),
      ('GIO_Asset_DBA','DBA','DataDictionary','CHARACTER_OCTET_LENGTH','Maximum length, in bytes, for binary data, character data, or text and image data.-1 for xml and large-value type data. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','CHARACTER_SET_CATALOG','Returns master. This indicates the database in which the character set is located, if the column is character data or text data type. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','CHARACTER_SET_NAME','Returns the unique name for the character set if this column is character data or text data type. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','CHARACTER_SET_SCHEMA','Always returns NULL.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','COLLATION_CATALOG','Always returns NULL.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','COLLATION_NAME','Returns the unique name for the collation if the column is character data or text data type. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','COLLATION_SCHEMA','Always returns NULL.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','COLUMN_DEFAULT','Default value of the column.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','COLUMN_NAME','Column name.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','DATA_TYPE','System-supplied data type.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','DATETIME_PRECISION','Subtype code for datetime and ISO interval data types. For other data types, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','DOMAIN_CATALOG','If the column is an alias data type, this column is the database name in which the user-defined data type was created. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','DOMAIN_NAME','If the column is a user-defined data type, this column is the name of the user-defined data type. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','DOMAIN_SCHEMA','If the column is a user-defined data type, this column returns the name of the schema of the user-defined data type. Otherwise, NULL is returned.Do not use INFORMATION_SCHEMA views to determine the schema of a data type. The only reliable way to find the schema of a type is to use the TYPEPROPERTY function.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','IS_NULLABLE','Nullability of the column. If this column allows for NULL, this column returns YES. Otherwise, NO is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','IsForeignKey','if 1 then column is part of Foreign Key'),
      ('GIO_Asset_DBA','DBA','DataDictionary','IsPrimaryKey','if 1 then column is part of Primary Key'),
      ('GIO_Asset_DBA','DBA','DataDictionary','IsRequired','if 1 then column cannot contain NULL'),
      ('GIO_Asset_DBA','DBA','DataDictionary','NUMERIC_PRECISION','Precision of approximate numeric data, exact numeric data, integer data, or monetary data. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','NUMERIC_PRECISION_RADIX','Precision radix of approximate numeric data, exact numeric data, integer data, or monetary data. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','NUMERIC_SCALE','Scale of approximate numeric data, exact numeric data, integer data, or monetary data. Otherwise, NULL is returned.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','ORDINAL_POSITION','Column identification number.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','TABLE_NAME','Table name.'),
      ('GIO_Asset_DBA','DBA','DataDictionary','TABLE_SCHEMA','Name of schema that contains the table.Do not use INFORMATION_SCHEMA views to determine the schema of an object. The only reliable way to find the schema of a object is to query the sys.objects catalog ')
      
--Update DBA.DataDictionaryColumnDesc using
--temporary table #CoulumnDescrptions populated by user data

UPDATE 
      DBA.DataDictionaryColumnDesc
SET 
      ColumnDescription = CD.ColumnDescription
FROM
#CoulumnDescrptions CD
INNER JOIN DBA.DataDictionaryColumnDesc DDCD
      ON  CD.DatabaseName = DDCD.DatabaseName
	  AND CD.TABLE_SCHEMA = DDCD.TABLE_SCHEMA
      AND CD.TABLE_NAME = DDCD.TABLE_NAME
      AND CD.COLUMN_NAME = DDCD.COLUMN_NAME
      
IF OBJECT_ID('tempdb..#CoulumnDescrptions') IS NOT NULL
/*Then it exists*/
   DROP TABLE #CoulumnDescrptions
