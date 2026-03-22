public with sharing class Assignment {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccount(String name){
        List<Account> acc = [SELECT Id, Name FROM Account WHERE Name LIKE :name+'%'];
        return acc;
    }
}