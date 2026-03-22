/**
 * @description     For showing how to comment on classes, different methods, and class variables
 * @author          Sparsh Jain
 */
public with sharing class DMLAssignment {
    
    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
    */
    
    public static void appendingName(){
        List<Student__c> studentList = [SELECT Student_Name__c FROM Student__c WHERE Student_Name__c LIKE 'S%' WITH SECURITY_ENFORCED];
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

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
    */

    public static void createOpportunitiesWithoutLinks(){
        List<Account> accountListDontHaveOpportunity = [SELECT Name ,(SELECT Name FROM Opportunities) FROM Account WHERE ID NOT IN  (SELECT AccountId FROM Opportunity) WITH SECURITY_ENFORCED];
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

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
    */

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

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
    */

    public static void deleteStudentsWithSecondLetterR(){
        List<Student__c> studentList = [SELECT Student_Name__c FROM Student__c WHERE Student_Name__c LIKE '_r%' WITH SECURITY_ENFORCED];
        Database.emptyRecycleBin(studentList);
    }

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
     * @param dateValue1  first date
     * @param dateValue2 second date
    */

    public static void undeleteStudentsDaletedByDemoUser(Date dateValue1, Date dateValue2){
        List<Student__c> deletedStudent = [SELECT Student_Name__c FROM Student__c WHERE isDeleted=TRUE AND (LastModifiedDate >:dateValue1 AND LastModifiedDate <:dateValue2) AND LastModifiedBy.Name = 'Salesforce Demo' WITH SECURITY_ENFORCED];
        undelete(deletedStudent);
    }

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
    */

    public static void insertAccountContactRecords(){
        List<sObject> objList = new List<sObject>();
        Account acc = new Account( Name = 'Test Account', Company_Email__c = 'testcompany@gmail.com');
        objList.add(acc);
        Contact cn = new Contact(Account= new Account(Company_Email__c = 'testcompany@gmail.com'), LastName = 'Doe');
        objList.add(cn);
        Database.insert(objList,false);
    }

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
     * @return List<sObject> insertAndCreateRelatedRecords
    */

    public static List<sObject> insertAndCreateRelatedRecords(){
        Product2 product = [SELECT Name FROM Product2 WHERE Name = 'GenWatt Diesel 10kW' WITH SECURITY_ENFORCED];
        Pricebook2 priceBook = [SELECT Name FROM Pricebook2 WHERE Name = 'Standard Price Book' WITH SECURITY_ENFORCED];
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
        List<Opportunity> opList = [SELECT Name FROM Opportunity WHERE Name  LIKE 'Acc%' WITH SECURITY_ENFORCED];
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

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
    */

    public static void deleteOpp(){
        List<AggregateResult> l = [SELECT AccountId,Count(Id) FROM Opportunity  WHERE IsClosed=false WITH SECURITY_ENFORCED GROUP BY AccountId  HAVING Count(Id)>2 ];
        List<AggregateResult> l2 = [SELECT AccountId,Count(Id) FROM Opportunity WHERE IsClosed=true WITH SECURITY_ENFORCED GROUP BY AccountId ];
        List<Id> delAccountList = new List<Id>();
        Boolean check=true;
        for(AggregateResult o: l){
            for(AggregateResult e:l2){
                
                if(o.get('AccountId') == e.get('AccountId')){
                    check=false;
                    
                }
            }
            if(check){
                delAccountList.add((Id)o.get('AccountId'));
                
            }else{
                check=true;
            }
        }
        Database.delete(delAccountList);
    }

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
     * @param objName obj name as string
    */

    public static Integer totalRecordsInObject(String objectName){
        String query = 'SELECT COUNT(Id) cnt FROM ' + objectName + ' WITH SECURITY_ENFORCED';
        List<AggregateResult> st = Database.query(query);
        Integer i= (Integer)st[0].get('cnt');
        System.debug(i);
        return i;
    }

    /**
     * @description For showing how to comment on a method parameter and a return type.
     * @author  Sparsh Jain
     * @param stdToInsertList giving list of student
    */

    public static void rollbackStudentRecords(List<Student__c> stdToInsertList){
        SavePoint sp = Database.setSavepoint();
        Integer total = stdToInsertList.size();
        Integer successCount =0;
        try {
            Database.SaveResult [] res = Database.insert(stdToInsertList,false);
            for (Database.SaveResult s : res) {
                if (s.isSuccess()) {
                    System.debug('Success');
                    successCount++;
                } else {
                    System.debug('Error');
                    for (Database.Error err : s.getErrors()) {
                        System.debug(err.message);
                    }
                }
            }
            if ((successCount / total)*100 < 80) {
                Database.rollback(sp);
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }
}