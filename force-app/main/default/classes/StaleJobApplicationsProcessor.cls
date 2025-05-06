public class StaleJobApplicationsProcessor {

    // Public method to process stale job applications
    public static void processStaleApplications() {
        // Define the cutoff date as 30 days ago from today
        Date cutoffDate = Date.today().addDays(-30);

        // Query job applications that are not closed or accepted
        // and have a follow-up date older than the cutoff date
        List<Job_Application__c> staleApps = [
            SELECT Id, Status__c, Follow_Up_Date__c, Notes__c
            FROM Job_Application__c
            WHERE Status__c NOT IN ('Closed', 'Accepted')
            AND Follow_Up_Date__c <= :cutoffDate
        ];

        // Loop through each stale application
        for (Job_Application__c app : staleApps) {
            // Set the status to 'Closed'
            app.Status__c = 'Closed';

            // Append a note indicating it was closed automatically,
            // while preserving any existing notes
            app.Notes__c = (String.isBlank(app.Notes__c) ? '' : app.Notes__c + '\n') +
                           'Closed by automated process due to inactivity.';
        }

        // If there are any stale applications, update them in the database
        if (!staleApps.isEmpty()) {
            update staleApps;
        }
    }
}