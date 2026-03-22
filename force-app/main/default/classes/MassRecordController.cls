public with sharing class MassRecordController {

    @AuraEnabled

    public static void updateAccounts(
        List<Id> recordIds,
        String fieldName,
        String value
    ){

        List<Account> accounts = [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Id IN :recordIds
        ];

        for(Account acc : accounts){

            acc.put(fieldName, value);

        }

        update accounts;
    }


    @AuraEnabled

    public static void deleteAccounts(
        List<Id> recordIds
    ){

        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE Id IN :recordIds
        ];

        delete accounts;

    }

}