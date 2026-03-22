trigger DocumentTrigger on Document__c (before insert) {
    
    if(Trigger.isInsert){
        for(Document__c dc : Trigger.new){
            
            if(dc.Valid_From_Date__c !=null && dc.Valid_To_Date__c !=null){
                dc.Valid_From_Date__c = Date.valueOf(dc.Valid_From_Date__c);
            	dc.Valid_To_Date__c = Date.valueOf(dc.Valid_To_Date__c);
                dc.ValidFromYear__c = String.valueOf(dc.Valid_From_Date__c.year());
                dc.ValidToYear__c = String.valueOf(dc.Valid_To_Date__c.year());
                if(dc.Valid_From_Date__c < System.today() && System.today() <  dc.Valid_To_Date__c){
                    dc.isActive__c = true;
                }
            }
            
        }
    }

}