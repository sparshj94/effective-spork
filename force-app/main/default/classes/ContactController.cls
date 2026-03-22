public with sharing class ContactController {
    
    @AuraEnabled()
    public static List<Contact> getContacts(Integer rowLimit, Integer offSet){
        List<Contact> conList = [SELECT Id, Name, Account.Name, LeadSource, Email FROM Contact ORDER BY Id LIMIT:rowLimit OFFSET:offSet];
        return conList;
    }
}