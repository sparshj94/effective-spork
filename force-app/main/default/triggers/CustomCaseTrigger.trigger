trigger CustomCaseTrigger on Custom_Case__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            System.debug('after insert');
            CustomCaseTriggerHandler.updateAutomaticCaseStatus(Trigger.new, Trigger.oldMap);
            
        } else if(Trigger.isUpdate){
            System.debug('before up caal');
            CustomCaseTriggerHandler.preventStatusChange(Trigger.new, Trigger.oldMap);
            CustomCaseTriggerHandler.updateStatusToResolved(Trigger.new, Trigger.oldMap);
        }
    } else if(Trigger.isAfter){

        if(Trigger.isInsert){
            // CustomCaseTriggerHandler.calculateTotalCases(Trigger.new, Trigger.oldMap);
            CustomCaseTriggerHandler.onInsertAndUpdate(Trigger.old, Trigger.newMap);
        } else if(Trigger.isUpdate){
            System.debug('after call');
            // CustomCaseTriggerHandler.preventStatusChange(Trigger.new, Trigger.oldMap);
        }
    }
}