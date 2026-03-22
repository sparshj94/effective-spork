public with sharing class OpportunityKanbanController {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(){
        return [SELECT Id, Name, StageName, Description FROM Opportunity];
    }

    @AuraEnabled
    public static Opportunity updateOpportunity(Opportunity opp){
        update opp;
        return opp;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getStages(){
        List<String> stages = new List<String>();
        for(Schema.PicklistEntry p : Opportunity.StageName.getDescribe().getPicklistValues()){
            stages.add(p.getValue());
        }
        return stages;
    }
}