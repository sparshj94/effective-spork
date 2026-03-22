public with sharing class DapTestOpportunitiesController {
    

    @AuraEnabled
    public static List<Opportunity> getOpportunities(Integer rowLimit, Integer rowOffSet){
        List<Opportunity> oppList = [SELECT Id, Name, Type, Account.Name, CreatedDate, LeadSource, TotalOpportunityQuantity, StageName FROM Opportunity LIMIT :rowLimit OFFSET :rowOffSet];
        return oppList;
    }
}