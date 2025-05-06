@isTest
private class JobApplicationTriggerHandlerTest {
    
    @isTest
    static void testStatusChangeCreatesTask() {
        // Step 1: Create a Job Application with initial status
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Test Application',
            Status__c = 'Applied'
        );
        insert jobApp;

        // Step 2: Update the status to trigger Task creation
        jobApp.Status__c = 'Interview Scheduled';
        Test.startTest();
        update jobApp;
        Test.stopTest();

        // Step 3: Verify that a Task was created with the correct subject
        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :jobApp.Id];
        System.assertEquals(1, tasks.size(), 'One Task should be created');
        System.assertEquals('Prepare for Interview', tasks[0].Subject, 'Subject should match expected value');
    }

    @isTest
    static void testStatusChangeToOfferReceived() {
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Test Application 2',
            Status__c = 'Interview Scheduled'
        );
        insert jobApp;

        jobApp.Status__c = 'Offer Received';
        Test.startTest();
        update jobApp;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :jobApp.Id];
        System.assertEquals(1, tasks.size(), 'One Task should be created for Offer Received');
        System.assertEquals('Review Job Offer', tasks[0].Subject, 'Subject should match expected value');
    }

    @isTest
    static void testNoTaskWhenStatusUnchanged() {
        Job_Application__c jobApp = new Job_Application__c(
            Name = 'Test Application 3',
            Status__c = 'Applied'
        );
        insert jobApp;

        // Status does not change
        jobApp.Name = 'Test Application Updated';
        Test.startTest();
        update jobApp;
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :jobApp.Id];
        System.assertEquals(0, tasks.size(), 'No Task should be created when status does not change');
    }
}