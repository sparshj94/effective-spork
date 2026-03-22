@RestResource(urlmapping='/in')
global with sharing class MagentaController {
   
    
    global class ResponseWrapper{
        String SuccessCount;
        String FailedCount;
        List<Record> Records;
    }
    public class Record{
        String record;
        String error;
    }
    
    public class RequestWrapper {
        public String Name;
        public String Email;
        public List<Salaries> Salaries;   
    }
    public class Salaries{
        public String Amount;
        public String Month;
        public Integer external_id_Temp;
    }
    //00Dfj00000J0ph7!AQEAQHyjVldpg.1yXZ_WsXO777KhH5hBRM62XBqg0VFhmtmGkii7PFbQENlmHv6FrkIUqOdvRNP4O2vliZ9jvNbKf9EJZktR
    @HttpPost   
    global static ResponseWrapper getAndInsert(){
        Integer successCount = 0;
        Integer failedCounts = 0;
        ResponseWrapper responseWp = new ResponseWrapper();
        responseWp.Records = new List<Record>();
        RestRequest req = RestContext.request;
        String str = req.requestBody.toString();
        List<RequestWrapper> reqList = (List<RequestWrapper>)JSON.deserialize(str.replaceAll('__c', '_Temp'), List<RequestWrapper>.class);
        Map<String, RequestWrapper> emailContactMap = new Map<String, RequestWrapper>();

        List<String> emailIds = new List<String>();
        
        for (RequestWrapper variable : reqList) {
            String email = variable.Email;
            emailIds.add(email);
            emailContactMap.put(email, variable);
        }

        List<Contact> existingContacts = [SELECT Id, LastName, Email FROM Contact WHERE Email IN :emailIds];
        List<Id> contactIds = new List<Id>();
        Map<String,Contact> existingContactMap = new Map<String,Contact>();
        for(Contact cn: existingContacts){
            contactIds.add(cn.Id);
            existingContactMap.put(cn.Email, cn);
        }

        List<Tax_Return__c> existingTaxReturns = [SELECT Id, Name, external_id__c, Amount__c, Contact__c, Month__c  FROM Tax_Return__c WHERE Contact__c IN :contactIds];
        Map<String, Tax_Return__c> existingTaxMap = new Map<String,Tax_Return__c>();
        for (Tax_Return__c tr : existingTaxReturns) {
            existingTaxMap.put(tr.external_id__c, tr);
        }

        List<Contact> contactsToInsert = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();

        List<Tax_Return__c> taxToInsert = new List<Tax_Return__c>();
        List<Tax_Return__c> taxToUpdate = new List<Tax_Return__c>();


        for(String em : emailContactMap.keySet()){
            if(existingContactMap.containsKey(em)){
                // update contact
                Boolean isToUpdate = false;
                RequestWrapper rw = emailContactMap.get(em);
                Contact cn = existingContactMap.get(em);
                if(cn.LastName!=rw.Name){
                    cn.LastName = rw.Name;
                    isToUpdate = true;
                }
                if(cn.Email!=rw.Email){
                    cn.Email = rw.Email;
                    isToUpdate = true;
                }
                if(isToUpdate){
                    contactsToUpdate.add(cn);
                }
                for(Salaries sl : emailContactMap.get(em).Salaries){
                    if(existingTaxMap.containsKey(String.valueOf(sl.external_id_Temp))){
                        // update tax return only
                        Tax_Return__c tr = existingTaxMap.get(String.valueOf(sl.external_id_Temp));
                        tr.Amount__c = Decimal.valueOf(sl.Amount);
                        tr.Month__c = sl.Month;
                        taxToUpdate.add(tr);
                    } else{
                        //insert tax return
                        Tax_Return__c tr = new Tax_Return__c();
                        tr.Contact__c = cn.Id;
                        tr.Amount__c = Decimal.valueOf(sl.Amount);
                        tr.Month__c = sl.Month;
                        tr.external_id__c = String.valueOf(sl.external_id_Temp);
                        taxToInsert.add(tr);
                    }
                }
            } else{
                // insert new contact and tax returns
                RequestWrapper rw = emailContactMap.get(em);
                Contact cn = new Contact();
                cn.LastName = rw.Name;
                cn.Email = rw.Email;
                contactsToInsert.add(cn);
            }
        }
        if(!contactsToInsert.isEmpty()){
            Database.SaveResult[] sv = Database.insert(contactsToInsert, false);
            for(Database.SaveResult sr : sv){
                if(sr.isSuccess()){
                    successCount++;
                } else {
                    failedCounts++;
                    for (Database.Error err : sr.getErrors()) {
                        String field = String.join(err.getFields(),',');
                        String msg = err.getMessage();
                        Record rc = new Record();
                        rc.record = field;
                        rc.error = msg;
                        responseWp.Records.add(rc);
                    }
                }
            }
            responseWp.SuccessCount = String.valueOf(successCount);
            responseWp.FailedCount = String.valueOf(failedCounts);
        }
        for(Contact cn : contactsToInsert){
            RequestWrapper rw = emailContactMap.get(cn.Email);
            for(Salaries sl :rw.Salaries){
                Tax_Return__c tr = new Tax_Return__c();
                tr.Contact__c = cn.Id;
                tr.Amount__c = Decimal.valueOf(sl.Amount);
                tr.Month__c = sl.Month;
                tr.external_id__c = String.valueOf(sl.external_id_Temp);
                taxToInsert.add(tr);
            }
        }
        if(!contactsToUpdate.isEmpty()){
            Database.SaveResult[] sv = Database.update(contactsToUpdate, false);
            for(Database.SaveResult sr : sv){
                if(sr.isSuccess()){
                    successCount++;
                } else {
                    failedCounts++;
                    for (Database.Error err : sr.getErrors()) {
                        String field = String.join(err.getFields(),',');
                        String msg = err.getMessage();
                        Record rc = new Record();
                        rc.record = field;
                        rc.error = msg;
                        responseWp.Records.add(rc);
                    }
                }
            }
            responseWp.SuccessCount = String.valueOf(successCount);
            responseWp.FailedCount = String.valueOf(failedCounts);
        }
        if(!taxToInsert.isEmpty()){
            Database.SaveResult[] sv = Database.insert(taxToInsert, false);
            for(Database.SaveResult sr : sv){
                if(sr.isSuccess()){
                    successCount++;
                } else {
                    failedCounts++;
                    for (Database.Error err : sr.getErrors()) {
                        String field = String.join(err.getFields(),',');
                        String msg = err.getMessage();
                        Record rc = new Record();
                        rc.record = field;
                        rc.error = msg;
                        responseWp.Records.add(rc);
                    }
                }
            }
            responseWp.SuccessCount = String.valueOf(successCount);
            responseWp.FailedCount = String.valueOf(failedCounts);
        }
        if(!taxToUpdate.isEmpty()){
            Database.SaveResult[] sv = Database.update(taxToUpdate, false);
            for(Database.SaveResult sr : sv){
                if(sr.isSuccess()){
                    successCount++;
                } else {
                    failedCounts++;
                    for (Database.Error err : sr.getErrors()) {
                        String field = String.join(err.getFields(),',');
                        String msg = err.getMessage();
                        Record rc = new Record();
                        rc.record = field;
                        rc.error = msg;
                        responseWp.Records.add(rc);
                    }
                }
            }
            responseWp.SuccessCount = String.valueOf(successCount);
            responseWp.FailedCount = String.valueOf(failedCounts);
        }
        return responseWp;
    }
}