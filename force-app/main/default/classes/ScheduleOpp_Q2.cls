public with sharing class ScheduleOpp_Q2 implements Schedulable{
    // String t1 =    '0 0 0 * * ?';
    // 0 30 0/6 * * ? 
    // To call the schedule func
    // ScheduleOpp_Q2 sch = new ScheduleOpp_Q2();
    // String st = 0 30 0/6 * *;
    // String jobId = System.schedule('Opp Close', st, sch);
    public void execute(SchedulableContext sc){
        OpportunityBatchClass_Q2 bae = new OpportunityBatchClass_Q2();
       	Database.executeBatch(bae);
    }
}