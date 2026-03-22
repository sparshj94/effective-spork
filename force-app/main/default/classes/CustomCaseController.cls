@RestResource(urlmapping='/create/case')
global with sharing class CustomCaseController {
    

    class ReqWrapper{
        String PreviousCase;
        String Subject;
        String UserName;
        String UserEmail;
        String Description;
        String TrackerModel;
        List <String> TroubleshootingStepsTaken;
        String SyncIssue;
    }

    @HttpPost
    global static void createCustomCase(){
        RestRequest req = RestContext.request;
        String str = req.requestBody.toString();
        ReqWrapper reqWrapper = (ReqWrapper)JSON.deserialize(str, ReqWrapper.class);
        System.debug(reqWrapper);
        String multiPickVals = format(reqWrapper.TroubleshootingStepsTaken);
        System.debug('Str val '+multiPickVals);
        List<Tracker_Model__c> trackerModel = [SELECT Id, Name FROM Tracker_Model__c WHERE Name = :reqWrapper.TrackerModel LIMIT 1];
        System.debug('MODAL ' + trackerModel);
        
        List<Custom_Case__c> previousCase = [SELECT Id, Name FROM Custom_Case__c WHERE Name = :reqWrapper.PreviousCase LIMIT 1];
        System.debug('prev case ' + previousCase);
        List<Custom_Case__c> caseToInsert = new List<Custom_Case__c>();
        if(previousCase.size()>=1){
            if(previousCase!=null && previousCase[0].Id!=null){
                // only if existing case is there;
                Custom_Case__c  newCase = new Custom_Case__c();
                newCase.Previous_Case__c = previousCase[0].Id;
                newCase.Subject__c = reqWrapper.Subject;
                newCase.User_Email__c = reqWrapper.UserEmail;
                newCase.User_Name__c =  reqWrapper.UserName;
                newCase.Description__c = reqWrapper.Description;
                newCase.Tracker_Model__c = trackerModel[0].Id;
                newCase.Sync_Issue__c = reqWrapper.SyncIssue;
                newCase.Troubleshooting_Steps_Taken__c = multiPickVals;
                caseToInsert.add(newCase);
            }
        }
        else {
            // new case 1st time
            Custom_Case__c  newCase = new Custom_Case__c();
            newCase.Subject__c = reqWrapper.Subject;
            newCase.User_Email__c = reqWrapper.UserEmail;
            newCase.User_Name__c =  reqWrapper.UserName;
            newCase.Description__c = reqWrapper.Description;
            newCase.Tracker_Model__c = trackerModel[0].Id;
            newCase.Sync_Issue__c = reqWrapper.SyncIssue;
            newCase.Troubleshooting_Steps_Taken__c = multiPickVals;
            caseToInsert.add(newCase);
        }
        System.debug(caseToInsert);

        Database.SaveResult[] sr = Database.insert(caseToInsert);
        for (Database.SaveResult sv : sr) {
            if(sv.isSuccess()){
                System.debug('inserted successfully');
                sendEmail(reqWrapper.UserEmail,caseToInsert[0].Id);
            }
        }
    }

    


    public static String format(List<String> values) {
        if (values == null) return null;
        return String.join(values, ';');
    }
    public static void sendEmail(String email,Id caseId){
        // 	Custom New Case
        EmailTemplate emailTemplate = [Select Id from EmailTemplate where name = 'Custom New Case'];
        // System.debug(emailTemplate[0].Id);
        String templateId = emailTemplate.Id !=null ? emailTemplate.Id : null;
        System.debug(templateId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {email};
        mail.setToAddresses(toAddresses);
        mail.setTargetObjectId('003fj00000ilT6rAAE');
        mail.setWhatId(caseId);
        mail.setTemplateId(templateId);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
    }
}