public with sharing class Dap2OpportunityController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> getOpportunitiesByStage() {
        Map<String, List<Opportunity>> stageMap = new Map<String, List<Opportunity>>();

        List<Opportunity> opps = [ SELECT Id, Name, Amount, StageName, Email__c FROM Opportunity ORDER BY Amount DESC];

        for (Opportunity opp : opps) {
            if (!stageMap.containsKey(opp.StageName)) {
                stageMap.put(opp.StageName, new List<Opportunity>());
            }
            stageMap.get(opp.StageName).add(opp);
        }

        return stageMap;
    }

    @AuraEnabled(cacheable=true)
    public static void deleteOpportunity(Id oppId){
        delete [SELECT Id FROM Opportunity WHERE ID  = :oppId];
    }
}