public class MapPracticeAssignment {
    public static Map<String, Contact> getContactMapByEmail(){
        List<Contact> contacts = [SELECT FirstName, LastName, Email FROM Contact];
        Map<String, Contact> mpp  = new Map<String, Contact>();

        for(Contact cnt : contacts){
            mpp.put(cnt.Email, cnt);
        }
        for(String email : mpp.keySet()){
            Contact cn = mpp.get(email);
            System.debug('Email '+ email + 'Value '+cn );
        }
        return mpp;
    }
    
    public static Map<String, List<Account>> getAccountMapByIndustry() {
        Map<String, List<Account>> accountMap = new Map<String, List<Account>>();
        List<Account> accountList = [SELECT Name, NumberOfEmployees, Industry FROM Account];

        for(Account acc : accountList){
            String industry = acc.Industry;
            if(!accountMap.containsKey(industry)){
                accountMap.put(industry, new List<Account>());
            }
            accountMap.get(industry).add(acc);
        }
        for(String st : accountMap.keySet()){
            System.debug(st + ' ' + accountMap.get(st));
        }
        return accountMap;
    }
	
    public static Map<String, List<Contact>> groupContactsByFirstLetter() {
        List<Contact> contactList = [SELECT FirstName, LastName, Email FROM Contact ORDER BY FirstName];
        Map<String, List<Contact>> contactMap = new Map<String,List<Contact>>();
        //  Loop through list
        // Extract first char of name
        // check if char is in map or not - if it is then add contact as value, else add key 

        for(Contact cn : contactList){
            String firstChar = cn.FirstName.substring(0, 1).toUpperCase();

            if(!contactMap.containsKey(firstChar)){
                contactMap.put(firstChar, new List<Contact>());
            }
            contactMap.get(firstChar).add(cn);
        }
        for(String letter : contactMap.keySet()){
            System.debug(letter + ' ' + contactMap.get(letter));
        }
        return contactMap;
    }
       
    public static Map<String, Decimal> calculateStageAmounts() {
        List<AggregateResult> opportunityList = [SELECT StageName, SUM(Amount) totalAmount FROM Opportunity GROUP BY StageName];
        Map<String, Decimal> stageMap= new Map<String, Decimal>();
        for(AggregateResult agr : opportunityList){
            String stageName = (String)agr.get('StageName');
            Decimal amount = (Decimal)agr.get('totalAmount');
            if(stageName!=null && amount!=null){
                stageMap.put(stageName, amount);
            }
            System.debug(agr);
        }
        for(String st : stageMap.keySet()){
            System.debug(st + ' ' + stageMap.get(st));
        }
        return stageMap;
    }

	public static Map<String, List<Opportunity>> groupOpportunitiesByLeadSourceAndStage() {
        Map<String, List<Opportunity>> oppMap = new Map<String, List<Opportunity>>();
        List<Opportunity> oppList = [SELECT LeadSource, StageName,Name FROM Opportunity];
        for(Opportunity op : oppList){
            String stageName = op.StageName;
            String leadSource = op.LeadSource;
            String mapKey = leadSource+'-'+stageName;
            if(!oppMap.containsKey(mapKey)){
                oppMap.put(mapKey, new List<Opportunity>());
            }
            oppMap.get(mapKey).add(op);
        }

        for(String st : oppMap.keySet()){
            System.debug(st + ' ' + oppMap.get(st));
        }
        return oppMap;
    }
	
