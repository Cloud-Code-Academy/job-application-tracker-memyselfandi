@isTest
private class JobApplicationTriggerTest {

    @isTest
    static void testPositiveStatusChange() {
        // Create Account for Testing
        Account company = new Account(Name = 'OpenAI');
        insert company;

        // Create a new Job_Application__c record with initial status "Applied"
        Job_Application__c jobApp = new Job_Application__c(
            Status__c = 'Applied',
            Application_Date__c = Date.today(),
            Company_Name__c = company.Id,
            Position_Title__c = 'Salesforce Developer'
        );
        insert jobApp;

        // Change the status to simulate a valid status change
        jobApp.Status__c = 'Interviewing';
        update jobApp;

        // Re-query the record to verify the status was updated
        Job_Application__c updatedJobApp = [
            SELECT Status__c FROM Job_Application__c WHERE Id = :jobApp.Id
        ];
        System.debug('Updated Status: ' + updatedJobApp.Status__c);
        System.assertEquals('Interviewing', updatedJobApp.Status__c, 'Status should be updated to Interviewing');

        // Optionally verify a related task was created
        List<Task> tasks = [
            SELECT Subject, WhatId FROM Task WHERE WhatId = :jobApp.Id
        ];
        System.debug('Number of tasks created: ' + tasks.size());
        for (Task t : tasks) {
            System.debug('Task Subject: ' + t.Subject);
        }
        System.assert(tasks.size() > 0, 'A follow-up Task should be created');
    }

    @isTest
    static void testNegativeNoStatusChange() {
        // Create Account for Testing
        Account company = new Account(Name = 'OpenAI');
        insert company;

        // Create a new Job_Application__c record with status "Applied"
        Job_Application__c jobApp = new Job_Application__c(
            Status__c = 'Applied',
            Application_Date__c = Date.today(),
            Company_Name__c = company.Id,
            Position_Title__c = 'Salesforce Developer'
        );
        insert jobApp;

        // Update a field other than the status
        jobApp.Notes__c = 'Backend Developer Role (Updated)';
        update jobApp;

        // Re-query the record to confirm the status is unchanged
        Job_Application__c unchangedJobApp = [
            SELECT Status__c FROM Job_Application__c WHERE Id = :jobApp.Id
        ];
        System.debug('Unchanged Status: ' + unchangedJobApp.Status__c);
        System.assertEquals('Applied', unchangedJobApp.Status__c, 'Status should not change');

        // Optionally check that no new task was created due to no status change
        List<Task> tasks = [
            SELECT Id, Subject FROM Task WHERE WhatId = :jobApp.Id
        ];
        System.debug('Number of tasks found: ' + tasks.size());
        for (Task t : tasks) {
            System.debug('Task Subject: ' + t.Subject);
        }

        System.assert(tasks.size() == 0, 'No additional tasks should be created when status does not change');
    }
}