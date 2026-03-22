public class QueryAssignment {
	public static List<AggregateResult> getClosedOpportunitySumByFiscalYear(){
        String userId = UserInfo.getUserId();
        List<AggregateResult> closedList = [SELECT SUM(Amount) amount, Fiscal_Year(CreatedDate) fy FROM Opportunity WHERE StageName = 'Closed Won' AND Owner.Id =:userId GROUP BY Fiscal_Year(CreatedDate)];
        return closedList;
    }
    
    public static List<Opportunity> fetchOpportunitiesBetweenDates(Date firstDate, Date secondDate){
        List<Opportunity> opportunityList = [SELECT Name FROM Opportunity WHERE CloseDate > :firstDate AND CloseDate < :secondDate AND Owner.Name = 'Saurman D’souza'];
        return opportunityList;
    }
    
 
    public static List<Account> fetchAccountsWithRelatedData(){
        List<Account> relatedList = [SELECT (SELECT Name FROM Opportunities) opp, (SELECT Name FROM Contacts) cn, (SELECT Title FROM Notes)nt FROM Account WHERE Name LIKE 'B%'];
        return relatedList;
    }
    
    public static List<Opportunity> fetchRelatedDataForOpportunity(){
        List<Opportunity> oppList = [SELECT Name, Account.Name, (SELECT Title from Notes), (SELECT Contact.Name FROM OpportunityContactRoles) FROM Opportunity WHERE NAME LIKE '%A'];
        return oppList;
    }
    
    public static List<List<sObject>> fetchTestOpportunityRecords(){
        Id userId = UserInfo.getUserId();
        List<List<sObject>> objList = [FIND 'Test' RETURNING Account(Id, Name WHERE Owner.Id=:userId), Opportunity(Id, Name WHERE CloseDate = This_Fiscal_year) ];
        return objList;
    }
    
    public static Map<Id, List<Opportunity>> opportunitiesRelatedToAccountMap  = new Map<Id, List<Opportunity>>(); 
    public static Map<Id, List<Contact>> contactsRelatedToAccountMap = new Map<Id, List<Contact>>();
    public static Map<Id, List<Note>> notesRelatedToAccountMap = new Map<Id, List<Note>>();
   

  	public static void setOppContactNotesRelatedToAccount(){
        List<Account> relatedList = [SELECT Name, (SELECT Name FROM Opportunities), (SELECT Name FROM Contacts), (SELECT Title FROM Notes) FROM Account];
        for(Account v : relatedList){
            Id accountId = v.Id;
            opportunitiesRelatedToAccountMap.put(accountId, v.Opportunities);
            contactsRelatedToAccountMap.put(accountId, v.Contacts);
            notesRelatedToAccountMap.put(accountId, v.Notes);
        }
    }
    
    
     public static List<AggregateResult> totalStudentOfEachBatch(){
        List<AggregateResult> studentList = [SELECT COUNT(Id),Batch__r.Name FROM Student_in_Batch__c GROUP BY Batch__r.Name];
        return studentList;
    }
    
    public static List<AggregateResult> sortedListOfStudentWithAvgRating(){
        List<AggregateResult> studentList = [SELECT Id,  AVG(Rating_out_of_10__c)  FROM Student__c GROUP BY Id ORDER BY AVG(Rating_out_of_10__c) ASC];
        return studentList;
    }

    public static List<Student__c> getStudentStartWithAA(){
        List<Student__c> studentList = [SELECT First_Name__c FROM Student__c WHERE First_Name__c LIKE '%aa%'];
        return studentList;
    }


    public static List<Batch__c> getBatchesWithCourseAndFaculty(){
        List<Batch__c> studentList = [SELECT Course__r.Name, Course__r.Faculty_Name__r.Name FROM Batch__c];
        return studentList;
    }

    public static List<AggregateResult> getDiscreteStudentsCount(){
        List<AggregateResult> studentList = [SELECT Count_Distinct(Student_Name__c) FROM Student__c];
        return studentList;
    }

    public static List<Student__c> getSortedStudentsOver25(){
        Date cutoffDate = System.today().addYears(-25);
        List<Student__c> result = [SELECT Name, Student_DOB__c FROM Student__c WHERE Student_DOB__c<=:cutoffDate ORDER BY Student_DOB__c ASC];
        return result;
    }

    public static List<Student_in_Batch__c> getRecordsWithNameTesting(){
        List<Student_in_Batch__c> studentInBatch = [SELECT 	Student__r.Student_Name__c, Batch__r.Course__r.Faculty_Name__r.Name FROM Student_in_Batch__c WHERE Student__r.Student_Name__c='Testing' AND Batch__r.Course__r.Faculty_Name__r.Name = 'Testing'];
        return studentInBatch;
    }

    public static List<Student__c> getStudentPresentInList(){
        List<String> names = new List<String>{'John','Jack','Will','David'};
        List<Student__c> studentList = [SELECT Student_Name__c  FROM Student__c WHERE Student_Name__c LIKE :names AND 	Registration_Date__c = THIS_QUARTER];
        return studentList;
    }

    public static List<String> getStudentCourseFacultyNameList(){
        List<Student_in_Batch__c> batchList = [SELECT Student__r.Student_Name__c, Batch__r.Course__r.Name, Batch__r.Course__r.Faculty_Name__r.Name FROM Student_in_Batch__c WHERE Batch__r.Course__r.Faculty_Name__r.Name LIKE 'Kri%' AND Batch__r.Course__r.Name != 'Php'];
        List<String> stringList = new List<String>();
        for(Student_in_Batch__c st : batchList){
            stringList.add(st.Student__r.Student_Name__c+'-'+st.Batch__r.Course__r.Name+'-'+st.Batch__r.Course__r.Faculty_Name__c);
        }
        return stringList;
    }

    public static List<Student__c> getStudentsBasedOnCourseAndFee(String courseName, Integer fee1, Integer fee2){
        List<Student__c> studentList = [SELECT Name FROM Student__c WHERE Course_Opted__c =:courseName AND Fee_Deposited__c >=:fee1 AND Fee_Deposited__c <=:fee2];
        return studentList;
    }
     
}