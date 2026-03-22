@RestResource(urlMapping='/CreateAccOpp')
global with sharing class CreateAccOppAPI {

    public class Wrapper{
        public String AccountName;
        List<Opp> Opportunities;
    }
    public class Opp{
        public String Name;
        public String Stage;
        public String closeDate;
        public Opp(String name, String stage, String closeDate){
            this.Name = name;
            this.Stage = stage;
            this.closeDate = closeDate;
        }
    }
   
    
    @HttpPost
    global static Map<String,String> accOpp(){
        RestRequest req = RestContext.request;
        String reqString = req.requestBody.toString();
        List<Wrapper> reqMapiing = (List<Wrapper>)JSON.deserialize(reqString, List<Wrapper>.class);
        System.debug(reqMapiing);
        Map<String, List<Opp>> internalMap = new Map<String,List<Opp>>();
        
        // response map
        Map<String,String> response = new Map<String,String>();
        
        
        List<Account> accToBeInserted = new List<Account>();
        for (Wrapper wp : reqMapiing) {
            System.debug(wp);
            String name = wp.AccountName;
            if(String.isBlank(name)){
                response.put('null','Account creation failed with related opportunity');
            }
            Account acc = new Account(Name = wp.AccountName);
            accToBeInserted.add(acc);
            internalMap.put(wp.AccountName, new List<Opp>(wp.Opportunities));
        }
        System.debug(internalMap);

        

        Database.SaveResult [] sv = Database.insert(accToBeInserted,false);
        Set<Id> successIds = new Set<Id>();

        for (Database.SaveResult sr : sv) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            }
        }

        List<Account> successAccounts = new List<Account>();
        List<Account> errorAccounts = new List<Account>();

        for(Account ac : accToBeInserted){
            if(successIds.contains(ac.Id)){
                successAccounts.add(ac);
            } else {
                errorAccounts.add(ac);
            }
        }

        /////////////////////////

        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id IN :successIds];

        for(Account acc : successAccounts){
            response.put(acc.Name, 'Account successfully created');
        }
        for (Account acc : errorAccounts) {
            if(!String.isBlank(acc.Name)){
                response.put(acc.Name, 'Account insertion failed');
            }
        }

        ////////
        List<Opportunity> oppToBeInserted = new List<Opportunity>();
        for (Account ac : accList) {
            if(internalMap.containsKey(ac.Name)){
                List<Opp> op = internalMap.get(ac.Name);
                for(Opp o : op){
                    Opportunity newOp = new Opportunity(Name = o.Name, StageName = o.Stage, CloseDate = Date.parse(o.closeDate), AccountId = ac.Id);
                    oppToBeInserted.add(newOp);
                }
            }
        }

        System.debug(oppToBeInserted);
        Database.SaveResult[] sk= Database.insert(oppToBeInserted,false);
        Set<Id> successOppIds = new Set<Id>();
        for(Database.SaveResult sd : sk){
            if(sd.isSuccess()){
                successOppIds.add(sd.getId());
            }
        }

        List<Opportunity> successOpportunity = new List<Opportunity>();
        List<Opportunity> errorOpportunity = new List<Opportunity>();
        for(Opportunity op : oppToBeInserted){
            if(successOppIds.contains(op.Id)){
                response.put(op.Name, 'Opportunity inserted successfully');
            } else {
                response.put(op.Name, 'Opportunity insertion failed');
            }
        }
 
        return response;
    }
}