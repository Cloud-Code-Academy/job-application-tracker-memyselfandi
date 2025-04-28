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
            OwnerId = jobApp.OwnerId,
            Subject = 'Review Job Description',
            Description = 'Check if the job description aligns with your interests and values',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today() // Set Due Date to today's date
        );
        tasksToInsert.add(task1);

        // Task 2: Review the highlighted skills to see if the role is a good fit
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Review Highlighted Skills',
            Description = 'Review the highlighted skills to see if the role is a good fit',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today() // Set Due Date to today's date
        );
        tasksToInsert.add(task2);

        // Task 3: Research the company or role and mark your excitement level
        Task task3 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Research Company and Role',
            Description = 'Research the company or role and mark your excitement level',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today() // Set Due Date to today's date
        );
        tasksToInsert.add(task3);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }    }

    // Specific handler for 'Applying' Status
    private static void handleApplying(Job_Application__c jobApp) {
        System.debug('Handling Applying status for Job Application: ' + jobApp.Id);
        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Find and research someone who works at the company and add them as a contact
        Task task1 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Research Company Contacts',
            Description = 'Find and research someone who works at the company and add them as a contact',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Due tomorrow
        );
        tasksToInsert.add(task1);

        // Task 2: Set up an informational interview to learn more about the role/company
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Set Up Informational Interview',
            Description = 'Set up an informational interview to learn more about the role/company',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Due tomorrow
        );
        tasksToInsert.add(task2);

        // Task 3: Identify potential referrals to help get your application on the top of the pile
        Task task3 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Identify Potential Referrals',
            Description = 'Identify potential referrals to help get your application on the top of the pile',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Due tomorrow
        );
        tasksToInsert.add(task3);

        // Task 4: Customize your work achievements using the job description keywords
        Task task4 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Customize Resume with Job Keywords',
            Description = 'Customize your work achievements using the job description keywords',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Due tomorrow
        );
        tasksToInsert.add(task4);

        // Task 5: Submit your application on the company website if possible
        Task task5 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Submit Application on Company Website',
            Description = 'Submit your application on the company website if possible',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Due tomorrow
        );
        tasksToInsert.add(task5);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
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