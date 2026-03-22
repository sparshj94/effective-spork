public class SmsSend {
    @future(callout=true)
    public static void send(String name){
        String stName = 'Hello '+name;
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint('https://api.twilio.com/2010-04-01/Accounts/axs/Messages.json');
    	req.setMethod('POST');
    
    	// Headers
    	Blob b = Blob.valueOf('Abc');
    	String enc = EncodingUtil.base64Encode(b);
    	req.setHeader('Authorization', 'Basic '+enc);
    
    	//Body
    	String body = 'From='+EncodingUtil.urlEncode('+15075797754','UTF-8')+'&To='+EncodingUtil.urlEncode('+919024219970','UTF-8')+'&Body='+EncodingUtil.urlEncode(stName,'UTF-8');
    	req.setBody(body);
    
    	// Http req
    	Http http = new Http();
    	HttpResponse res = new HttpResponse();
    	res = http.send(req);
    }
}