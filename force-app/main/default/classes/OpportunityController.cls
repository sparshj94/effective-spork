public with sharing class OpportunityController {
    
    @AuraEnabled()
    public static List<Opportunity> getOpenOpportunity(Integer limitSize, Integer offSet){
        List<Opportunity> opp = [SELECT Id, Name, StageName FROM Opportunity WHERE isClosed = false LIMIT :limitSize OFFSET:offSet];
        return opp;
    }
}