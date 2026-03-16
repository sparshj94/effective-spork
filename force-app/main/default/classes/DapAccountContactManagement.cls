public with sharing class DapAccountContactManagement {
    

    // after insert account
    public static void insertNewRecords(List<Account> accList){
        List<Contact> contactToInserted = new List<Contact>();
        for (Account acc : accList) {
            Integer cnt = acc.Number_of_Contacts__c;
            for(Integer i=0; i<cnt; i++){
                Contact cn = new Contact();
                cn.AccountId = acc.Id;
                cn.LastName = 'Contact ' +i;
                contactToInserted.add(cn); 
            }
        }
        Database.insert(contactToInserted);        
    }

    // validate, before insert account
    public static void validate(List<Account> accList){
        for(Account acc: accList){
            if(acc.Number_of_Contacts__c<1){
                acc.addError('No of Contact field is zero or negative');
            }   
        }
    }

    // after insert, update, delete of contact check acc field with that
    public static void checkContactInsertUpdate(List<Contact> newList, Map<Id,Contact> oldMap){
        Set<Id> accIds = new Set<Id>();
        for (Contact cn : newList) {
            if(cn.AccountId!=null){
                accIds.add(cn.AccountId);
            }
        }
        Map<Id,Account> accMap = new Map<Id,Account>(
                [SELECT Id, Name, Number_of_Contacts__c, Company_Email__c,
                (SELECT Id FROM Contacts)
                FROM Account
                WHERE Id IN :accIds]
         );

        List<Contact_change_log__c> logs = new List<Contact_change_log__c>();

        for(Contact c : conList){

            logs.add(new Contact_change_log__c(
                Contact__c = c.Id,
                Change_Type__c = eventType,
                Changed_By__c = UserInfo.getUserId(),
                Change_Date_Time__c = System.now()
            ));
        }

        insert logs;

        sendAlertEmail(accMap);
    }


    public static void sendAlertEmail(Map<Id,Account> accMap){

        EmailTemplate template =
            [SELECT Id FROM EmailTemplate
            WHERE DeveloperName='Account_Alert'
            LIMIT 1];

        List<Messaging.SingleEmailMessage> emails =
            new List<Messaging.SingleEmailMessage>();

        for(Account acc : accMap.values()){

            Integer expected = acc.No_of_Contact__c.intValue();
            Integer actual = acc.Contacts.size();

            if(expected != actual){

                Messaging.SingleEmailMessage mail =
                    new Messaging.SingleEmailMessage();

                mail.setTemplateId(template.Id);
                mail.setWhatId(acc.Id);
                mail.setToAddresses(new String[]{acc.Company_Email__c});
                mail.setSaveAsActivity(false);

                emails.add(mail);
            }
        }

        Messaging.sendEmail(emails);
    }

}

