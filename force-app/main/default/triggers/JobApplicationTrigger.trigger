trigger JobApplicationTrigger on Job_Application__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            JobApplicationTriggerHandler.handleStatusChange(Trigger.new, Trigger.isUpdate ? Trigger.oldMap : null);
        }
    }
}