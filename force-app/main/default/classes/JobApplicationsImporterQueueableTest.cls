@isTest
private with sharing class JobApplicationsImporterQueueableTest {

    // Test that the queueable job runs and processes data using the mock callout
    @isTest
    static void testQueueableExecution() {
        Test.setMock(HttpCalloutMock.class, new USAJobsMock()); // Set mock callout

        Test.startTest();
        System.enqueueJob(new JobApplicationsImporterQueueable()); // Enqueue queueable class
        Test.stopTest();

        // Check that job data was parsed and stored
        System.assertEquals(1, USAJobsService.parsedJobs.size());
    }
}
