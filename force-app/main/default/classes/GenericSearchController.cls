public with sharing class GenericSearchController {

    @AuraEnabled(cacheable=true)

    public static List<Account> searchAccounts(
        String field,
        String value
    ){

        String query =
        'SELECT Id, Name, Industry, CreatedDate FROM Account ' +
        'WHERE ' + field + ' LIKE \'%' + value + '%\'';

        return Database.query(query);
    }
}