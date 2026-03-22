public with sharing class BulkPhoneEnquiryLeadsConvertion implements Database.Batchable<SObject>{
    public static Integer totalNoOfLeads;
    public static Integer totalFailedLeads;
    public static Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([SELECT Id FROM Lead WHERE LeadSource = 'Phone Inquiry' AND IsConverted = FALSE]);
    }

    public static void execute(Database.BatchableContext bc, List<Lead> leadList){
        List<Database.LeadConvert> convertedLead = new List<Database.LeadConvert>();
        totalNoOfLeads = leadList.size();
        for (Lead l : leadList) {
            Database.LeadConvert lc  = new Database.LeadConvert();
            lc.setLeadId(l.Id);
            lc.setConvertedStatus('Closed - Converted');
            lc.setDoNotCreateOpportunity(true);
            lc.setOpportunityName('Lead Conversion');
            convertedLead.add(lc);
        }

        if(!convertedLead.isEmpty()){
            List<Database.LeadConvertResult> result = Database.convertLead(convertedLead);
            
            for (Database.LeadConvertResult lr : result) {
                if(!lr.isSuccess()){
                    totalFailedLeads++;
                    System.debug('Error while Lead Conversion');
                    System.debug(lr.getErrors());
                }
            }
        }
    }

    public static void finish(Database.BatchableContext bc ){
        System.debug('Conversion Executed Successfuly');
        Id jobId = bc.getJobId();
        AsyncApexJob jobs = [SELECT Id,TotalJobItems, JobItemsProcessed, Status, NumberOfErrors FROM AsyncApexJob WHERE id =:jobId ];
        System.debug(jobs);
        // Email
         Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        List<String> mailList = new List<String>{'sparshjain@cyntexa.com'};
         emailToSend.toaddresses = mailList;
         emailToSend.setSubject('Lead Conversion Job Completed');
         emailToSend.setPlainTextBody('Total No of Leads: ' + totalNoOfLeads + '\n' + 'Failed Leads: ' + totalFailedLeads + 'Batch Job Ids: ' + bc.getJobId());
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailToSend});
    }
}