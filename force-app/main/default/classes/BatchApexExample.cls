public class BatchApexExample implements Database.Batchable<sObject> {
	
    public static Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Name FROM Account');
    }
    
    public static void execute(Database.BatchableContext bc , List<Account> accList){
        System.debug(accList.size());
        for(Account acc : accList){
            acc.Name = acc.Name + ' Batch';
        }
    }
    
    public static void finish(Database.BatchableContext bc){
        System.debug('Batch Processigng completed');
    }
}