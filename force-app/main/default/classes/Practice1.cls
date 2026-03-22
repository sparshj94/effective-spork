public class Practice1 {
    public static void mm(){
        List<Order> orderList = new List<Order>();
        Set<Id> orderIds = new Set<Id>();
        for(Order o:orderList){
            orderIds.add(o.Id);
        }
        String orderId = '801fj00000j4tYjAAI';
        String str = '[Product1(2), Product2(1), Product3(3),GenWatt Diesel 1000kW(4)]';
        List<String> ans  = str.subString(1,str.length()-1).split(',');
        Map<String,String> mpp = new Map<String,String>();
        // unique product names
        Set<String> productNames = new Set<String>();
        for(String st : ans){
            String q = st.substringBetween('(',')');
            String p = st.substringBetween('','(');
            mpp.put(p,q);
            productNames.add(p);
        }
       
      
        List<Product2> dbProducts = [SELECT Id, Name FROM Product2 WHERE Name IN :productNames];
         
        System.debug(dbProducts);
        for(Product2 pm : dbProducts){
            System.debug(pm.PricebookEntries[0]);
        }
        
        List<OrderItem> orderItemToBeCreated = new List<OrderItem>();
        for(Product2 st : dbProducts){
            if(mpp.containsKey(st.Name)){
                OrderItem oi = new OrderItem();
                oi.Product2Id = st.Id;
                oi.OrderId = orderId;
                oi.UnitPrice = st.PricebookEntries[0].UnitPrice;
                oi.PricebookEntryId = st.PricebookEntries[0].Id;
                oi.Quantity = Decimal.valueOf(mpp.get(st.Name));
                orderItemToBeCreated.add(oi);
            }
        }

        Database.SaveResult[] sv = Database.insert(orderItemToBeCreated,false);
        for(Database.SaveResult sr : sv){
            if (sr.isSuccess()) {
        		// Operation was successful, so get the ID of the record that was processed
        		System.debug('Successfully inserted' + sr.getId());
    		}
    		else {
        		// Operation failed, so get all errors                
        		for(Database.Error err : sr.getErrors()) {
            		System.debug('The following error has occurred.');                    
            		System.debug(err.getStatusCode() + ': ' + err.getMessage());
            		System.debug('Account fields that affected this error: ' + err.getFields());
        	}
    	}
        
    }
    }
}