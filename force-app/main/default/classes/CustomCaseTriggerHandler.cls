public with sharing class CustomCaseTriggerHandler {
    

    // public static void calculateTotalCases(List<Custom_Case__c> newList, Map<Id,Custom_Case__c> oldMap){
    //     // insert update delete ? 
    //     // after insert
    //     Set<Id> trackerModelIds = new Set<Id>();
    //     for (Custom_Case__c cs : newList) {
    //         if(cs.Tracker_Model__c!=null){
    //             trackerModelIds.add(cs.Tracker_Model__c);
    //         }
    //     }
    //     System.debug(trackerModelIds);
    //     // Total_Cases__c Tracker_Model__c
    //     List<Tracker_Model__c> trackerModel = [SELECT Id, Name, (SELECT Id FROM Custom_Cases__r) FROM Tracker_Model__c WHERE Id IN :trackerModelIds];
    //     Map<Id, Integer> trackerCaseCountMap = new Map<Id, Integer>();
    //     for (Tracker_Model__c tm : trackerModel) {
    //         if(!trackerCaseCountMap.containsKey(tm.Id)){
    //             Integer caseCount  = tm.Custom_Cases__r.size() > 0 ? tm.Custom_Cases__r.size() : 0;
    //             trackerCaseCountMap.put(tm.Id, caseCount);
    //         }
    //     }
    //     List<Tracker_Model__c> trackerToUpdate = new List<Tracker_Model__c>();
    //     for(Tracker_Model__c tm : trackerModel){
    //         if(trackerCaseCountMap.containsKey(tm.Id)){
    //             Tracker_Model__c tc = new Tracker_Model__c(Id = tm.Id, Total_Cases__c = trackerCaseCountMap.get(tm.Id));
    //         }
    //     }
    //     System.debug(trackerToUpdate);
    //     Database.update(trackerToUpdate);
    // }

    // worked
    public static void updateAutomaticCaseStatus(List<Custom_Case__c> newList, Map<Id,Custom_Case__c> oldMap){
        // before insert
        System.debug('open calal');
        for (Custom_Case__c cs : newList) {
            cs.Status__c = 'Open';
        }
    }

    public static void updateStatusToResolved(List<Custom_Case__c> newList, Map<Id,Custom_Case__c> oldMap){
        // after update }} before update
        for (Custom_Case__c cs : newList) { 
            if(cs.Resolution_Details__c!=null|| !String.isBlank(cs.Resolution_Details__c) || !String.isEmpty(cs.Resolution_Details__c)){
                cs.Status__c = 'Resolved';
            }
        }
        // Database.update(newList,false);
    }

    public static void preventStatusChange(List<Custom_Case__c> newList, Map<Id,Custom_Case__c> oldMap){
        // before update
        for (Custom_Case__c cs : newList) {
            System.debug(cs.Resolution_Details__c);
            System.debug(String.isBlank(cs.Resolution_Details__c));
            System.debug(String.isEmpty(cs.Resolution_Details__c));
            // if(cs.Resolution_Details__c==null|| String.isBlank(cs.Resolution_Details__c) || String.isEmpty(cs.Resolution_Details__c)){
            //     cs.addError('Status cant be change until Resolution Details is Blank');
            // }
            Custom_Case__c oldCase = oldMap.get(cs.Id);
            if(cs.Status__c != oldCase.Status__c){
                if(cs.Resolution_Details__c==null|| String.isBlank(cs.Resolution_Details__c) || String.isEmpty(cs.Resolution_Details__c)){
                    cs.addError('Status cant be change until Resolution Details is Blankkkk');
                }
            }
        }
    }


    public static void onInsertAndUpdate(List<Custom_Case__c> oldCase , Map<Id,Custom_Case__c> newCase){
        Set<Id> parentIds = new Set<Id>();
        if(oldCase!=null){
           for(Custom_Case__c casee : oldCase){
                if(casee.Tracker_Model__c !=null){
                    parentIds.add(casee.Tracker_Model__c);
                }
            } 
        }
        
        if(newCase!=null){
            for(Custom_Case__c casee : newCase.values()){
                if(casee.Tracker_Model__c !=null){
                    parentIds.add(casee.Tracker_Model__c);
                }
            }
        }
		        
        List<Tracker_Model__c> accountsToUpdate = new List<Tracker_Model__c>();
        for (Tracker_Model__c acc : [SELECT Id, (SELECT Id FROM Custom_Cases__r) FROM Tracker_Model__c WHERE Id IN :parentIds]) {
            acc.Total_Cases__c = acc.Custom_Cases__r.size(); 
            accountsToUpdate.add(acc);
        }
        
        if (accountsToUpdate.size() > 0) {
        	update accountsToUpdate;
    	}
    }

}