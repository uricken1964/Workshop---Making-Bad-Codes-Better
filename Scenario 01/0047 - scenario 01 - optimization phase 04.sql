/*
	============================================================================
	File:		0047 - scenario 01 - optimization phase 04.sql

	Summary:	The deletion process covers lots of indexes.
				It is important to check how the indexes get used.
				It might be useful to delete unnecessary indexes!
				
				THIS SCRIPT IS PART OF THE WORKSHOP:
					"Performance optimization by identifying and correcting bad SQL code"

	Date:		October 2024
	Revion:		November 2024

	SQL Server Version: >= 2016
	------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
	============================================================================
*/
USE ERP_Demo;
GO

/*
	Let's check the indexes in the table dbo.jobqueue!
*/
SELECT	i.index_id,
		i.name,
		i.type_desc,
		i.is_unique,
		i.is_primary_key,
		i.is_unique_constraint,
        ddius.user_seeks,
        ddius.user_scans,
        ddius.user_lookups,
        ddius.user_updates,
        ddius.last_user_seek,
        ddius.last_user_scan,
        ddius.last_user_lookup,
        ddius.last_user_update
FROM	sys.indexes AS i
		INNER JOIN sys.dm_db_index_usage_stats AS ddius
		ON	(
				i.index_id = ddius.index_id
				AND i.object_id = ddius.object_id
			)
WHERE	ddius.database_id = DB_ID()
		AND i.object_id = OBJECT_ID(N'dbo.jobqueue', N'U')
ORDER BY
		i.index_id ASC;
GO

/*
	Let's remove indexes which are not used in the table.

	NOTE:	this is only for demo purposes and fits to this specific scenario
			Don't delete vendor indexes without permissions
			Do not rely on these statistics only but check Query Store or your
			Execution plans whether other indexes on the table are used!!!
*/
DROP INDEX nix_jobqueue_sortorder	ON dbo.jobqueue;
DROP INDEX nix_jobqueue_genprocid	ON dbo.jobqueue;
DROP INDEX nix_jobqueue_uid_task	ON dbo.jobqueue;
DROP INDEX nix_jobqueue_objectname	ON dbo.jobqueue;
DROP INDEX ccc_jobqueue_sr02506778	ON dbo.jobqueue;
GO

/*
	Let's check the indexes in the table dbo.jobqueue!
*/
SELECT	i.index_id,
		i.name,
		i.type_desc,
		i.is_unique,
		i.is_primary_key,
		i.is_unique_constraint,
        ddius.user_seeks,
        ddius.user_scans,
        ddius.user_lookups,
        ddius.user_updates,
        ddius.last_user_seek,
        ddius.last_user_scan,
        ddius.last_user_lookup,
        ddius.last_user_update
FROM	sys.indexes AS i
		INNER JOIN sys.dm_db_index_usage_stats AS ddius
		ON	(
				i.index_id = ddius.index_id
				AND i.object_id = ddius.object_id
			)
WHERE	ddius.database_id = DB_ID()
		AND i.object_id = OBJECT_ID(N'dbo.jobqueue', N'U')
ORDER BY
		i.index_id ASC;
GO