trigger EmployeeTrigger on Employee__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isBefore) {
        // Calls your Gatekeeper logic
        DevBaHandler.validate(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    }
    
    if (Trigger.isAfter) {
        // Calls your routing and calculation logic
        DevBaHandler.handleAfter(Trigger.new, Trigger.oldMap, Trigger.isUpdate, Trigger.isInsert, Trigger.isDelete, Trigger.isUndelete);
    }
}