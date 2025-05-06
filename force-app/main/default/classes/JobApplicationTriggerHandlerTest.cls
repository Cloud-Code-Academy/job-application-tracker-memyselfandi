@isTest
public class JobApplicationTriggerHandlerTest {

    // Utility method to create a Job_Application__c record with a valid status
    private static Job_Application__c createJobApplication(String status) {
        return new Job_Application__c(
            Status__c = status,
            Application_Date__c = Date.today()
        );
    }

    // Test for 'Interviewing' status - follow-up task should be created
    @isTest
    static void testStatusInterviewingCreatesFollowUpTask() {
        Job_Application__c job = createJobApplication('Applied');
        insert job;

        job.Status__c = 'Interviewing';
        update job;

        List<Task> tasks = [SELECT Subject FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(1, tasks.size());
        System.assertEquals('Prepare for interview', tasks[0].Subject);
    }

    // Test for 'Saved' status - no task should be created
    @isTest
    static void testStatusSaved() {
        Job_Application__c job = createJobApplication('Applying');
        insert job;

        job.Status__c = 'Saved';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(0, tasks.size());
    }

    // Test for 'Applying' status
    @isTest
    static void testStatusApplying() {
        Job_Application__c job = createJobApplication('Saved');
        insert job;

        job.Status__c = 'Applying';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(0, tasks.size());
    }

    // Test for 'Applied' status
    @isTest
    static void testStatusApplied() {
        Job_Application__c job = createJobApplication('Applying');
        insert job;

        job.Status__c = 'Applied';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(0, tasks.size());
    }

    // Test for 'Negotiating' status
    @isTest
    static void testStatusNegotiating() {
        Job_Application__c job = createJobApplication('Interviewing');
        insert job;

        job.Status__c = 'Negotiating';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(0, tasks.size());
    }

    // Test for 'Accepted' status
    @isTest
    static void testStatusAccepted() {
        Job_Application__c job = createJobApplication('Negotiating');
        insert job;

        job.Status__c = 'Accepted';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(0, tasks.size());
    }

    // Test for 'Closed' status
    @isTest
    static void testStatusClosed() {
        Job_Application__c job = createJobApplication('Accepted');
        insert job;

        job.Status__c = 'Closed';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assertEquals(0, tasks.size());
    }
}