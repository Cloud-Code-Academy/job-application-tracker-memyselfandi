@isTest
private with sharing class JobApplicationsImportSchedulerTest {

    // Test scheduling the job to ensure it enqueues the queueable job properly
    @isTest
    static void testSchedulerEnqueuesQueueable() {
        Test.setMock(HttpCalloutMock.class, new USAJobsMock()); // Set mock for any future callouts

        // Define a cron expression for the test (runs Jan 1, 2050 at 2:00 AM)
        String cronExp = '0 0 2 1 1 ? 2050';
        JobApplicationsImportScheduler scheduler = new JobApplicationsImportScheduler();

        Test.startTest();
        String jobId = System.schedule('TestJobImport', cronExp, scheduler); // Schedule the job
        Test.stopTest();

        // Assert that the scheduled job was accepted and returned a job ID
        System.assertNotEquals(null, jobId);
    }
}
