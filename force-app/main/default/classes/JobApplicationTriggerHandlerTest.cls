@isTest
public class JobApplicationTriggerHandlerTest {

    // Utility method to create a Job_Application__c record with a valid status
    private static Job_Application__c createJobApplication(String status) {
        Account company = new Account(Name = 'OpenAI');
        insert company;

        return new Job_Application__c(
            Status__c = status,
            Application_Date__c = Date.today(),
            Company_Name__c = company.Id,
            Position_Title__c = 'Salesforce Developer'
        );
    }

    // Test for 'Interviewing' status - follow-up task should be created
    @isTest
    static void testStatusInterviewingCreatesFollowUpTask() {
        Job_Application__c job = createJobApplication('');
        insert job;

        job.Status__c = 'Interviewing';
        update job;

        List<Task> tasks = [SELECT Subject FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 5, 'Expected 5 follow-up task for Interviewing status');
        System.assert(tasks[0].Subject == 'Prepare Blurb - Tell Me About Yourself', 'Expected task subject to be "Prepare Blurb - Tell Me About Yourself"');
    }

    // Test for 'Saved' status - 3 tasks should be created
    @isTest
    static void testStatusSaved() {
        Job_Application__c job = createJobApplication('Applying');
        insert job;

        job.Status__c = 'Saved';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 3, 'Expected 3 tasks to be created for Saved status');
    }

    // Test for 'Applying' status
    @isTest
    static void testStatusApplying() {
        Job_Application__c job = createJobApplication('');
        insert job;

        job.Status__c = 'Applying';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 5, 'Expected 5 tasks for Applying status');
    }

    // Test for 'Applied' status
    @isTest
    static void testStatusApplied() {
        Job_Application__c job = createJobApplication('');
        insert job;

        job.Status__c = 'Applied';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 4, 'Expected 4 tasks for Applied status');
    }

    // Test for 'Negotiating' status
    @isTest
    static void testStatusNegotiating() {
        Job_Application__c job = createJobApplication('');
        insert job;

        job.Status__c = 'Negotiating';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 3, 'Expected 3 tasks for Negotiating status');
    }

    // Test for 'Accepted' status
    @isTest
    static void testStatusAccepted() {
        Job_Application__c job = createJobApplication('');
        insert job;

        job.Status__c = 'Accepted';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 3, 'Expected 3 taskd for Accepted status');
    }

    // Test for 'Closed' status
    @isTest
    static void testStatusClosed() {
        Job_Application__c job = createJobApplication('');
        insert job;

        job.Status__c = 'Closed';
        update job;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :job.Id];
        System.assert(tasks.size() == 2, 'Expected 2 tasks for Closed status');
    }
}