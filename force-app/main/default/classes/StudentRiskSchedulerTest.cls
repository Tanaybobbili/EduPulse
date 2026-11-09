
@IsTest
private class StudentRiskSchedulerTest {

    @IsTest
    static void testSchedulerExecution() {

        // Generate a unique name for this test job.
        String jobName =
            'EduPulse Scheduler Test ' +
            String.valueOf(DateTime.now().getTime());

        Test.startTest();

        String jobId = System.schedule(
            jobName,
            '0 0 2 * * ?',
            new StudentRiskScheduler()
        );

        Test.stopTest();

        // Verify that Salesforce created the scheduled job.
        CronTrigger scheduledJob = [
            SELECT Id, CronExpression, State
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(
            '0 0 2 * * ?',
            scheduledJob.CronExpression,
            'The scheduler should use the configured CRON expression.'
        );

        System.assertNotEquals(
            null,
            scheduledJob.Id,
            'The scheduled job should exist.'
        );
    }
}
