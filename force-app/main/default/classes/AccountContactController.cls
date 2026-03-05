public with sharing class AccountContactController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer limitSize, Integer offSet){
        List<Account> acc = [SELECT Name, Phone, Industry FROM Account LIMIT: limitSize OFFSET :offSet];
        return acc;
    }
    
}