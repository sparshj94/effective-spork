public with sharing class ContactController {
    
    @AuraEnabled()
    public static List<Contact> getContacts(Integer rowLimit, Integer offSet){
        List<Contact> conList = [SELECT Name Account.Name, LeadSource, Email FROM Contact LIMIT:rowLimit OFFSET:offSet];
        return conList;
    }
}