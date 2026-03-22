@RestResource(urlMapping='/ld')
global with sharing class PracticePaper3 {
    
    @HttpGet
    global static void km(){
        System.debug('Hello');
    }
    @HttpPost
    global static void mm(){
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        LeadWrapper wrapperObj = (LeadWrapper)JSON.deserialize(reqBody,LeadWrapper.class);
        List<LeadWrapper.LeadData> leadList = wrapperObj.leads;
        LeadBatch bc = new LeadBatch(leadList);
        System.debug('Batch start point');
        Id jId  = Database.executeBatch(bc);
        System.debug('Batch ended');
        System.debug(jId);
    }
}