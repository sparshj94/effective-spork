@RestResource(urlMapping = '/convertLead')
global with sharing class LeadConvertApi_Q1b {

    public class RequestWrapper {
        public String LeadName;
        public Boolean Create_opp;
    }
    
    @HttpPost
    global static String convertLeadApi(){
        RestRequest req = RestContext.request;
        String stm = req.requestBody.toString();
        System.debug(stm);
        List<RequestWrapper> input = (List<RequestWrapper>)JSON.deserialize(stm,List<RequestWrapper>.class);
        List<String> leadNames = new List<String>();
        Map<String,Boolean> mpp = new Map<String,Boolean>();
        for(RequestWrapper rp : input){
           leadNames.add(rp.LeadName);
           mpp.put(rp.LeadName, rp.Create_opp);
        }
        System.debug(mpp);
        System.debug(leadNames);
        
        // Fetch Leads from db first
        // then cnvert each lead and make acc and contact
        // if bool is true then only make opp for that
        // return array of string with ids

        List<Lead> leadList = [SELECT Id, Name FROM Lead WHERE Name IN :leadNames];
        System.debug(leadList);
        List<Database.LeadConvert> leadToBeConverted = new List<Database.LeadConvert>();
        for(Lead l : leadList){
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.id);
            lc.setConvertedStatus('Closed - Converted');
            if(mpp.containsKey(l.Name)){
                if(mpp.get(l.Name)==false){
                    lc.setDoNotCreateOpportunity(true);
                }
            }
            leadToBeConverted.add(lc);
        }
        System.debug(leadToBeConverted);
        List<String> convertedLeadIds = new List<String>();
        if(!leadToBeConverted.isEmpty()){
            Database.LeadConvertResult[] res = Database.convertLead(leadToBeConverted,false);
            for (Database.LeadConvertResult r : res) {
                if(r.isSuccess()){
                    System.debug(r.getLeadId());
                    convertedLeadIds.add(r.getLeadId());
                }
            }
        }
        System.debug(convertedLeadIds);
        String listString = JSON.serialize(convertedLeadIds);
        System.debug(listString);
        String result = 'These leads are converted: '+listString;
        System.debug(result);   
        return result;
    }
}