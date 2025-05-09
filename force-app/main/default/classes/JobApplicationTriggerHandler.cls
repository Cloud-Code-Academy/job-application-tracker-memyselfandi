/**
 * @description
 * Trigger handler for the Job Application object.
 * Detects when the Status__c field changes on insert or update and
 * calls specific methods based on the new Status__c value.
 *
 * @author Katende Kinene
 *
 * @date 04/28/2025
 */
public class JobApplicationTriggerHandler {

    public static Boolean wasCalled = false; // Static flag at the top level

    // Main handler method that checks if Status__c field has changed.
    public static void handleStatusChange(List<Job_Application__c> newList, Map<Id, Job_Application__c> oldMap) {
        wasCalled = true;
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
    private static void handleSaved(List<Job_Application__c> jobApps) {
        System.debug('Handling Saved status for Job Applications: ' + jobApps.size());

        // Collect all related Account IDs from the Job Applications
        Set<Id> accountIds = new Set<Id>();
        for (Job_Application__c jobApp : jobApps) {
            if (String.isNotBlank(jobApp.Company_Name__c)) {
                accountIds.add(jobApp.Company_Name__c);
            }
        }

        // Prefetch all related Contacts grouped by AccountId
        Map<Id, List<Contact>> accountIdToContacts = new Map<Id, List<Contact>>();
        if (!accountIds.isEmpty()) {
            for (Contact con : [
                SELECT Id, Name, AccountId, Contact_Type__c, CreatedDate
                FROM Contact
                WHERE AccountId IN :accountIds
                ORDER BY CreatedDate DESC // Newest first for general contact
            ]) {
                if (!accountIdToContacts.containsKey(con.AccountId)) {
                    accountIdToContacts.put(con.AccountId, new List<Contact>());
                }
                accountIdToContacts.get(con.AccountId).add(con);
            }
        }

        // List to hold updated Job Application records
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();

        for (Job_Application__c jobApp : jobApps) {
            System.debug('Handling Saved status for Job Application: ' + jobApp.Id);

            // Primary Contact Check Section
            if (jobApp.Primary_Contact__c == null && String.isNotBlank(jobApp.Company_Name__c)) {
                List<Contact> relatedContacts = accountIdToContacts.get(jobApp.Company_Name__c);

                if (relatedContacts != null && !relatedContacts.isEmpty()) {
                    Contact primaryContact = null;
                    Contact generalContact = null;

                    // Find the most recent 'Primary Contact'
                    for (Contact con : relatedContacts) {
                        if (con.Contact_Type__c == 'Primary Contact') {
                            primaryContact = con;
                            break; // Found the primary, no need to continue searching for primary
                        }
                        if (generalContact == null) {
                            generalContact = con; // Keep track of the newest general contact
                        }
                    }

                    if (primaryContact != null) {
                        jobApp.Primary_Contact__c = primaryContact.Id;
                        System.debug('Auto-assigned Primary Contact: ' + primaryContact.Id);
                        appsToUpdate.add(new Job_Application__c(Id = jobApp.Id, Primary_Contact__c = primaryContact.Id));
                    } else if (generalContact != null) {
                        jobApp.Primary_Contact__c = generalContact.Id;
                        System.debug('Auto-assigned Primary Contact (any Contact): ' + generalContact.Id);
                        appsToUpdate.add(new Job_Application__c(Id = jobApp.Id, Primary_Contact__c = generalContact.Id));
                    } else {
                        System.debug('No Contacts found on Company (Account): ' + jobApp.Company_Name__c);
                    }
                } else {
                    System.debug('No Contacts found for Account ID: ' + jobApp.Company_Name__c);
                }
            } else if (jobApp.Primary_Contact__c != null) {
                System.debug('Primary Contact is already set: ' + jobApp.Primary_Contact__c);
            } else if (String.isBlank(jobApp.Company_Name__c)) {
                System.debug('Job Application has no related Account.');
            }

            /*Task Creation Section */
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
            }
        }

        // Perform a single update for all modified Job Application records
        if (!appsToUpdate.isEmpty()) {
            try {
                update appsToUpdate;
                System.debug('Updated Primary Contact for ' + appsToUpdate.size() + ' Job Applications.');
            } catch (DmlException e) {
                System.debug('Error updating Job Applications: ' + e.getMessage());
            }
        }
    }

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
        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Reach out to the hiring manager or recruiter
        Task task1 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Reach Out to Hiring Manager or Recruiter',
            Description = 'Reach out to the hiring manager or recruiter regarding your application.',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(2) // Due date = today + 2 days
        );
        tasksToInsert.add(task1);

        // Task 2: Follow up on your application via email weekly
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Weekly Follow-Up on Application',
            Description = 'Send a follow-up email weekly regarding the status of your application.',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(2) // Due date = today + 2 days
        );
        tasksToInsert.add(task2);

        // Task 3: Continue identifying and saving similar job opportunities
        Task task3 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Identify Similar Job Opportunities',
            Description = 'Continue identifying and saving similar job opportunities.',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(2) // Due date = today + 2 days
        );
        tasksToInsert.add(task3);

        // Task 4: Set up weekly networking calls to explore similar companies/roles
        Task task4 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Set Up Weekly Networking Calls',
            Description = 'Set up weekly networking calls to explore similar companies and roles.',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(2) // Due date = today + 2 days
        );
        tasksToInsert.add(task4);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

        // Prepare a list to hold the Job Application records to update
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();

        // Create a new instance to update, setting the ID to the current jobApp's ID
        Job_Application__c updatedApp = new Job_Application__c(Id = jobApp.Id);

        // Update the Application_Date__c field (if it's not already set or needs updating)
        if (updatedApp.Application_Date__c == null) {
            updatedApp.Application_Date__c = Date.today();
        }

        // Set the Follow_Up_Date__c field (you might want to set this to a future date)
        updatedApp.Follow_Up_Date__c = Date.today().addDays(3); // Example: Follow up in 7 days

        // Add the updated record to the list
        appsToUpdate.add(updatedApp);

        // Perform the update ONLY if there are records to update
        if (!appsToUpdate.isEmpty()) {
            try {
                update appsToUpdate;
                System.debug('Updated Application_Date__c and Follow_Up_Date__c for Job Application: ' + jobApp.Id);
            } catch (DmlException e) {
                // It's crucial to handle DML exceptions properly
                System.debug('Error updating Job Application: ' + e.getMessage());
            }
        }
    }
    }

    // Specific handler for 'Interviewing' Status
    private static void handleInterviewing(Job_Application__c jobApp) {
        System.debug('Handling Interviewing status for Job Application: ' + jobApp.Id);

        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Prepare your blurb or “tell me about yourself” response
        Task task1 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Prepare Blurb - Tell Me About Yourself',
            Description = 'Prepare your blurb or “tell me about yourself” response',
            Status = 'Not Started',
            Priority = 'High',
            ActivityDate = Date.today().addDays(3) // Set Due Date to 3 days from today
        );
        tasksToInsert.add(task1);

        // Task 2: Practice answering behavioral interview questions
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Practice Behavioral Interview Questions',
            Description = 'Practice answering behavioral interview questions',
            Status = 'Not Started',
            Priority = 'High',
            ActivityDate = Date.today().addDays(3) // Set Due Date to 3 days from today
        );
        tasksToInsert.add(task2);

        // Task 3: Research the company and your interviewers
        Task task3 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Research Company and Interviewers',
            Description = 'Research the company and your interviewers',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(3) // Set Due Date to 3 days from today
        );
        tasksToInsert.add(task3);

        // Task 4: Set up your virtual interview space and test your tech
        Task task4 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Setup Virtual Interview Space',
            Description = 'Set up your virtual interview space and test your tech',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(3) // Set Due Date to 3 days from today
        );
        tasksToInsert.add(task4);

        // Task 5: Send thank you emails within 24 hours
        Task task5 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Send Thank You Emails',
            Description = 'Send thank you emails within 24 hours after your interview',
            Status = 'Not Started',
            Priority = 'High',
            ActivityDate = Date.today().addDays(3) // Set Due Date to 3 days from today
        );
        tasksToInsert.add(task5);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

    }

    // Specific handler for 'Negotiating' Status
    private static void handleNegotiating(Job_Application__c jobApp) {
        System.debug('Handling Negotiating status for Job Application: ' + jobApp.Id);
        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Research your market value and know your numbers
        Task task1 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Research Market Value',
            Description = 'Research your market value and know your numbers',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(4) // Set Due Date to 4 days from today
        );
        tasksToInsert.add(task1);

        // Task 2: Prepare your negotiation scripts
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Prepare Negotiation Scripts',
            Description = 'Prepare your negotiation scripts',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(4) // Set Due Date to 4 days from today
        );
        tasksToInsert.add(task2);

        // Task 3: Evaluate your offer and decline or accept
        Task task3 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Evaluate Offer - Decline or Accept',
            Description = 'Evaluate your offer carefully and decide whether to decline or accept.',
            Status = 'Not Started',
            Priority = 'High',
            ActivityDate = Date.today().addDays(5) // Set Due Date to 5 days from today
        );
        tasksToInsert.add(task3);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    // Specific handler for 'Accepted' Status
    private static void handleAccepted(Job_Application__c jobApp) {
        System.debug('Handling Accepted status for Job Application: ' + jobApp.Id);
        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Send a thank you email accepting the offer
        Task task1 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Send Offer Acceptance Email',
            Description = 'Send a thank you email formally accepting the job offer.',
            Status = 'Not Started',
            Priority = 'High',
            ActivityDate = Date.today().addDays(1) // Due in 1 day
        );
        tasksToInsert.add(task1);

        // Task 2: Complete any necessary onboarding paperwork
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Complete Onboarding Paperwork',
            Description = 'Complete all necessary onboarding paperwork provided by the company.',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(7) // Due in 7 days
        );
        tasksToInsert.add(task2);

        // Task 3: Notify other companies about your decision (if applicable)
        Task task3 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Notify Other Companies',
            Description = 'Notify other companies where you have ongoing applications about your decision.',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(2) // Due in 2 days
        );
        tasksToInsert.add(task3);

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }

    // Specific handler for 'Closed' Status
    private static void handleClosed(Job_Application__c jobApp) {
        System.debug('Handling Closed status for Job Application: ' + jobApp.Id);
        List<Task> tasksToInsert = new List<Task>();

        // Task 1: Research your market value and know your numbers
        Task task1 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Send a follow-up email',
            Description = 'Send a follow-up email thanking the interviewer and asking for feedback',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Set Due Date to 4 days from today
        );
        tasksToInsert.add(task1);

        // Task 2: Prepare your negotiation scripts
        Task task2 = new Task(
            WhatId = jobApp.Id,
            OwnerId = jobApp.OwnerId,
            Subject = 'Review your notes',
            Description = 'Review your notes and reflect on areas of improvement',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(1) // Set Due Date to 4 days from today
        );
        tasksToInsert.add(task2);

        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}