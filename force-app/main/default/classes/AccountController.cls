public with sharing class AccountController {
 
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer rowLimit, Integer offSet){
        List<Account> acc = [SELECT Id, Name,NumberOfEmployees, Phone, Owner.Name, BillingCity, (SELECT Id, Name,NumberOfEmployees, Phone, Owner.Name, BillingCity FROM ChildAccounts) FROM Account LIMIT: rowLimit OFFSET:offSet];
        return acc;
    }
}