@isTest
private class USAJobsServiceTest {
    @isTest
    static void testGetJobs() {
        // Set the mock callout
        Test.setMock(HttpCalloutMock.class, new USAJobsMock());

        // Call the method inside a test context
        Test.startTest();
        USAJobsService.getJobs();
        Test.stopTest();

        // Assert we parsed two jobs
        System.assertEquals(2, USAJobsService.parsedJobs.size(), 'Should parse 2 jobs');

        // Assert first job details
        Map<String, String> job1 = USAJobsService.parsedJobs[0];
        System.assertEquals('Salesforce Developer', job1.get('JobTitle'), 'Job title mismatch');
        System.assertEquals('Department of Tech', job1.get('OrganizationName'), 'Org name mismatch');
        System.assertEquals('Washington, DC', job1.get('LocationName'), 'Location mismatch');

        // Assert second job details
        Map<String, String> job2 = USAJobsService.parsedJobs[1];
        System.assertEquals('Apex Engineer', job2.get('JobTitle'), 'Job title mismatch');
        System.assertEquals('Federal IT', job2.get('OrganizationName'), 'Org name mismatch');
        System.assertEquals('Washington, DC', job2.get('LocationName'), 'Location mismatch');
    }
}