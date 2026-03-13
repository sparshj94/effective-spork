public with sharing class AccountAndContact {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer limitSize, Integer offSet, String name, String industry, String rating){
        List<Account> acc = [SELECT Name, Phone, Industry, Rating FROM Account WHERE Name=:name AND Industry=:industry AND Rating=:rating  LIMIT: limitSize OFFSET :offSet];
        return acc;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Integer limitSize, Integer offSet, Id accountId){
        List<Contact> con = [SELECT Name, Account.Name, Phone, Email FROM Contact WHERE AccountId = :accountId LIMIT: limitSize OFFSET :offSet];
        return con;
    }
}