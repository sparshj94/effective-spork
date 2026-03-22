public with sharing class PerformanceDap2Handler {
    
    // after insert and update on performance
    public static void sendPerformanceReviewMail(List<Performance__c> newList){

        Set<Id> empId = new Set<Id>();
        for (Performance__c pf : newList) {
            if(pf.Employeee__c!=null){
                empId.add(pf.Employeee__c);
            }
        }
        List<Employeee__c> empList = [SELECT Id, Email__c FROM Employeee__c where id in :empId];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select Id from EmailTemplate where name = 'Performance Review'];
        // System.debug(emailTemplate[0].Id);
        String templateId = emailTemplate.Id !=null ? emailTemplate.Id : null;

        
            for (Employeee__c emp : empList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{emp.Email__c});
                mail.setTargetObjectId('003fj00000f0qF7AAI'); // change this id....
                mail.setWhatId(emp.Id);
                mail.setTemplateId(templateId);

                emails.add(mail);
            }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('succ');
        }
    }

    // after insert update on performance done
    public static void updateAvgRatingEmployee(List<Performance__c> newList, Map<Id, Performance__c> oldMap){
        /// remaining
        Set<Id> empIds = new Set<Id>();
        for (Performance__c pf : newList) {
            if(pf.Employeee__c!=null){
                empIds.add(pf.Employeee__c);
            }
        }
        List<Employeee__c> aggres = [SELECT Id, Name, (SELECT Id, Rating__c FROM Performances__r) FROM Employeee__c WHERE Id IN :empIds];
        Map<Id, Decimal> empAvgRatingMap = new Map<Id, Decimal>();
        List<Employeee__c> empUpdated = new List<Employeee__c>();
        for (Employeee__c emp : aggres) {
            if(!empAvgRatingMap.containsKey(emp.Id)){
                Decimal sum=0;
                for (Performance__c pf : emp.Performances__r) {
                    Decimal rating = pf.Rating__c !=null ? pf.Rating__c : 0;
                    sum+=rating;
                }
                if(emp.Performances__r.size()>0){
                    Decimal avgCount = sum/emp.Performances__r.size();
                    empAvgRatingMap.put(emp.Id, avgCount);
                }else{
                    empAvgRatingMap.put(emp.Id, 0);
                }
            }
            Employeee__c newEmp = new Employeee__c(Id = emp.Id, Average_Rating__c = empAvgRatingMap.get(emp.Id));
            empUpdated.add(newEmp);
        }
        Database.update(empUpdated);
    }

    // after update of employee/ after insert,update on performance ... ? done 
    public static void updateSalaryFields(List<Performance__c> newList){  

        Set<Id> empId = new Set<Id>();
        for (Performance__c pf : newList) {
            if(pf.Employeee__c!=null){
                empId.add(pf.Employeee__c);
            }
        }
        List<Employeee__c> employees = [SELECT Id, Name, CTC__c, Average_Rating__c FROM Employeee__c WHERE Id IN :empId];
        List<Employeee__c> employeUpdated = new List<Employeee__c>();
        for (Employeee__c emp : employees) {
            Integer Bonus = 0;
            if(emp.Average_Rating__c==5){
                Bonus = 20;
            } else if(emp.Average_Rating__c>4 && emp.Average_Rating__c<5){
                Bonus=15;
            } else if(emp.Average_Rating__c>3 && emp.Average_Rating__c<4){
                Bonus = 10;
            } else if(emp.Average_Rating__c>2 && emp.Average_Rating__c<3){
                Bonus = 5;  
            } else if(emp.Average_Rating__c<2){
                Bonus = 0;
            }
            System.debug(emp.CTC__c);
            
            // Decimal updatedCTC = emp.CTC__c !=null ? emp.CTC__c + ((Bonus/100)*emp.CTC__c) : 0;
            Decimal ctc = emp.CTC__c != null ? emp.CTC__c : 0;
            Decimal extraPay = ctc + ((Bonus/100.0)*ctc);
            System.debug(extraPay);
            Decimal MonthlyPay = (extraPay*0.7)/12;
            System.debug(MonthlyPay);
            Employeee__c newEmp = new Employeee__c(Id = emp.Id, CTC__c = extraPay, Bonus__c = Bonus, Monthly_Pay__c = MonthlyPay);
            employeUpdated.add(newEmp);
        }
        System.debug(employeUpdated);
        Database.update(employeUpdated);
    }

    // Before insert, update on performanbce done
    public static void validatePerformance(List<Performance__c> newList){
        for (Performance__c pf : newList) {
            System.debug(pf.Rating__c);
            if(pf.Rating__c<1 || pf.Rating__c>5){
                pf.addError('Rating can be in 1 to 5 Range');
            }
        }
    }

    // before update done 
    public static void validateEmployee(List<Employeee__c> newList, Map<Id,Employeee__c> oldMap){
        for (Employeee__c emp : newList) {
            Employeee__c oldEmp = oldMap.get(emp.Id);
            System.debug(emp.Company__c + ' ' + oldEmp.Company__c + ' ' + emp.Contract_Period__c);
            if(emp.Company__c != oldEmp.Company__c){
                if(emp.Contract_Period__c=='Yes'){
                    emp.addError('Cannot change company on contract period');
                }
            }
        }
    }

    // before insetry on emp done 
    public static void preFillEmployee(List<Employeee__c> newList){
        for (Employeee__c emp : newList) {
            emp.Contract_Period__c  = 'Yes';
            Decimal MonthlyPay = (emp.CTC__c*0.7)/12;
            emp.Monthly_Pay__c = MonthlyPay;
        }
        System.debug(newList);
    }

    public static void sendEmailToEmployeeAvgLessThanTwo(){
        List<Employeee__c> empList;
    }

    // after insert, update on employee done
    public static void updateAvgCompany(List<Employeee__c> newList){
        System.debug('compnay update');
        // update avg rating of company
        Set<Id> companyId = new Set<Id>();
        for (Employeee__c emp : newList) {
            if(emp.Company__c!=null){
                companyId.add(emp.Company__c);
            }
        }
        List<Company__c> aggres = [SELECT Id, Name, (SELECT Id, Average_Rating__c FROM Employeees__r) FROM Company__c WHERE Id IN :companyId];
        Map<Id, Decimal> companyAvgRatingMap = new Map<Id, Decimal>();
        List<Company__c> companyUpdated = new List<Company__c>();
        for (Company__c emp : aggres) {
            if(!companyAvgRatingMap.containsKey(emp.Id)){
                Decimal sum=0;
                for (Employeee__c pf : emp.Employeees__r) {
                    Decimal rating = pf.Average_Rating__c !=null ? pf.Average_Rating__c : 0;
                    sum+=rating;
                }
                if(emp.Employeees__r.size()>0){
                    Decimal avgCount = sum/emp.Employeees__r.size();
                    companyAvgRatingMap.put(emp.Id, avgCount);
                }else{
                    companyAvgRatingMap.put(emp.Id, 0);
                }
            }
            Company__c newEmp = new Company__c(Id = emp.Id, Average_Rating__c = companyAvgRatingMap.get(emp.Id));
            companyUpdated.add(newEmp);
        }
        Database.update(companyUpdated);
        System.debug(companyUpdated);
    }


    public static void sendMailToManagers() {

        List<Employeee__c> empList = [
            SELECT Id, Email__c 
            FROM Employeee__c 
            WHERE Role__c = 'Manager' AND Email__c != null
        ];

        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE Name = 'Company Performance Mail' LIMIT 1];

        Id templateId = templates[0].Id;

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Employeee__c emp : empList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {emp.Email__c});
            mail.setWhatId(emp.Id);
            mail.setTemplateId(templateId);
            mail.setTargetObjectId('003fj00000czfy2AAA');
            mails.add(mail);
        }

        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }


    public static void sendLowRatingEmployees() {

        List<Employeee__c> empList = [
            SELECT Id, Email__c 
            FROM Employeee__c 
            WHERE Average_Rating__c < 2 AND Email__c != null
        ];
        if (empList.size()<1) {
            System.debug('no one is less than 2');
        }

        List<EmailTemplate> templates = [ SELECT Id FROM EmailTemplate WHERE Name = 'Low Performance Mail' LIMIT 1 ];

        Id templateId = templates[0].Id;

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for (Employeee__c emp : empList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {emp.Email__c});
            mail.setWhatId(emp.Id);
            mail.setTemplateId(templateId);
            mail.setTargetObjectId('003fj00000fxofXAAQ');
            mails.add(mail);
        }

        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }


}