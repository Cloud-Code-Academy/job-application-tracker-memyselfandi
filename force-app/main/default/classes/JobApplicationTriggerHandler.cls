/**
 * @description
 *  Trigger handler for the Job Application object.
 *  Detects when the Status__c field changes on insert or update and
 *  calls specific methods based on the new Status__c value.
 *
 * @author Katende Kinene
 *
 * @date 04/28/2025
 */
public class JobApplicationTriggerHandler {

    // Main handler method that checks if Status__c field has changed
    public static void handleStatusChange(List<Job_Application__c> newList, Map<Id, Job_Application__c> oldMap) {
        for (Job_Application__c newJobApp : newList) {
            Job_Application__c oldJobApp = oldMap != null ? oldMap.get(newJobApp.Id) : null;

            Boolean isStatusChanged = false;

            // Handle insert (no old record exists)
            if (oldJobApp == null && newJobApp.Status__c != null) {
                isStatusChanged = true;
            }
            // Handle update (compare old vs new Status__c value)
            else if (oldJobApp != null && newJobApp.Status__c != oldJobApp.Status__c) {
                isStatusChanged = true;
            }

            if (isStatusChanged) {
                System.debug('Status changed for Job Application: ' + newJobApp.Id);
                System.debug('New Status: ' + newJobApp.Status__c);

                // Call method to perform action based on new Status__c
                handleStatusAction(newJobApp);
            }
        }
    }

    // Helper method to route to specific handler based on Status__c value
    private static void handleStatusAction(Job_Application__c jobApp) {
        switch on jobApp.Status__c {
            when 'Saved' {
                handleSaved(jobApp);
            }
            when 'Applying' {
                handleApplying(jobApp);
            }
            when 'Applied' {
                handleApplied(jobApp);
            }
            when 'Interviewing' {
                handleInterviewing(jobApp);
            }
            when 'Negotiating' {
                handleNegotiating(jobApp);
            }
            when 'Accepted' {
                handleAccepted(jobApp);
            }
            when 'Closed' {
                handleClosed(jobApp);
            }
            when else {
                System.debug('Unhandled Status value: ' + jobApp.Status__c);
            }
        }
    }

    // Specific handler for 'Saved' Status
    private static void handleSaved(Job_Application__c jobApp) {
        System.debug('Handling Saved status for Job Application: ' + jobApp.Id);

        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Check if the job description aligns with your interests and values
        Task task1 = new Task(
            WhatId = jobApp.Id,
            Subject = 'Review Job Description',
            Description = 'Check if the job description aligns with your interests and values',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        tasksToInsert.add(task1);

        // Task 2: Review the highlighted skills to see if the role is a good fit
        Task task2 = new Task(
            WhatId = jobApp.Id,
            Subject = 'Review Highlighted Skills',
            Description = 'Review the highlighted skills to see if the role is a good fit',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        tasksToInsert.add(task2);

        // Task 3: Research the company or role and mark your excitement level
        Task task3 = new Task(
            WhatId = jobApp.Id,
            Subject = 'Research Company and Role',
            Description = 'Research the company or role and mark your excitement level',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        tasksToInsert.add(task3);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }    }

    // Specific handler for 'Applying' Status
    private static void handleApplying(Job_Application__c jobApp) {
        System.debug('Handling Applying status for Job Application: ' + jobApp.Id);
        // Add specific logic for Applying status
    }

    // Specific handler for 'Applied' Status
    private static void handleApplied(Job_Application__c jobApp) {
        System.debug('Handling Applied status for Job Application: ' + jobApp.Id);
        // Add specific logic for Applied status
    }

    // Specific handler for 'Interviewing' Status
    private static void handleInterviewing(Job_Application__c jobApp) {
        System.debug('Handling Interviewing status for Job Application: ' + jobApp.Id);
        // Add specific logic for Interviewing status
    }

    // Specific handler for 'Negotiating' Status
    private static void handleNegotiating(Job_Application__c jobApp) {
        System.debug('Handling Negotiating status for Job Application: ' + jobApp.Id);
        // Add specific logic for Negotiating status
    }

    // Specific handler for 'Accepted' Status
    private static void handleAccepted(Job_Application__c jobApp) {
        System.debug('Handling Accepted status for Job Application: ' + jobApp.Id);
        // Add specific logic for Accepted status
    }

    // Specific handler for 'Closed' Status
    private static void handleClosed(Job_Application__c jobApp) {
        System.debug('Handling Closed status for Job Application: ' + jobApp.Id);
        // Add specific logic for Closed status
    }
}