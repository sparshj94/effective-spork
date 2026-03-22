public class SmsSend {
    @future(callout=true)
    public static void send(String name){
        String stName = 'Hello '+name;
    	HttpRequest req = new HttpRequest();
    	
    	//Body
    	String body = 'From='+EncodingUtil.urlEncode('+15075797754','UTF-8')+'&To='+EncodingUtil.urlEncode('+919024219970','UTF-8')+'&Body='+EncodingUtil.urlEncode(stName,'UTF-8');
    	req.setBody(body);
    
    	// Http req
    	Http http = new Http();
    	HttpResponse res = new HttpResponse();
    	res = http.send(req);
    }
}