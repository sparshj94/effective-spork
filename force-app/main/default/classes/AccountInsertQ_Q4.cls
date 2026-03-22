public with sharing class AccountInsertQ_Q4 implements Queueable{
    
    public void execute(QueueableContext qc){
        List<Account> accList = new List<Account>();
        for(Integer i = 1; i<=2000; i++){
            Account acc = new Account(Name = 'Accountq ' + i);
            accList.add(acc);
        }
        Database.insert(accList);

        List<Account> newList = [SELECT Id, Name FROM Account WHERE Name LIKE 'Accountq%'];
        System.enqueueJob(new ContactInsertQ_Q4(newList));
    }
}