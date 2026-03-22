public with sharing class MyRecordsController {
	 @AuraEnabled
    public static List<Map<String, String>> getAllObjectsLabel(List<String> objApiList) {
        List<Map<String, String>> items = new List<Map<String, String>>();
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(objApiList); 
        for(Schema.DescribeSObjectResult sd: describeSobjectsResult){
            items.add(new Map<String, String>{'value' => sd.getName(), 'label' => sd.getLabel()});
        }        
        return items;
    }



    // String objectName = 'Opportunity';
    // String fieldName ='StageName';
    @AuraEnabled
    public static List<Map<String, String>> getPickListVals(){
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('Opportunity') ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        List<Map<String, String>> items = new List<Map<String, String>>();
        Schema.DescribeFieldResult fieldResult = fields.get('StageName').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            items.add(new Map<String, String>{'value' => pickListVal.getValue(), 'label' => pickListVal.getLabel()});
        }
        return  items;
    }
}