public with sharing class JobApplicationActionController {

    // Make method accessible to Lightning components (Aura and LWC)
    @AuraEnabled
    public static void runCustomLogic(Id recordId) {
        // Call existing business logic using the recordId
        JobApplicationTriggerHandler.runManualTaskLogic(recordId);
    }
}