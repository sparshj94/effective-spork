public class PracticePaper1 {
    public static void mm(List<Order> orderList){
        //String st = '[Product1(2), Product2(1), Product3(3),GenWatt Diesel 1000kW(4)]';
        Set<String> productNames = new Set<String>();
        Map<String, Decimal> productQtyMap = new Map<String, Decimal>();
        List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        List<String> invalidProduct = new List<String>();
        Id stdPbId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        List<Id> pbId = new List<Id>();
        for(Order ord : orderList){
            pbId.add(ord.Pricebook2Id);
            /*
            if(ord.Pricebook2Id == null){
                ord.Pricebook2Id = stdPbId;
            }
*/
            String str = ord.Products__c.substring(1, ord.Products__c.length()-1);
            List<String> parts = str.split(',');
            for(String p : parts){
                p = p.trim();
                String qty = p.substringBetween('(',')');
                String name = p.substringBefore('(');

                productNames.add(name);
                productQtyMap.put(name, Decimal.valueOf(qty));
            }
        }

        List<Product2> products = [
            SELECT Id, Name, (SELECT Id, UnitPrice FROM PricebookEntries WHERE Pricebook2Id = :pbId) FROM Product2 WHERE Name IN :productNames];

        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 p : products){
            productMap.put(p.Name, p);
        }

        for(Order ord : orderList){
            for(String name : productQtyMap.keySet()){
                Product2 p = productMap.get(name);
                if(p==null){
                    invalidProduct.add(name);
                }

                if(p != null && !p.PricebookEntries.isEmpty()){
                    PricebookEntry pbe = p.PricebookEntries[0];

                    orderItemsToInsert.add(new OrderItem(
                        OrderId = ord.Id,
                        PricebookEntryId = pbe.Id,
                        Quantity = productQtyMap.get(name),
                        UnitPrice = pbe.UnitPrice
                    ));
                }
            }
        }
        
        Database.SaveResult[] sv = Database.insert(orderItemsToInsert,false);
        for(Database.SaveResult sr : sv){
            if (sr.isSuccess()) {
        		// Operation was successful, so get the ID of the record that was processed
        		System.debug('Successfully inserted' + sr.getId());
               	System.debug('Invalid Products'+ invalidProduct);
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