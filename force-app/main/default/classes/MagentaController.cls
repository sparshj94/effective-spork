@RestResource(urlmapping='/in')
global with sharing class MagentaController {
   
    public class Rw{
        
    }
    
    public class RequestWrapper {
        String Name;
        String Email;
        List<Salaries> Salaries;   
    }
    public class Salaries{
        String Amount;
        String Month;
        Integer external;
    }
    //00Dfj00000J0ph7!AQEAQHyjVldpg.1yXZ_WsXO777KhH5hBRM62XBqg0VFhmtmGkii7PFbQENlmHv6FrkIUqOdvRNP4O2vliZ9jvNbKf9EJZktR
    @HttpPost   
    global static void getAndInsert(){
        RestRequest req = RestContext.request;
        String str = req.requestBody.toString();
        // Blob inputBlob = req.requestBody;
        // List<Object> reqestString = (List<Object>)req.requestBody;
        List<RequestWrapper> reqList = (List<RequestWrapper>)JSON.deserialize(str, List<RequestWrapper>.class);
        
        System.debug(reqList);
        for (RequestWrapper variable : reqList) {
            System.debug(variable);
            System.debug(variable.Name + ' ' + variable.Email);

        }
    }
}