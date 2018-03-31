/****** Object:  StoredProcedure [DBA].[uspAddTableDescription]    Script Date: 10/07/2015 10:34:32 ******/
IF  EXISTS (SELECT * FROM sys.objects 
      WHERE object_id = OBJECT_ID(N'[DBA].[uspAddColumnDescription]') AND type in (N'P', N'PC'))

            DROP PROCEDURE [DBA].[uspAddColumnDescription]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DBA].[uspAddColumnDescription]
@ObjectType  nvarchar(128),
@TableSchema nvarchar(128),
@TableName nvarchar(128),
@ColumnName nvarchar(128),
@ColumnDescription nvarchar(1000)
AS

BEGIN

      SET @ColumnDescription =ISNULL(@ColumnDescription,'----------------------------------')
      
      IF EXISTS (
                        SELECT   *
                        FROM   
                        ::fn_listextendedproperty (
                                    NULL, 
                                    'Schema', 
                                    @TableSchema, 
                                    @ObjectType, 
                                    @TableName, 
                                    'column', 
                                    @ColumnName)
                        WHERE
                              ObjName = @ColumnName
                              AND Name ='Description')
                  
                  EXEC 
                        sys.sp_updateextendedproperty 
                        @name = N'Description',
                        @level0type = N'SCHEMA' ,
                        @level0name = @TableSchema,
                        @level1type = @ObjectType,
                        @level1name = @TableName,
                        @level2type = N'Column',
                        @level2name = @ColumnName
      
      ELSE
      
            EXEC 
                  sys.sp_addextendedproperty 
                  @name = N'Description',
                  @Value = @ColumnDescription,
                  @level0type = N'SCHEMA' ,
                  @level0name = @TableSchema,
                  @level1type = @ObjectType,
                  @level1name = @TableName,
                  @level2type = N'Column',
                  @level2name = @ColumnName

      
END

go
/****** Object:  StoredProcedure [DBA].[uspAddTableDescription]    Script Date: 10/07/2015 10:34:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DBA].[uspAddTableDescription]') AND type in (N'P', N'PC'))
DROP PROCEDURE [DBA].[uspAddTableDescription]
GO

/****** Object:  StoredProcedure [DBA].[uspAddTableDescription]    Script Date: 10/07/2015 10:34:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [DBA].[uspAddTableDescription]
@ObjectType varchar(5),
@TableSchema nvarchar(128),
@TableName nvarchar(128),
@TableDescription nvarchar(1000)
AS

BEGIN

      SET @TableDescription =ISNULL(@TableDescription,'----------------------------------')
      
      IF EXISTS (
                        SELECT   *
                        FROM   
                        ::fn_listextendedproperty (
                                    NULL, 
                                    'Schema', 
                                    @TableSchema, 
                                    @ObjectType, 
                                    @TableName, 
                                    null, 
                                    null)
                        WHERE
                              ObjName = @TableName
                              AND Name ='dESCRIPTION')
                  
                  EXEC 
                        sys.sp_updateextendedproperty 
                        @name = N'Description',
                        @level0type = N'SCHEMA' ,
                        @level0name = @TableSchema,
                        @level1type = @ObjectType,
                        @level1name = @TableName
      
      ELSE
      
            EXEC 
                  sys.sp_addextendedproperty 
                  @name = N'Description',
                  @value = @TableDescription,
                  @level0type = N'SCHEMA' ,
                  @level0name = @TableSchema,
                  @level1type = @ObjectType,
                  @level1name = @TableName

      
END
