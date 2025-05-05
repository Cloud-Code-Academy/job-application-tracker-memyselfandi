global with sharing class StaleJobApplicationsScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        StaleJobApplicationsProcessor.processStaleApplications();
    }

    /*// Runs every day at 12:00 PM (noon)
    String cronExpr = '0 0 12 * * ?'; // Seconds Minutes Hours Day_of_month Month Day_of_week
    System.schedule('Daily Stale Job Application Cleanup', cronExpr, new StaleJobApplicationsScheduler());
 */
}
