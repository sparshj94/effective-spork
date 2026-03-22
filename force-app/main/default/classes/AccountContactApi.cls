@RestResource(urlMapping = '/createAccountAndContact')
global class AccountContactApi {
	
    @HttpPost
    global static String myMethod(){
        RestRequest req = RestContext.request;
        String str = req.requestBody.toString();
        Map<String,Object> mapObj = (Map<String,Object>)json.deserializeUntyped(str);
        System.debug(mapObj);
        String name = String.valueOf(mapObj.get('Name'));
        String lastName = String.valueOf(mapObj.get('LastName'));
        Account acc = new Account(Name = name);
        insert acc;
        Id accId = acc.Id;
        System.debug(accId);
        Contact cn = new Contact(LastName = lastName, AccountId = accId);
        insert cn;
        return 'Acc and Contact inseted successfully';
    }
    @HttpGet
    global static String mmc(){
        return 'Test';
    }
    
}