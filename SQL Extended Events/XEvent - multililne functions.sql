USE ERP_Demo;
GO

IF EXISTS (SELECT * FROM sys.dm_xe_sessions WHERE name = N'Track Scalar Functions')
BEGIN
	RAISERROR (N'Dropping XEvent-Session: [Track Scalar Functions]', 0, 1) WITH NOWAIT;
	DROP EVENT SESSION [Track Scalar Functions] ON SERVER;
END

	RAISERROR (N'Createing XEvent-Session: [Track Scalar Functions]', 0, 1) WITH NOWAIT;
	CREATE EVENT SESSION [Track Scalar Functions]
	ON SERVER
	ADD EVENT sqlserver.sp_statement_completed
	(
		ACTION (package0.event_sequence)
		WHERE
		(
			sqlserver.database_name =  N'ERP_Demo'
			AND statement LIKE N'%Customer%'
		)
	),
	ADD EVENT sqlserver.sql_statement_completed
	(
		ACTION (package0.event_sequence)
		WHERE
		(
			sqlserver.database_name =  N'ERP_Demo'
			AND statement LIKE N'%Customer%'

		)
	)
	WITH
	(
		MAX_MEMORY = 4096KB,
		EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
		MAX_DISPATCH_LATENCY = 5 SECONDS,
		MAX_EVENT_SIZE = 0KB,
		MEMORY_PARTITION_MODE = NONE,
		TRACK_CAUSALITY = OFF,
		STARTUP_STATE = OFF
	);

	IF @show_execution_plans = 1
	BEGIN
		RAISERROR (N'adding events for execution plans: [Track Scalar Functions]', 0, 1) WITH NOWAIT;

		ALTER EVENT SESSION [Track Scalar Functions] ON SERVER
		ADD EVENT sqlserver.query_post_compilation_showplan
		(ACTION (package0.event_sequence)),
		ADD EVENT sqlserver.query_post_execution_showplan
		(ACTION (package0.event_sequence));
	END

	IF @show_start_statements = 1
	BEGIN
		RAISERROR (N'adding events for starting statements: [Track Scalar Functions]', 0, 1) WITH NOWAIT;

		ALTER EVENT SESSION [Track Scalar Functions] ON SERVER
		ADD EVENT sqlserver.sp_statement_starting
		(
			ACTION (package0.event_sequence)
			WHERE
			(
				sqlserver.database_name =  N'demo_db'
				AND statement LIKE N'%Customer%'
			)
		),
		ADD EVENT sqlserver.sql_statement_starting
		(
			ACTION (package0.event_sequence)
			WHERE
			(
				sqlserver.database_name =  N'demo_db'
				AND statement LIKE N'%Customer%'
			)
		)
	END

	RAISERROR (N'Starting XEvent-Session: [Track Scalar Functions]', 0, 1) WITH NOWAIT;
	ALTER EVENT SESSION [Track Scalar Functions] ON SERVER STATE = START;
END
GO