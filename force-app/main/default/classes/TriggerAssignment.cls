public class TriggerAssignment {
    // Trigger.new
    /* public static void checkForOpportunity(List<Opportunity> oppList){
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity op : oppList){
            accountIds.add(op.AccountId);
        }

        // List<Account> accList = [SELECT Id, Rating, CustomerPriority__c FROM Account WHERE ID IN :accountIds];
        Map<Id, Account> mpp = new Map<Id,Account>([SELECT Id, Rating, CustomerPriority__c FROM Account WHERE ID IN :accountIds]);
        List<Account> accToBeUpdated  = new List<Account>();
        for(Opportunity op : oppList){
            if(op.Amount >10000){
               Account ac =  mpp.get(op.AccountId);
               ac.Rating = 'Hot';
               ac.CustomerPriority__c = 'High';
               accToBeUpdated.add(ac);
            }
        }
        Database.update(accToBeUpdated,false);
    }
    
    */
    /*
    public static void checkOpportunityDuplicacy(List<Opportunity> oppList){
       // check for same name in existing opp for that account &&
       //stored id of account of trig. opp 
       Set<Id> accountIds = new Set<Id>();

       for(Opportunity op : oppList){
            accountIds.add(op.AccountId);
        }

       // find existing opp for trig accounts.
       List<Opportunity> existingOppForAccount = [SELECT ID, Name , AccountId  FROM Opportunity WHERE AccountId IN :accountIds WITH SECURITY_ENFORCED ];
       Map<Id, Set<String>> existingOppMap = new Map<Id, Set<String>>();

       for (Opportunity opp : existingOppForAccount) {
            if(!existingOppMap.containsKey(opp.AccountId)){
                existingOppMap.put(opp.AccountId, new Set<String>());
            }
            existingOppMap.get(opp.AccountId).add(opp.Name);
       }

       for(Opportunity newOpp : oppList){
            Set<String> oldNames = existingOppMap.get(newOpp.AccountId);
            if(oldNames!=null && oldNames.contains(newOpp.Name)){
                newOpp.Name = newOpp.Name + ' Duplicate Opportunity';
            }
        }
    }
	
*/
    public static void backupOpportunity(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        // on update 
        // after update
        List<Opportunity> oppToBeInserted = new List<Opportunity>();
        for (Opportunity op : newList) {
            Opportunity oldOpp = new Opportunity();
            oldOpp = oldMap.get(op.Id);

            if(op.Amount!=oldOpp.Amount || op.CloseDate!=oldOpp.CloseDate || op.StageName!=oldOpp.StageName){
                Opportunity newOp = new Opportunity();
                newOp.Name = oldOpp.Name + ' Backup';
                newOp.Amount = oldOpp.Amount;
                newOp.StageName = oldOpp.StageName;
                newOp.CloseDate = oldOpp.CloseDate;
                oppToBeInserted.add(newOp);
            }
        }
        if(!oppToBeInserted.isEmpty()){
            Database.insert(oppToBeInserted);
        }
    }
}