trigger OppTrigger on Opportunity (before insert, after insert, after update) {
	if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                // TriggerAssignment.checkOpportunityDuplicacy(Trigger.new);
            } else if(Trigger.isUpdate){
                //TriggerAssignment.backupOpportunity(Trigger.oldMap, Trigger.new);
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert ) {
                // TriggerAssignment.checkForOpportunity(Trigger.new);
            } else if (Trigger.isUpdate){
                // TriggerAssignment.checkForOpportunity(Trigger.new);
                
            }else if (Trigger.isDelete) {
                
            }
        }

}