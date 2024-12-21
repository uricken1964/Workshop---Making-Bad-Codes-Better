/*
	============================================================================
	File:		0042 - scenario 01 - user definied function.sql

	Summary:	The developer created a user definied function for the calculation
				of the status of a customer. This script shows the ORIGINAL function
				as it has been implemented beforehand.

				The user definied function returns thre columns

				| c_custkey | num_of_orders | classification |
				
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
CREATE OR ALTER FUNCTION dbo.calculate_customer_category
(
	@c_custkey		BIGINT,
	@int_orderyear	INT
)
RETURNS @t TABLE
(
	c_custkey		BIGINT	NOT NULL	PRIMARY KEY CLUSTERED,
	num_of_orders	INT		NOT NULL	DEFAULT (0),
	classification	CHAR(1)	NOT NULL	DEFAULT ('Z')
)
BEGIN

	/*
		if the customer does not have any orders in the specific year
		we return the value "Z"
	*/
	DECLARE	@num_of_orders	INT;

	/* Insert the c_custkey into the table variable */
	INSERT INTO @t (c_custkey) VALUES (@c_custkey);

	/* How many orders has the customer for the specific year */
	SELECT	@num_of_orders = COUNT(*)
	FROM	dbo.orders
	WHERE	o_custkey = @c_custkey
			AND YEAR(o_orderdate) = @int_orderyear;

	/* Update the value for num_of_orders in the table variable */
	UPDATE	@t
	SET		num_of_orders = @num_of_orders
	WHERE	c_custkey = @c_custkey;

	/* Depending on the number of orders we define what category the customer is */
	IF @num_of_orders = 0
		RETURN;

	IF @num_of_orders >= 20
	BEGIN
		UPDATE	@t
		SET		classification = 'A'
		WHERE	c_custkey = @c_custkey;

		RETURN;
	END

	IF @num_of_orders >= 10
	BEGIN
		UPDATE	@t
		SET		classification = 'B'
		WHERE	c_custkey = @c_custkey;
		
		RETURN;
	END

	IF @num_of_orders >= 5
	BEGIN
		UPDATE	@t
		SET		classification = 'C'
		WHERE	c_custkey = @c_custkey;

		RETURN;
	END

	UPDATE	@t
	SET		classification = 'D'
	WHERE	c_custkey = @c_custkey;

	RETURN;
END
GO

/* Test of user definied function with different customers */
SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_nationkey,
        c.c_name,
		ccc.num_of_orders,
		ccc.classification
FROM	dbo.customers AS c
		CROSS APPLY dbo.calculate_customer_category(c.c_custkey, 2019) AS ccc
WHERE	c.c_custkey = 1483396;	/* A-customer */
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_nationkey,
        c.c_name,
		ccc.num_of_orders,
		ccc.classification
FROM	dbo.customers AS c
		CROSS APPLY dbo.calculate_customer_category(c.c_custkey, 2019) AS ccc
WHERE	c.c_custkey = 746111;		/* B-customer */
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_nationkey,
        c.c_name,
		ccc.num_of_orders,
		ccc.classification
FROM	dbo.customers AS c
		CROSS APPLY dbo.calculate_customer_category(c.c_custkey, 2019) AS ccc
WHERE	c.c_custkey = 149134;		/* C-customer */
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_nationkey,
        c.c_name,
		ccc.num_of_orders,
		ccc.classification
FROM	dbo.customers AS c
		CROSS APPLY dbo.calculate_customer_category(c.c_custkey, 2019) AS ccc
WHERE	c.c_custkey = 696764;		/* D-customer */
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_nationkey,
        c.c_name,
		ccc.num_of_orders,
		ccc.classification
FROM	dbo.customers AS c
		CROSS APPLY dbo.calculate_customer_category(c.c_custkey, 2019) AS ccc
WHERE	c.c_custkey = 10;		/* Z-customer */
GO