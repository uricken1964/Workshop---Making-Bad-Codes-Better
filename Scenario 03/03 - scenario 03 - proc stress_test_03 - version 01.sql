/*
	============================================================================
	File:		03 - scenario 03 - proc stress_test_03 - version 01.sql

	Summary:	This script creates the original query which should be fired
				10.000 times in a minute!
				
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
/* This setting is for statisticsparser only! */
SET LANGUAGE us_english;
GO

USE ERP_Demo;
GO

CREATE OR ALTER PROCEDURE dbo.stress_test_03
	@uid_sapuser	VARCHAR(38)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	internalname,
			uid_person,
			centralaccount,
			xmarkedfordeletion
	FROM	dbo.persons
	WHERE	(
				uid_person IN
				(
					SELECT	p.uid_person
					FROM	dbo.persons AS p
							INNER JOIN dbo.sapusers AS a
							ON
							(
								p.CentralSAPAccount = a.accnt
								OR p.CCC_AliasName = a.accnt
							)
					WHERE	a.uid_sapuser = @uid_sapuser
				)
			)
	ORDER BY
		   internalname,
		   centralaccount;
END
GO
