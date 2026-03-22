public class PracticePaper2Account {
	public static void mm(Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
      
        Set<Id> accId = new Set<Id>();
        for(Id id : newMap.keySet()){
            Opportunity oldOpp = oldMap.get(id);
            if((oldOpp.OverDue__c != newMap.get(id).OverDue__c || oldOpp.IsClosed != newMap.get(id).IsClosed) && newMap.get(id).AccountId!=null){
                accId.add(newMap.get(id).AccountId);
            }  
        }
        List<AggregateResult> closedOpp = [SELECT  COUNT(Id) cnt, AccountId FROM Opportunity WHERE isClosed=true AND AccountId IN :accId group by accountid];
        List<AggregateResult> overDueOpp = [SELECT  COUNT(Id) cnt, AccountId FROM Opportunity WHERE OverDue__c=true AND isClosed = false AND AccountId IN :accId group by accountid];
        List<Account> accToBeUpdated = new List<Account>();
        
        Map<Id, Account> accMapToUpdate = new Map<Id, Account>();

        for(Id aId : accId){
            accMapToUpdate.put(aId, new Account(
                Id = aId,
                Total_Number_of_OverDue__c = 0,
                Closed_Opportunity__c = 0
            ));
        }

        
                for (AggregateResult arr : overDueOpp) {
                    Id acccId = (Id)arr.get('AccountId');
                    Integer cnt = (Integer)arr.get('cnt');
                    accMapToUpdate.get(acccId).Total_Number_of_OverDue__c = cnt;
                }
            
                for (AggregateResult arr : closedOpp) {
                    Id acccId = (Id)arr.get('AccountId');
                    Integer cnt = (Integer)arr.get('cnt');
                    accMapToUpdate.get(acccId).Closed_Opportunity__c = cnt;
                }

        Database.SaveResult[] sv = Database.update(accMapToUpdate.values(),false); 
        for (Database.SaveResult res : sv) {
            if(res.isSuccess()){
                System.debug('Success'+ res.getId());
            }else {
                for (Database.Error err : res.errors) {
                    System.debug('eRRORS'+ err.getMessage());
                    System.debug(err.getFields());
                }
            }
        }
    }
}