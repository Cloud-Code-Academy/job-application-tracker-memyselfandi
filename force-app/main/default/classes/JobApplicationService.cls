public with sharing class JobApplicationService {

    // Exposing this method to the Aura framework, making it accessible in LWC or Flow
    @AuraEnabled(cacheable=true)
    public static List<Job_Application__c> fetchJobs() {
        // Calling the getJobs() method from JobApplicationTriggerHandler class
        // This fetches a list of Job_Application__c records
        return JobApplicationTriggerHandler.getJobs();  // Returns the results of getJobs()
    }
}