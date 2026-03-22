@RestResource(urlMapping = '/getAccCont')
global with sharing class AccAndContAPI {
    
    public class ConWrapper{
        public Map<String,ContactClass> Contacts;
        public String Name;
        public Integer NumberOfEmployees;
    }
    public class ContactClass{
        	public String Name;
        	public ContactClass(Contact c){
            	this.Name = c.Name;
        	}
    }
    
    @HttpPost
    global static String getAccountAndContact(){
        RestRequest req = RestContext.request;
        String str = req.requestBody.toString();
        Map<String,Object> mapObj = (Map<String,Object>)json.deserializeUntyped(str);
        String name = String.valueOf(mapObj.get('Name'));
        System.debug(name);
        List<Account> acc = [SELECT Name, NumberOfEmployees FROM Account WHERE Name = :name LIMIT 1];
        System.debug(acc);
        if(acc.isEmpty()){
            return 'No Account Exists with name Geetika';
        }
        List<Contact> contactList = [SELECT Name FROM Contact WHERE Account.Id = :acc[0].Id];
        System.debug(contactList);
        ConWrapper cn = new ConWrapper();
        Map<String,ContactClass> mpp = new Map<String,ContactClass>();
		
        Integer i =1;
        for(Contact cnn : contactList){
            mpp.put('Contact '+i, new ContactClass(cnn));
            i++;
        }
        cn.Contacts = mpp;
        cn.Name = acc[0].Name;
        cn.NumberOfEmployees = acc[0].NumberOfEmployees;
        System.debug(cn);
        String mm = JSON.serialize(cn);
        System.debug(mm);
        return mm;
    }
    
}