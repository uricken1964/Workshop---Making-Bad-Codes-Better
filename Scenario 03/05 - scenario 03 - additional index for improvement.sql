/*
	============================================================================
	File:		05 - scenario 03 - additional index for improvement.sql

	Summary:	After we implemented the fix from the vendor we had the same
				issue as before. So we must change the query by ourself!
				
				Use https://statisticsparser.com to analyze the usage of resources!

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
USE [ERP_Demo]
GO

CREATE NONCLUSTERED INDEX nix_persons_ccc_aliasname ON dbo.persons
(ccc_aliasname)
WITH 
(DATA_COMPRESSION = PAGE)
GO

