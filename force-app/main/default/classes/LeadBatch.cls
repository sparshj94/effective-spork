public with sharing class LeadBatch implements Database.Batchable<LeadWrapper.LeadData>, Database.Stateful{
    
    Map<Id,List<Lead>>  agentAssignedLeads = new Map<Id,List<Lead>>();
    List<LeadWrapper.LeadData> inputData;

    Set<String> processedEmails = new Set<String>();
    Set<String> processedPhones = new Set<String>();


    public LeadBatch(List<LeadWrapper.LeadData> leads){
        this.inputData = leads;
    }
	
    
    public Iterable<LeadWrapper.LeadData> start(Database.BatchableContext bc){
        System.debug('Batch start method');
        return inputData;
    }
    public  void execute(Database.BatchableContext bc, List<LeadWrapper.LeadData> leadList){
        List<Lead> leadToInserted = new List<Lead>();
		System.debug('Batch In execute method');
        for (LeadWrapper.LeadData ll : leadList) {
            String email = ll.Email != null ? ll.Email.trim().toLowerCase() : null;
            String phone = ll.Phone != null ? ll.Phone.trim() : null;
            
            Boolean isDuplicate = false;
            if(email!=null && processedEmails.contains(email)){
                isDuplicate = true;
            }
            if(phone!=null && processedPhones.contains(phone)){
                isDuplicate = true;
            }

            if(!isDuplicate){
                Lead newLead = new Lead();
                newLead.FirstName = ll.FirstName;
                newLead.LastName = ll.LastName;
                newLead.Company = ll.Company;
                newLead.Email = ll.Email;
                newLead.Phone = ll.Phone;
                newLead.Status = ll.Status;
                newLead.LeadSource = ll.LeadSource;
                newLead.Industry = ll.Industry;
                newLead.Description = ll.Description;   
                leadToInserted.add(newLead);
                if(phone!=null) {processedPhones.add(phone);}
                if(email!=null){processedEmails.add(email);}
            }
        }

        if (leadToInserted.isEmpty()) return;
        assignOwners(leadToInserted);
        Database.insert(leadToInserted,false);
        for (Lead ld : leadToInserted) {
            if(String.valueOf(ld.OwnerId).startsWith('005')){
                if(!agentAssignedLeads.containsKey(ld.OwnerId)){
                    agentAssignedLeads.put(ld.OwnerId,new List<Lead>());
                }
                agentAssignedLeads.get(ld.OwnerId).add(ld);
            }
        }
    }


    public void finish(Database.BatchableContext bc){
        System.debug('Batch finish  method');
        if(agentAssignedLeads.isEmpty()) return;

        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Email, Name FROM User WHERE Id IN :agentAssignedLeads.keySet()]);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id uid : agentAssignedLeads.keySet()){

            User u = userMap.get(uid);
            List<Lead> leads = agentAssignedLeads.get(uid);

            String csv = generateCSV(leads);

            Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
            file.setFileName('AssignedLeads.csv');
            file.setBody(Blob.valueOf(csv));
            file.setContentType('text/csv');

            Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[]{u.Email});
            mail.setSubject('New Leads Assigned - ' + leads.size());
            mail.setPlainTextBody('Dear ' + u.Name +',\n\nYou have ' + leads.size() +
                                  ' new leads assigned.\n\n Find the below attachment for you reference.'
         	);

            mail.setFileAttachments(
                new Messaging.EmailFileAttachment[]{file}
            );

            emails.add(mail);
        }

        if (!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
        System.debug('Batch finish end');
    }

    public static String generateCSV(List<Lead> leads){

        String csv = 'FirstName,LastName,Company,Email,Phone\n';

        for (Lead l : leads){
            csv += '"' + l.FirstName + '","' +
            l.LastName + '","' +
            l.Company + '","' +
            l.Email + '","' +
            l.Phone + '"\n';
        }

        return csv;
    }



    public static void assignOwners(List<Lead> leadsToInsert){
        List<User> userList = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'Lead Agents'];
        System.debug(userList);
        Map<Id,Integer> agentLeadCount = new Map<Id,Integer>();
        
        List<String> status = new List<String>{'Closed - Not Converted','Closed - Converted'};
        List<AggregateResult> leadCountList = [SELECT OwnerId, COUNT(Id) total FROM Lead WHERE OwnerId IN :userList AND Status NOT IN :status GROUP BY OwnerId];
        for (AggregateResult agg : leadCountList) {
            Id id = (Id)agg.get('OwnerId');
            Integer count = (Integer)agg.get('total');
            System.debug(id + ' '+count);
            agentLeadCount.put(id,count);
        }
        for (User u : userList) {
            if (!agentLeadCount.containsKey(u.Id)) {
                agentLeadCount.put(u.Id, 0);
            }
        }
        System.debug(agentLeadCount);
        // get queue
        Group leadQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Lead Assignment Queue' LIMIT 1];
        Integer maxCapacity = 2;
        Integer agentIndex = 0;
        Integer totalAgents = userList.size();

        for (Lead ld : leadsToInsert) {

            Boolean assigned = false;

            for (Integer i = 0; i < totalAgents; i++) {

                User currentAgent = userList[agentIndex];
                Integer currentCount = agentLeadCount.get(currentAgent.Id);

                if (currentCount < maxCapacity) {
                    ld.OwnerId = currentAgent.Id;
                    agentLeadCount.put(currentAgent.Id, currentCount + 1);
                    assigned = true; 
                    agentIndex =  Math.mod((agentIndex + 1),totalAgents);
                    break;
                }
                agentIndex = Math.mod((agentIndex + 1),totalAgents);
            }

            if (!assigned) {
                ld.OwnerId = leadQueue.Id;
            }
        }
    }
}