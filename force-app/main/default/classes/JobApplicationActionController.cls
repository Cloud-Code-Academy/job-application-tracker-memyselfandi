public with sharing class JobApplicationActionController {

    // Make method accessible to Lightning components (Aura and LWC)
    @AuraEnabled
    public static void runCustomLogic() {
        // Call existing business logic using the recordId
        JobApplicationTriggerHandler.runManualTaskLogic();
    }
}