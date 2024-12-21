/*
	============================================================================
	File:		0041 - scenario 01 - preparation.sql

	Summary:	This script prepares tables in the database ERP_Demo
				for the chapter
				- bad code - usage of functions
				
				THIS SCRIPT IS PART OF THE WORKSHOP:
					"Workshop - Making Bad Codes better"

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

/* Create all necessary indexes on the tables! */
EXEC dbo.sp_create_indexes_customers;
GO

EXEC dbo.sp_create_indexes_orders;
GO

EXEC dbo.sp_create_indexes_nations;
GO

/* Create the foreign key references on the tables */
EXEC dbo.sp_create_foreignkeys
	@master_table = 'dbo.nations',
    @detail_table = N'dbo.customers';
GO

EXEC dbo.sp_create_foreignkeys
	@master_table = 'dbo.customers',
    @detail_table = N'dbo.orders';
GO