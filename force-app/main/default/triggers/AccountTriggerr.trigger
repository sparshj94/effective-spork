trigger AccountTriggerr on Account (after insert, after update){
    List<Account_Update__e> events = new List<Account_Update__e>();

    for (Account account : Trigger.new) {
        Account_Update__e event = new Account_Update__e();
        event.RecordId__c = account.Id;
        if(Trigger.isInsert){
            event.Change_Type__c = 'Insert';
        	System.debug('Inside insert');
        }
        else if(Trigger.isUpdate){	
            event.Change_Type__c = 'Update';
        	System.debug('Inside update');
        }
           
        events.add(event);
    }

    if (!events.isEmpty()) {
        System.debug('Inside ' + events);
        EventBus.publish(events);
        System.debug('Out');
    }
}