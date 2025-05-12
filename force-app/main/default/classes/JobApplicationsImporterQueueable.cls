public with sharing class JobApplicationsImporterQueueable implements Queueable, Database.AllowsCallouts {
    
    // Entry point for queueable job
    public void execute(QueueableContext context) {
        try {
            USAJobsService.getJobs();  // Perform the API callout and job import
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in Queueable execution: ' + e.getMessage());
        }
    }
}
