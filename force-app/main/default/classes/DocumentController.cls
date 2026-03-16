public with sharing class DocumentController {
    
    @AuraEnabled(cacheable=true)
    public static List<Document__c> getAllDocuments(){
        List<Document__c> dc = [SELECT Id, Name, Document_Type__c, isActive__c, ValidFromYear__c, ValidToYear__c from Document__c ];
        return dc;
    }

    @AuraEnabled()
    public static String insertDocuments(List<Document__c> docList){
        Database.SaveResult[] sv = Database.insert(docList);
        for (Database.SaveResult sb : sv) {
            if(sb.isSuccess()){
                return 'Succesfully Inserted';
            }
        }
        return 'Inserted';
    }

    
}