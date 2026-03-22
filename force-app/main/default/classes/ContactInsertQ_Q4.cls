public with sharing class ContactInsertQ_Q4 implements Queueable{
    
    List<Account> accList = new List<Account>();

    public ContactInsertQ_Q4(List<Account> accList){
        this.accList = accList;
    }

    public void execute(QueueableContext qc){
        List<Contact> contactList = new List<Contact>();
        for(Integer i =1; i<=accList.size(); i++){
            Contact cn = new Contact(LastName = 'Accql ' + i, AccountId = accList[i].Id);
            contactList.add(cn);
        }
        Database.insert(contactList);
        System.enqueueJob(new SysAdminReviewQ_Q4());
    }
}