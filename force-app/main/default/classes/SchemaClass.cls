public class SchemaClass {
    public static void mt(){
        List<Account> accList = new List<Account>();
        for(Integer i = 1; i<=200; i++){
            Account ac = new Account(Name = 'Accn ' + i);
            ac.Rating = 'Cold';
            ac.CustomerPriority__c = 'Low';
            accList.add(ac);
        }
        Database.insert(accList,false);
    }
    
    public static void del(){
        List<Account> insertedAccount = [SELECT ID, Name FROM Account WHERE Name LIKE 'Accn%'];
        Database.delete(insertedAccount);
    }
}