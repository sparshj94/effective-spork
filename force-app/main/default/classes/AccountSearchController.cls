public with sharing class AccountSearchController {

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String name, String industry, String rating) {

        String query = 'SELECT Id, Name, Industry, Rating, Website FROM Account WHERE Id != null';

        if(String.isNotBlank(name)){
            query += ' AND Name LIKE \'%' + name + '%\'';
        }

        if(String.isNotBlank(industry)){
            query += ' AND Industry = :industry';
        }

        if(String.isNotBlank(rating)){
            query += ' AND Rating = :rating';
        }

        query += ' ORDER BY Name';

        return Database.query(query);
    }


    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId){

        return [
            SELECT Id, FirstName, LastName, Email, Phone
            FROM Contact
            WHERE AccountId = :accountId
        ];
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getRatings(){

        List<String> ratings = new List<String>();

        Schema.DescribeFieldResult field = Account.Rating.getDescribe();

        for(Schema.PicklistEntry entry : field.getPicklistValues()){
            ratings.add(entry.getValue());
        }

        return ratings;
    }
}