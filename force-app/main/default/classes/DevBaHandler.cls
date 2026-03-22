public with sharing class DevBaHandler {
    private static Id baRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('BA').getRecordTypeId();
    private static Id devRecordTypeId = Schema.SObjectType.Employee__c.getRecordTypeInfosByDeveloperName().get('Developer').getRecordTypeId();

    public static void validate(List<Employee__c> newList, Map<Id,Employee__c> oldMap, Boolean isInsert, Boolean isUpdate){
        Set<Id> parentIdsToCheck = new Set<Id>();
        for(Employee__c emp : newList){
            if(emp.parent__c !=null){
                if(isInsert || (isUpdate&&emp.parent__c != oldMap.get(emp.Id).parent__c)){
                    parentIdsToCheck.add(emp.parent__c);
                }
            }
        }
        if(parentIdsToCheck.isEmpty()) return;

       
        Map<Id,Employee__c> parentMap = new Map<Id,Employee__c>([SELECT Id, RecordTypeId, (SELECT Id FROM Employees__r) FROM Employee__c WHERE ID IN :parentIdsToCheck]);
        Map<Id, Integer> childCount = new Map<Id,Integer>();

        for(Employee__c emp: newList){
            if(emp.parent__c!=null){
                if(isInsert || (isUpdate&&emp.parent__c!=oldMap.get(emp.Id).parent__c)){
                    Employee__c parent = parentMap.get(emp.parent__c);

                    if(emp.RecordTypeId == devRecordTypeId && parent.RecordTypeId!=baRecordTypeId){
                        emp.addError('Parent of Dev can only be BA Employee');
                    }
                    
                    // FIX 2: Updated the size check here to Employees__r
                    Integer existingChild = parent.Employees__r.size();
                    Integer incoming = childCount.containsKey(emp.parent__c) ? childCount.get(emp.parent__c) : 0;

                    if(existingChild+incoming>=1){
                        emp.addError('Parent has already child');
                    } else{
                        childCount.put(emp.parent__c, incoming+1);
                    }
                }
            }
        }
    }

    public static void handleAfter(List<Employee__c> newList, Map<Id, Employee__c> oldMap, Boolean isUpdate, Boolean isInsert, Boolean isDelete, Boolean isUndelete){
        Set<ID> parentIdsToRecalculate = new Set<Id>();
        List<Employee__c> recordsToProcess = isDelete ? oldMap.values() : newList;

        for(Employee__c emp : recordsToProcess){
            if(isInsert || isUndelete || isDelete){
                if(emp.parent__c!=null){
                    parentIdsToRecalculate.add(emp.parent__c);
                }
            } else if(isUpdate){
                // score and reparenting
                Employee__c oldEmp = oldMap.get(emp.Id);

                // reparent
                if(emp.parent__c!=oldEmp.parent__c){
                    if(emp.parent__c!=null) parentIdsToRecalculate.add(emp.parent__c);
                    if(oldEmp.parent__c!=null) parentIdsToRecalculate.add(oldEmp.parent__c);
                }
                else if(emp.BA__c !=oldEmp.BA__c || emp.DEV_Score__c !=oldEmp.DEV_Score__c ){
                    if(emp.parent__c!=null) parentIdsToRecalculate.add(emp.parent__c);
                }
            }
        }
        if(!parentIdsToRecalculate.isEmpty()){
            recalculate(parentIdsToRecalculate);
        }
    }
    
    public static void recalculate(Set<Id> parentIds){
        if(parentIds.isEmpty()) return;
        

        List<Employee__c> parentToUpdate = [SELECT Id, parent__c, (SELECT Id, RecordTypeId, BA__c, DEV_Score__c, SUM_BA_Score__c, SUM_DEV_Score__c, MAX_BA_Score__c, MAX_DEV_Score__c FROM Employees__r) 
            FROM Employee__c WHERE Id IN :parentIds];
            
        List<Employee__c> updates = new List<Employee__c>();
        Set<Id> nextLevelParentId = new Set<Id>();

        for(Employee__c parent : parentToUpdate){
            Decimal sumBA = 0, sumDev = 0;
            Decimal maxBA = 0, maxDev = 0;
            
            
            for(Employee__c child : parent.Employees__r){
                Decimal childBAScore = child.RecordTypeId == baRecordTypeId ? (child.BA__c != null ? child.BA__c : 0) : 0;
                Decimal childDEVScore = child.RecordTypeId == devRecordTypeId ? (child.DEV_Score__c != null ? child.DEV_Score__c : 0) : 0;

                Decimal childSumBA = child.SUM_BA_Score__c != null ? child.SUM_BA_Score__c : 0;
                Decimal childSumDEV = child.SUM_DEV_Score__c != null ? child.SUM_DEV_Score__c : 0;

                sumBA += (childBAScore + childSumBA);
                sumDev += (childDEVScore + childSumDEV);

                Decimal currentChildMaxBA = Math.max(childBAScore, child.MAX_BA_Score__c != null ? child.MAX_BA_Score__c : 0);
                Decimal currentChildMaxDEV = Math.max(childDEVScore, child.MAX_DEV_Score__c != null ? child.MAX_DEV_Score__c : 0);

                if(currentChildMaxBA > maxBA) maxBA = currentChildMaxBA;
                if(currentChildMaxDEV> maxDev) maxDev = currentChildMaxDEV;
            }
            parent.MAX_BA_Score__c = maxBA;
            parent.SUM_BA_Score__c = sumBA;
            parent.SUM_DEV_Score__c = sumDev;
            parent.MAX_DEV_Score__c = maxDev;
            updates.add(parent);
            if(parent.Parent__c!=null){
                nextLevelParentId.add(parent.Parent__c);
            }
        }
        if(!updates.isEmpty()){
            update updates;
        }
        if(!nextLevelParentId.isEmpty()){
            recalculate(nextLevelParentId);
        }
    }
}