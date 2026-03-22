public with sharing class StripePaymentService {
    
	@future(callout=true)
    public static void makePayment(List<Id> oppId){
        // fetch opp from db
        // make links for each opp
        //send email

        List<Opportunity> oppList = [SELECT Id, Name, Amount, Email__c, (SELECT Id FROM OpportunityLineItems ) FROM Opportunity WHERE Id IN :oppId];
        System.debug(oppList);
        stripe__c config = stripe__c.getOrgDefaults();
        String apiKey = config.api_key__c;
        List<Opportunity> updatedOpp = new List<Opportunity>();

        for(Opportunity opp : oppList){
            if(opp.OpportunityLineItems.size()==0){
                continue;
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.stripe.com/v1/payment_links');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer '+apiKey);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            Integer amount = Integer.valueOf(opp.Amount*100);

            String body = 'line_items[0][price_data][currency]=inr' + 
                '&line_items[0][quantity]=1'+
                '&line_items[0][price_data][product_data][name]='+EncodingUtil.urlEncode(opp.Name,'UTF-8')+
                '&line_items[0][price_data][unit_amount]='+amount;

            req.setBody(body);
            System.debug(body);
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(res);
            if(res.getStatusCode()==200){
                Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                System.debug(result);
                String link = (String)result.get('url');
                opp.payment_link__c = link;
                updatedOpp.add(opp);
                sendEmail(opp.Email__c, link);
                System.debug(result);
            }
        }
        if(!updatedOpp.isEmpty()){
            Database.update(updatedOpp,false);
        }
    }
    public static void sendEmail(String email, String link){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{email});
        mail.setSubject('Complete payment');
        System.debug('LINK ' + link);
        //mail.setPlainTextBody('Please complete payment using this link: \n ' + link);
        String htmlBody =
        '<html><body>' +
        'Hi,<br/><br/>' +
        'Please complete your payment by clicking below:<br/><br/>' +
        '<a href="' + link + '">Pay Now</a>' +
        '<br/><br/>Thank you.' +
        '</body></html>';

    	mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}