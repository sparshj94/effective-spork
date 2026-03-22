trigger DapPracticePaper2 on Performance__c (before insert, before update, after insert, after update) {

    // after insert, update 
    // send perfromance review mail
    // avg rating of empolyee , bonus, ctc and mp

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            PerformanceDap2Handler.validatePerformance(Trigger.new);
        } else if(Trigger.isUpdate){
            PerformanceDap2Handler.validatePerformance(Trigger.new);
        }
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            PerformanceDap2Handler.updateAvgRatingEmployee(Trigger.new, Trigger.oldMap);
            PerformanceDap2Handler.updateSalaryFields(Trigger.new);
            // PerformanceDap2Handler.sendPerformanceReviewMail(Trigger.new);
            PerformanceDap2Handler.sendLowRatingEmployees();
            PerformanceDap2Handler.sendMailToManagers();
        } else if(Trigger.isUpdate){
            PerformanceDap2Handler.updateAvgRatingEmployee(Trigger.new, Trigger.oldMap);
            PerformanceDap2Handler.updateSalaryFields(Trigger.new);
        }
    }
}