trigger DapPracticePaper2EmpTrigger on Employeee__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            System.debug('before insert');
            PerformanceDap2Handler.preFillEmployee(Trigger.new);
        } else if(Trigger.isUpdate){
            System.debug('before update');
            PerformanceDap2Handler.validateEmployee(Trigger.new, Trigger.oldMap);
        }
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('after insert');
            PerformanceDap2Handler.updateAvgCompany(Trigger.new);
        } else if(Trigger.isUpdate){
            System.debug('after update');
            PerformanceDap2Handler.updateAvgCompany(Trigger.new);
        }
    }
}