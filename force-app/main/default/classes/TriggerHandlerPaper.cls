public with sharing class TriggerHandlerPaper {
    
    public static void validate(List<Employee__c> newList, Map<Id, Employee__c> oldMap){
        System.debug('iNSIDE VAL');
        Set<Id> parentIds = new Set<Id>();
        for (Employee__c emp : newList) {
            if(emp.Parent__c!=null){
                parentIds.add(emp.Parent__c);
            }
        }

        Map<Id, Employee__c> parentMap = new Map<Id,Employee__c>([SELECT Id, RecordType.Name FROM Employee__c WHERE Id IN :parentIds]);
        Map<Id,Integer> childCountMap = new Map<Id,Integer>();
        for(Employee__c emp :[SELECT Id, Parent__c FROM Employee__c WHERE Parent__c IN :parentIds]){
            childCountMap.put(emp.Parent__c, childCountMap.containsKey(emp.Parent__c) ? childCountMap.get(emp.Parent__c)+1 : 1);
        }

        for(Employee__c emp : newList){
            if(emp.Parent__c==null) continue;

            Employee__c parent = parentMap.get(emp.Parent__c);
            if(parent==null) continue;
            System.debug(emp.RecordTypeID + ' '+ parent.RecordType.Name);
            if(emp.RecordTypeId=='012fj000004RPT3AAO' && parent.RecordType.Name!='BA'){
                emp.addError('Dev can only have BA as Parent');
            }

            Integer existingChild = childCountMap.get(emp.Parent__c);
            if(existingChild!=null && existingChild>=1){
                if(oldMap==null || oldMap.get(emp.Id).Parent__c != emp.Parent__c){
                    emp.addError('Parent already has child');
                }
            }
        }
    }

    public static void updateAgg(List<Employee__c> newList, Map<Id,Employee__c> oldMap){
        System.debug('iNSIDE UPAGG');
        Set<Id> parentIds = new Set<Id>();
        for (Employee__c emp : newList) {
            if(emp.Parent__c!=null){
                parentIds.add(emp.Parent__c);
            }
            if(oldMap!=null && oldMap.get(emp.Id).Parent__c != emp.Parent__c && oldMap.get(emp.Id).Parent__c !=null){
                parentIds.add(oldMap.get(emp.Id).Parent__c);
            }
        }
        if(!parentIds.isEmpty()){
            recalculate(parentIds);
        }
    }

    public static void updateAggOnDelete(List<Employee__c> oldList){
        Set<Id> parentIds = new Set<Id>();
        for (Employee__c emp : oldList) {
            if(emp.Parent__c!=null){
                parentIds.add(emp.Parent__c);
            }
        }
        if(!parentIds.isEmpty()){
            recalculate(parentIds);
        }
    }

    public static void recalculate(Set<Id> parentIds){
        System.debug('iNSIDE RECAL');
        List<Employee__c> parents = [SELECT Id, MAX_BA_Score__c, MAX_DEV_Score__c, SUM_BA_Score__c, SUM_DEV_Score__c FROM Employee__c WHERE Id IN: parentIds];
        List<Employee__c> childs = [SELECT Id, Parent__c, DEV_Score__c, BA__c,RecordType.Name FROM Employee__c WHERE Parent__c IN :parentIds];

        Map<Id, List<Employee__c>> childMap = new Map<Id,List<Employee__c>>();

        for (Employee__c emp : childs) {
            if(!childMap.containsKey(emp.Parent__c)){
                childMap.put(emp.Parent__c, new List<Employee__c>());
            }
            childMap.get(emp.Parent__c).add(emp);
        }

        for(Employee__c emp : parents){
            Decimal maxBa = 0;
            Decimal maxDev = 0;
            Decimal sumBa = 0;
            Decimal sumDev = 0;

            if(childMap.containsKey(emp.Id)){
                for(Employee__c child : childMap.get(emp.Id)){
                    if(child.RecordType.Name == 'BA' && child.BA__c!=null){
                        sumBa+=child.BA__c;
                        maxBa = Math.max(maxBa, child.BA__c);
                    }
                    if(child.RecordType.Name=='Developer' && child.DEV_Score__c!=null){
                        sumDev+=child.DEV_Score__c;
                        maxDev = Math.max(maxDev, child.DEV_Score__c);
                    }
                }
            }
            emp.SUM_BA_Score__c = sumBa;
            emp.SUM_DEV_Score__c = sumDev;
            emp.MAX_BA_Score__c = maxBa;
            emp.MAX_DEV_Score__c = maxDev;
        }
        update parents;
    }
}