SELECT * FROM SYS.indexes
SELECT * FROM SYS.index_columns
SELECT * FROM SYS.COLUMNS

SELECT SO.[NAME],SI.name,SCOL.name FROM SYS.objects SO
INNER JOIN SYS.indexes SI
ON SO.object_id =SI.object_id
INNER JOIN SYS.index_columns SIC
ON SO.object_id = SIC.object_id
INNER JOIN SYS.columns SCOL
ON SO.object_id = SCOL.object_id
where so.[type] = 'U'