/*
	============================================================================
	File:		06 - scenario 01 - optimization phase 03.sql

	Summary:	This script optimize the table valued function that way
				that we make a multi line function a inline function
				
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
	Function Name:	dbo.calculate_customer_category
	Parameters:		@c_custkey		=>	customer key from dbo.customers
					@int_orderyear	=>	year of the status earned

	Description:	This user definied function calculates the number of
					orders a customer has placed for a specific year
*/
DROP FUNCTION IF EXISTS dbo.calculate_customer_category;
GO

CREATE OR ALTER FUNCTION dbo.calculate_customer_category
(
	@c_custkey		BIGINT,
	@int_orderyear	INT
)
RETURNS TABLE
AS
RETURN
(
	WITH noo
	AS
	(
		SELECT	COUNT_BIG(*)	AS	num_of_orders
		FROM	dbo.orders
		WHERE	o_custkey = @c_custkey
				AND o_orderdate >= DATEFROMPARTS(@int_orderyear, 1, 1)
				AND o_orderdate < DATEFROMPARTS(@int_orderyear + 1, 1, 1)
	)
	SELECT	@c_custkey			AS	c_custkey,
			noo.num_of_orders	AS	num_of_orders,
			CASE
				WHEN noo.num_of_orders >= 20	THEN 'A'
				WHEN noo.num_of_orders >= 10	THEN 'B'
				WHEN noo.num_of_orders >= 5		THEN 'C'
				WHEN noo.num_of_orders >= 1		THEN 'D'
				ELSE 'Z'
			END		AS	classification
	FROM	noo
);
GO