    public static Map<String, List<Lead>> groupLeadsByStatus () {
        Map<String, List<Lead>> leadMap = new  Map<String, List<Lead>>();
        List<Lead> leadList = [SELECT FirstName, LastName, Email,Status FROM Lead];
        for(Lead lead : leadList){
            String status = lead.Status;
            if(!leadMap.containsKey(status)){
                leadMap.put(status, new List<Lead>());
            }
            leadMap.get(status).add(lead);
        }
        for(String st : leadMap.keySet()){
            System.debug(st + ' ' + leadMap.get(st));
        }
        return leadMap;
    }
    
    
    public static Map<String, List<Bank_Account__c>> getBankAccountsByRecordType(){
        // online - []
        // offline -[]
        Map<String, List<Bank_Account__c>> bankMap = new Map<String, List<Bank_Account__c>>();
        List<Bank_Account__c> bankList = [SELECT Account_Holder_Name__c, Name, Account_Type__c, Branch__c, Current_Balance__c, RecordTypeId,RecordType.Name FROM Bank_Account__c];

        for (Bank_Account__c bankAccount : bankList) {
            String recordTypeName = bankAccount.RecordType.Name;
            if(!bankMap.containsKey(recordTypeName)){
                bankMap.put(recordTypeName, new List<Bank_Account__c>());
            }
            bankMap.get(recordTypeName).add(bankAccount);
        }
        for (String name : bankMap.keySet()) {
            System.debug(name + ' ' + bankMap.get(name));
        }
        return bankMap;
    }
    
    
 	public static Map<String, List<Case>> getCasesByPriority() {
        Map<String, List<Case>> caseMap = new Map<String, List<Case>>();
        List<Case> caseList = [SELECT ContactEmail, Origin,Priority, Account.Name, Contact.FirstName FROM Case];
        for (Case variable : caseList) {
            String priority = variable.Priority;
            if(!caseMap.containsKey(priority)){
                caseMap.put(priority, new List<Case>());
            }
            caseMap.get(priority).add(variable);
        }
        for(String var : caseMap.keySet()){
            System.debug(var + ' ' + caseMap.get(var));
        }
        return caseMap;
    }   
    
 	
    public static Map<String, Integer> buildStudentMap() {
        Map<String, Integer> studentMapp = new Map<String, Integer>();
        List<AggregateResult> studentList = [SELECT CreatedBy.FirstName name, COUNT(Id) studentCount FROM Student__c GROUP BY CreatedBy.FirstName];
        for (AggregateResult variable : studentList) {
            String firstName = (String)variable.get('name');
            Integer count = (Integer)variable.get('studentCount');
            studentMapp.put(firstName, count);
        }
        for(String st : studentMapp.keySet()){
            System.debug(st + ' ' + studentMapp.get(st));
        }
        return studentMapp;
    }


	public static Map<String, List<Account>> buildAccountMap() {
        Map<String, List<Account>> accountMap  = new  Map<String, List<Account>>();
        List<Account> accountList = [SELECT Name, AnnualRevenue, BillingCountry FROM Account];
        for (Account variable : accountList) {
            String country = (String)variable.get('BillingCountry');
            if(country!=null){
                if(!accountMap.containsKey(country)){
                    accountMap.put(country, new List<Account>());
                }
                accountMap.get(country).add(variable);
            }
        }

        for (String country : accountMap.keySet()) {
            System.debug(country + '  ' + accountMap.get(country));
        }
        return accountMap;
    }
    
    
    
    
    public static Map<String, List<Contact>> getContactsByMailingState() {
        Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
        List<Contact> contactList = [SELECT FirstName, MailingState FROM Contact];

        for (Contact variable : contactList) {
            String state = (String)variable.get('MailingState');

            if(state!=null){
                if(!contactMap.containsKey(state)){
                    contactMap.put(state, new List<Contact>());
                }
                contactMap.get(state).add(variable);
            }
        }
        for(String st : contactMap.keySet()){
            System.debug(st + ' ' + contactMap.get(st));
        }
        return contactMap;
    }

	
    public static Map<Id, List<Faculty__c>> getFacultyByOwner() {
        Map<Id, List<Faculty__c>> facultyMap = new Map<Id, List<Faculty__c>>();
        List<Faculty__c> facultyList = [SELECT OwnerId, Name, Faculty_Email__c, Total_Number_of_Course__c FROM Faculty__c];
        
        for(Faculty__c fac : facultyList){
            Id id = fac.OwnerId;
            if( id!=null){
                if(!facultyMap.containsKey(id)){
                    facultyMap.put(id, new List<Faculty__c>());
                }
                facultyMap.get(id).add(fac);
            }
        }
        for (String str : facultyMap.keySet()) {
            System.debug(str + ' ' + facultyMap.get(str));
        }
        return facultyMap;
    }
}