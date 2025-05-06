@isTest
private class JobApplicationTriggerTest {

    @isTest
    static void testPositiveStatusChange() {
        // Create a new Job_Application__c record with initial status "Applied"
        Job_Application__c jobApp = new Job_Application__c(
            Status__c = 'Applied',
            Application_Date__c = Date.today()
        );
        insert jobApp;

        // Change the status to simulate a valid status change
        jobApp.Status__c = 'Interviewing';
        update jobApp;

        // Re-query the record to verify the status was updated
        Job_Application__c updatedJobApp = [
            SELECT Status__c FROM Job_Application__c WHERE Id = :jobApp.Id
        ];

        // Assert that the status was correctly changed
        System.assertEquals('Interviewing', updatedJobApp.Status__c, 'Status should be updated to Interviewing');

        // Optionally verify a related task was created (if your handler creates one)
        List<Task> tasks = [
            SELECT Subject, WhatId FROM Task WHERE WhatId = :jobApp.Id
        ];
        System.assert(tasks.size() > 0, 'A follow-up Task should be created');
    }

    @isTest
    static void testNegativeNoStatusChange() {
        // Create a new Job_Application__c record with status "Applied"
        Job_Application__c jobApp = new Job_Application__c(
            Status__c = 'Applied',
            Application_Date__c = Date.today()
        );
        insert jobApp;

        // Update a field other than the status
        jobApp.Notes__c = 'Backend Developer Role (Updated)';
        update jobApp;

        // Re-query the record to confirm the status is unchanged
        Job_Application__c unchangedJobApp = [
            SELECT Status__c FROM Job_Application__c WHERE Id = :jobApp.Id
        ];
        System.assertEquals('Applied', unchangedJobApp.Status__c, 'Status should not change');

        // Optionally check that no new task was created due to no status change
        List<Task> tasks = [
            SELECT Id FROM Task WHERE WhatId = :jobApp.Id
        ];
        System.assertEquals(0, tasks.size(), 'No task should be created when status does not change');
    }
}