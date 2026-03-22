public class InsStatement {
  
    
    public static void appendingName(){
        List<Student__c> studentList = [SELECT Student_Name__c FROM Student__c WHERE Student_Name__c LIKE 'S%'];
        //System.debug(studentList);
        for(Integer i = 0; i<studentList.size(); i++){
            Integer count = i+1;
            String name = studentList[i].Student_Name__c;
            String firstName = name.substringBefore(' ');
            String lastName = name.substringAfter(' ');
            String newName = firstName + ' '+ lastName +' ' + 'Test' + ' ' + count;
            studentList[i].Student_Name__c = newName;
        }
        Database.update(studentList,false);
        System.debug(studentList);
    }
    
    public static void createOpportunitiesWithoutLinks(){
        List<Account> accountListDontHaveOpportunity = [SELECT Name ,(SELECT Name FROM Opportunities) FROM Account WHERE ID NOT IN  (SELECT AccountId FROM Opportunity)];
        List<Opportunity> opportunityCreated = new List<Opportunity>();
        for (Account ac : accountListDontHaveOpportunity) {
            Opportunity op = new Opportunity();
            op.Name  = ac.Name + ' ' + 'First Opportunity';
            op.StageName = 'Prospecting';
            op.CloseDate = System.today();
            op.AccountId = ac.Id;
            opportunityCreated.add(op);
        }
        Database.insert(opportunityCreated);
    }
    
    
    public static void manipulateAccountAndContact(){
        Account acc = new Account();
        acc.Name = 'Unive Container';
        Contact cn = new Contact();
        cn.LastName='Carter last';
        cn.AccountId  = acc.Id;
        Database.insert(acc,false);
        Database.insert(cn,false);
        delete(acc);
        delete(cn);
        undelete(acc);
    }
    
    public static void deleteStudentsWithSecondLetterR(){
        List<Student__c> studentList = [SELECT Student_Name__c FROM Student__c WHERE Student_Name__c LIKE '_r%'];
        Database.emptyRecycleBin(studentList);
    }
    
    public static void undeleteStudentsDaletedByDemoUser(Date dateValue1, Date dateValue2){
        List<Student__c> deletedStudent = [SELECT Student_Name__c FROM Student__c WHERE isDeleted=TRUE AND (LastModifiedDate >:dateValue1 AND LastModifiedDate <:dateValue2) AND LastModifiedBy.Name = 'Salesforce Demo'];
        undelete(deletedStudent);
    }
    
    public static void insertAccountContactRecords(){
        List<sObject> objList = new List<sObject>();
        Account acc = new Account( Name = 'Test Account', Company_Email__c = 'testcompany@gmail.com');
        objList.add(acc);
        Contact cn = new Contact(Account= new Account(Company_Email__c = 'testcompany@gmail.com'), LastName = 'Doe');
        objList.add(cn);
        Database.insert(objList,false);
    }
    
    public static void del(){
        List<Account> ac = [SELECT Name FROM Account WHERE Name LIKE 'Acc%'];
        delete(ac);
    }
    

    public static List<sObject> insertAndCreateRelatedRecords(){
        Product2 product = [SELECT Name FROM Product2 WHERE Name = 'GenWatt Diesel 10kW'];
        Pricebook2 priceBook = [SELECT Name FROM Pricebook2 WHERE Name = 'Standard Price Book'];
        List<sObject> relatedAccount = new List<sObject>();

        for(Integer i = 1; i<6; i++){
            Account ac = new Account(Name = 'Acc'+ ' ' + i, Company_Email__c = 'testaccount' + i + '@gmail.com');
            Account ref = new Account(Company_Email__c = 'testaccount' + i + '@gmail.com');
            relatedAccount.add(ac);
            Contact cn = new Contact(LastName = ac.Name + ' ' + 'Contact', Account = ref);
            relatedAccount.add(cn);
            Opportunity op = new Opportunity(Name = ac.Name + '-' + 'Opp', Account = ref, Pricebook2Id=priceBook.Id, StageName = 'Prospecting',CloseDate = System.today());
            relatedAccount.add(op);
        }
        relatedAccount.sort();
        Database.SaveResult[] sv = Database.insert(relatedAccount,false);
        List<sObject> oplSaveList = new List<sObject>();
        List<Opportunity> opList = [SELECT Name FROM Opportunity WHERE Name  LIKE 'Acc%'];
        for (Opportunity ops : opList) {
            OpportunityLineItem opl = new OpportunityLineItem(OpportunityId = ops.ID, Product2Id = product.Id,TotalPrice=20000, Quantity=100);
            oplSaveList.add(opl);
            relatedAccount.add(opl);
        }
        sv=Database.insert(oplSaveList,false);
        for (Database.SaveResult s : sv) {
            if(s.isSuccess()){
                System.debug('sUCCESS');
            } else {
                System.debug('Error');
                for (Database.Error ee : s.getErrors()) {
                    System.debug(ee.getFields());
                    System.debug(ee.getMessage());
                }
            }
        }
        return relatedAccount;
    }
    public static void deleteOpp() {
        List<AggregateResult> results = [SELECT AccountId FROM Opportunity WHERE IsClosed = false AND AccountId != null GROUP BY AccountId  HAVING COUNT(Id) > 2];

        List<Id> accountIdToDelete = new List<Id>();
        for (AggregateResult ar : results) {
            accountIdToDelete.add((Id)ar.get('AccountId'));
        }
        if (!accountIdToDelete.isEmpty()) {
            Database.delete(accountIdToDelete, false);
        }
    }
    
    public static void amc(){
        String s = 'Student__c';
        Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = globalMap.get(s);
        System.debug(sObjType);
        List<sObject> st = Database.query('SELECT COUNT(Id) FROM :sObjType');
        System.debug(st);
    }
    
    public static Integer totalRecordsInObject(String objName){
        String query = 'SELECT COUNT(Id) cnt FROM ' + objName;
        List<AggregateResult> st = Database.query(query);
        Integer i= (Integer)st[0].get('cnt');
        System.debug(i); 
        return i;
    }
    public static void checkOpportunityDuplicacy(List<Opportunity> oppList){
       // check for same name in existing opp for that account && 
       Set<Id> accountIdOfTriggeringOpp = new Set<Id>();
       for(Opportunity op : oppList){
            accountIdOfTriggeringOpp.add(op.AccountId);
       }
       List<Opportunity> existingOppForTriggeringOppAccount = [SELECT ID FROM Opportunity WHERE AccountId IN :accountIdOfTriggeringOpp];

    }
}