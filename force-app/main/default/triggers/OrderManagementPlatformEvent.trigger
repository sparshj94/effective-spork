trigger OrderManagementPlatformEvent on Order__c (after insert, after update) {
    List<Order_Event__e> events = new List<Order_Event__e>();
    List<Order_Log__c> orderLogs = new List<Order_Log__c>();
    for (Order__c ord : Trigger.new) {
        Order_Event__e event = new Order_Event__e();
        event.Order_Name__c = ord.Name;
        TimeZone tz = UserInfo.getTimeZone();
        DateTime dt = Datetime.now();
        if(Trigger.isInsert){
            // event time 
            Order_Log__c ol = new Order_Log__c(
                Name = ord.Name, 
                Message__c = ord.Status__c, 
                Customer_Name__c  = ord.Customer_Name__c, 
                Amount__c = ord.Amount__c, 
                Event_Time__c = ord.LastModifiedDate
            );
            event.Order_Name__c = ord.Name;
            event.Message__c = ord.Status__c;
            event.Event_Time__c = dt.format();
            event.Customer_Name__c = ord.Customer_Name__c;
            event.Amount__c = ord.Amount__c;
            orderLogs.add(ol);
        	System.debug('Inside insert');
        }
        else if(Trigger.isUpdate){
            Order_Log__c ol = new Order_Log__c(
                Name = ord.Name, 
                Message__c = ord.Status__c, 
                Customer_Name__c  = ord.Customer_Name__c, 
                Amount__c = ord.Amount__c, 
                Event_Time__c = ord.LastModifiedDate
            );	
            event.Message__c = ord.Status__c;
            event.Order_Name__c = ord.Name;
            event.Event_Time__c = dt.format();
            event.Customer_Name__c = ord.Customer_Name__c;
            event.Amount__c = ord.Amount__c;
            orderLogs.add(ol);
        	System.debug('Inside insert');
        }
           
        events.add(event);
    }

    if (!events.isEmpty()) {
        System.debug('Inside ' + events);
        EventBus.publish(events);
        Database.insert(orderLogs, false);
        System.debug('Out');
    }
}