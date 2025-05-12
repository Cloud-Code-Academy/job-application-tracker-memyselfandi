@isTest
public class USAJobsServiceTest {
    
    @isTest
    static void testGetJobs_Positive() {
        // Set the mock response to simulate a successful HTTP callout
        Test.setMock(HttpCalloutMock.class, new USAJobsMock());

        // Call the method that initiates the HTTP callout
        Test.startTest();
        USAJobsService.getJobs();
        Test.stopTest();

        // Assert that parsed jobs list is not empty
        System.assert(!USAJobsService.parsedJobs.isEmpty(), 'Parsed jobs list should not be empty');

        // Assert that we have the expected number of jobs
        System.assertEquals(1, USAJobsService.parsedJobs.size(), 'There should be 1 parsed job');

        // Validate the contents of the first job
        Map<String, String> firstJob = USAJobsService.parsedJobs[0];
        System.assertEquals('Salesforce Developer', firstJob.get('JobTitle'), 'Job title mismatch');
        System.assertEquals('Department of Tech', firstJob.get('OrganizationName'), 'Organization name mismatch');
        System.assertEquals('Washington, DC', firstJob.get('Location'), 'Location name mismatch');
        
    }
}