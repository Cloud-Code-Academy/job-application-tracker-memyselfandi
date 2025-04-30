@isTest
public class USAJobsServiceTest {
    @isTest
    static void testGetJobs_Success_WithInterfaceMock() {
        // 1. Set up the mock callout response using the new mock class
        Test.setMock(HttpCalloutMock.class, new MockUSAJobsServiceWithInterface());

        // 2. Call the method that makes the callout
        Test.startTest();
        USAJobsService service = new USAJobsService(); // Instantiate the service class
        service.getJobs(); // Call the getJobs method
        Test.stopTest();

        // 3. Assertions to verify the behavior based on the mock response
        // (Same as before - check debug logs or a testable variable)
        System.debug('Test with interface mock completed. Check debug logs.');
    }

    // You can keep or modify your other test methods as needed.
}