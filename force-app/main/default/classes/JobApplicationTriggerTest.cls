@isTest
private class JobApplicationTriggerTest {

    // Simulated handler class flag (if applicable in your design)
    public class TestHandler extends JobApplicationTriggerHandler {
        public static Boolean wasCalled = false;

        // This override would be used if your actual handler supports overriding for tests
        public static override void handleStatusChange(List<Job_Application__c> newList, Map<Id, Job_Application__c> oldMap) {
            wasCalled = true;
        }
    }

    @isTest
    static void testPositiveStatusChange() {
        // Create a new Job_Application__c record with initial status "Applied"
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Software Engineer Role',
            Status__c = 'Applied'
        );
        insert jobApp; // Insert the record to trigger the BEFORE INSERT logic

        // Change the status to simulate a valid status change
        jobApp.Status__c = 'Interview';
        update jobApp; // Update the record to trigger the BEFORE UPDATE logic

        // Re-query the record to verify the status was updated
        Job_Application__c updatedJobApp = [SELECT Status__c FROM Job_Application__c WHERE Id = :jobApp.Id];

        // Assert that the status was correctly changed to "Interview"
        System.assertEquals('Interview', updatedJobApp.Status__c, 'Status should be updated to Interview');
    }

    @isTest
    static void testNegativeNoStatusChange() {
        // Create a new Job_Application__c record with status "Applied"
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Backend Developer Role',
            Status__c = 'Applied'
        );
        insert jobApp; // Insert to trigger BEFORE INSERT

        // Update a field other than the status (here we update Name only)
        jobApp.Name = 'Backend Developer Role (Updated)';
        update jobApp; // Triggers BEFORE UPDATE, but status has not changed

        // Re-query the record to confirm the status is still "Applied"
        Job_Application__c unchangedStatusApp = [SELECT Status__c FROM Job_Application__c WHERE Id = :jobApp.Id];

        // Assert that the status did not change
        System.assertEquals('Applied', unchangedStatusApp.Status__c, 'Status should not change');
    }
}