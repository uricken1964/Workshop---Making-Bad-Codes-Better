/*
	============================================================================
	File:		01 - scenario 02 - maintenance procedure.sql

	Summary:	This procedure creates the maintenance stored procedure
				dbo.jobqueue_delete.
				The code is - nearby - exactly the same as the vendor code
				and only modifified for better reading / understanding.
					
				The stored procedure uses two variables which control the behavior
				@rowlimit	=>	batch size of rows to be deleted
				@maxlimit	=>	number of rows to delete from dbo.jobqueue

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

CREATE OR ALTER PROCEDURE dbo.jobqueue_delete
	@rowlimit	INT	=	1000,
	@maxlimit	INT =	50000
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	SET	LOCK_TIMEOUT 50;

	/* Declaration of variables for the execution */
	DECLARE	@items			AS	dbo.helpertable;
	DECLARE	@itemportion	AS	dbo.helpertable;

	DECLARE @rows_per_batch		INT;
	DECLARE @LaufDelete			INT = 0;
	DECLARE @AnzahlLoesch		INT;
	DECLARE @AnzahlLoeschGesamt	INT = 0;
	DECLARE @Start				DATETIME;
	DECLARE @ende				DATETIME;
	DECLARE @diff				INT;
	DECLARE @ExpectedRuntime	FLOAT = 1000.0;
	DECLARE @rows_total			INT;

	DECLARE	@error_message		NVARCHAR(2024);
	DECLARE	@error_number		INT;
	DECLARE	@error_line			INT;

BEGIN TRY
	SELECT	@rows_total = COUNT(*) FROM	dbo.jobqueue;

	IF @rows_total > 0
		GOTO normal

	IF @rows_total = 0	AND @@TRANCOUNT = 0
	BEGIN
		BEGIN TRANSACTION;
		BEGIN TRY
			UPDATE	dbo.jobqueue
			SET		Generation = q.Generation
			FROM	dbo.jobqueue AS q WITH (TABLOCKX);
		END TRY
		BEGIN CATCH
			SET	@rows_total = 1;
		END CATCH

		/* Step 1: We replace the second count by the previous value */
		IF (SELECT COUNT(*) FROM dbo.jobqueue) = 0 AND @rows_total = 0
		BEGIN
			BEGIN TRY
				TRUNCATE TABLE dbo.jobqueue;
				COMMIT;
				
				SET	@LaufDelete = 1;
			END TRY
			BEGIN CATCH
				ROLLBACK;
			END CATCH
		END
		ELSE
		BEGIN
			ROLLBACK;
		END
	END

	IF @LaufDelete = 1
	BEGIN
		GOTO endLabel;
	END

normal:
	INSERT INTO @Items (singleguid)
	SELECT	TOP (@maxlimit)
			qt.uid_jobqueue
	FROM	dbo.jobqueue AS qt WITH (READPAST)
	WHERE	Generation = -1;

	SET	@LaufDelete = 1;
	SET	@rows_per_batch = @RowLimit;

	WHILE @LaufDelete > 0
	BEGIN
		SET		@Start = GETUTCDATE()

		DELETE	@ItemPortion;

		INSERT INTO @ItemPortion (singleguid)
		SELECT TOP (@rows_per_batch)
				t.singleguid
		FROM	@Items t
		WHERE	t.BitProperty = 0;

		SET		@LaufDelete = @@ROWCOUNT;

		IF @LaufDelete = 0
			CONTINUE;

		UPDATE	@Items
		SET		BitProperty = 1
		FROM	@Items AS t
				INNER JOIN @ItemPortion AS p
				ON (t.singleguid = p.singleguid)

		BEGIN TRY
			DELETE	dbo.jobqueue
			WHERE	uid_jobqueue IN
					(
						SELECT t.singleguid
						FROM @ItemPortion t
					);

			SET		@AnzahlLoesch = @@ROWCOUNT;
		END TRY
		BEGIN CATCH
			SELECT	@AnzahlLoesch = 0;
			WAITFOR DELAY '00:00:05';
		END CATCH

		SET @AnzahlLoeschGesamt += @AnzahlLoesch;
		SET	@ende = GETUTCDATE();
		SET	@diff = DATEDIFF(ms, @start, @ende)

		SELECT @rows_per_batch =
			CASE
				WHEN @diff = 0 THEN @RowLimit
				WHEN @AnzahlLoesch = 0 THEN @RowLimit
				WHEN @diff > @ExpectedRuntime THEN @RowLimit
				ELSE CONVERT(INT, @ExpectedRuntime * CONVERT(float, @rows_per_batch) / CONVERT(float, @diff))
			END
	END
END TRY
BEGIN CATCH
	SET	@error_message = ERROR_MESSAGE();
	SET	@error_number = ERROR_NUMBER();
	SET	@error_line = ERROR_LINE();
	SELECT	@error_message	AS	error_message,
			@error_number	AS error_number,
			@error_line		AS	error_ine;
END CATCH

endLabel:
	RETURN (@AnzahlLoeschGesamt);
END
GO