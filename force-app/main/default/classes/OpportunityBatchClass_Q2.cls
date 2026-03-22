public with sharing class OpportunityBatchClass_Q2 implements Database.Batchable<SObject>{
    
    public  Database.QueryLocator start(Database.BatchableContext bc){
        // Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
        // 25 * 30 * 23 * * 
        // * 30 6 * * * 

        Datetime targetTime = System.now().addHours(-23).addMinutes(-30).addSeconds(-25);
        return Database.getQueryLocator([SELECT Id, StageName FROM Opportunity WHERE LastModifiedDate <= :targetTime AND StageName != 'Closed Won' AND StageName != 'Closed Lost']);
    }

    public  void execute(Database.BatchableContext bc , List<Opportunity> oppList){
        for (Opportunity opp : oppList) {
            opp.StageName = 'Closed Lost';
        }
        Database.update(oppList);
    }

    public  void finish(Database.BatchableContext bc){
        System.debug('Job Finished....');
        Id jobId = bc.getJobId();
        AsyncApexJob jobs = [SELECT Id,TotalJobItems, JobItemsProcessed, Status, NumberOfErrors FROM AsyncApexJob WHERE id =:jobId ];
        System.debug(jobs);
    }
}