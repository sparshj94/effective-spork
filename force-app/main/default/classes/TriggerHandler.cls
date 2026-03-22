public with sharing class TriggerHandler {
    

    public static void calculateTotalCases(List<Custom_Case__c> newList, Map<Id,Custom_Case__c> oldMap){
        // insert update delete ? 
        // insert
        Set<Id> trackerModelIds = new Set<Id>();
        for (Custom_Case__c cs : newList) {
            if(cs.Tracker_Model__c!=null){
                trackerModelIds.add(cs.Tracker_Model__c);
            }
        }
        // Total_Cases__c Tracker_Model__c
        List<Tracker_Model__c> trackerModel = [SELECT Id, Name, (SELECT Id FROM Custom_Cases__r) FROM Tracker_Model__c WHERE Id IN :trackerModelIds];
    }
}