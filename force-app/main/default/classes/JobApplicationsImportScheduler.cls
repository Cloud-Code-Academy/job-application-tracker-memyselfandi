//getJobs() method performs an HTTP callout - so must use Queueable with Schedulable
public with sharing class JobApplicationsImportScheduler implements Schedulable {
    
    // This method is triggered by the Apex scheduler
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new JobApplicationsImporterQueueable());
    }
}

/*String cronExp = '0 0 2 1/3 * ?'; // At 2:00 AM every 3 days starting on the 1st of the month
String jobName = 'Job_Import_Every_3_Days';
JobImportScheduler job = new JobImportScheduler();
System.schedule(jobName, cronExp, job);*/
