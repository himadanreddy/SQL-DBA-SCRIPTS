/**************************************************************************
** CREATED BY:   Bulent Gucuk
** CREATED DATE: 2019.02.26
** CREATED FOR:  Stopping the jobs before maintenance
** NOTES:	The script depends on the DBA database and table named dbo.JobsRunning
**			If you get an error make sure to alter the script to accomandate the
**			database and table name, when executed it will log all the jobs running at
**			step and will stop the job.  Run it only once, truncate command will truncate
**			the table and you will lose the list of jobs enabled before
***************************************************************************/
USE msdb;
GO
DECLARE @RowId SMALLINT = 1
	, @MaxRowId SMALLINT
	, @job_name SYSNAME

TRUNCATE TABLE DBA.dbo.JobsRunning
INSERT INTO DBA.dbo.JobsRunning
SELECT
	ROW_NUMBER () OVER(ORDER BY J.NAME) AS RowId,
    j.name AS job_name,
	j.job_id,
    ja.start_execution_date,      
    ISNULL(last_executed_step_id,0)+1 AS current_executed_step_id,
    Js.step_name
--INTO DBA.dbo.JobsRunning
FROM dbo.sysjobactivity AS ja
	LEFT OUTER JOIN dbo.sysjobhistory AS jh ON ja.job_history_id = jh.instance_id
	INNER JOIN dbo.sysjobs AS j ON ja.job_id = j.job_id
	INNER JOIN dbo.sysjobsteps AS js ON ja.job_id = js.job_id AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
AND ja.start_execution_date is not null
AND ja.stop_execution_date is null

SELECT @MaxRowId = @@ROWCOUNT

SELECT @MaxRowId, * from DBA.DBO.JobsRunning;

WHILE @RowId <= @MaxRowId
	BEGIN
		SELECT @job_name = job_name
		FROM	DBA.dbo.JobsRunning
		WHERE	RowId = @RowId;

		EXEC msdb.dbo.sp_stop_job @job_name = @job_name;

		SELECT @RowId = @RowId + 1;
	END
