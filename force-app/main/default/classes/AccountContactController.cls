public with sharing class AccountContactController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer limitSize, Integer offSet){
        List<Account> acc = [SELECT Name, Phone, Industry, Rating FROM Account LIMIT: limitSize OFFSET :offSet];
        return acc;
    }
    @AuraEnabled
    public static List<Account> getAccountss(Integer limitSize, Integer offSet){
        List<Account> acc = [SELECT Name, Phone, Industry, Rating FROM Account LIMIT: limitSize OFFSET :offSet];
        return acc;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Integer limitSize, Integer offSet, Id accountId){
        List<Contact> con = [SELECT Name, Account.Name, Phone, Email FROM Contact WHERE AccountId = :accountId LIMIT: limitSize OFFSET :offSet];
        return con;
    }
    
}