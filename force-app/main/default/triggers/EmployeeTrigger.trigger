
trigger EmployeeTrigger on Employee__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isBefore) {
        DevBaHandler.validate(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    }
    
    if (Trigger.isAfter) {
        DevBaHandler.handleAfter(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete);
    }
}