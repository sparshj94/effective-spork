public with sharing class ProductAndPriceController {
    
	public class ProductWrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String DisplayUrl;
        @AuraEnabled
        public Decimal UnitPrice;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProductsAndPrice(){
        List<ProductWrapper> pwList = new List<ProductWrapper>();
        List<Product2> prodList = [SELECT Id, Name, Description, DisplayUrl, (SELECT Id, UnitPrice from  PricebookEntries) from Product2 limit 2];
        for (Product2 p : prodList) {
            ProductWrapper pw = new ProductWrapper();
            pw.Id = p.Id;
            pw.Name = p.Name;
            pw.Description = p.Description;
            pw.DisplayUrl = p.DisplayUrl;
            pw.UnitPrice = p.PricebookEntries[0].UnitPrice;
            pwList.add(pw);
        }
        for (ProductWrapper p : pwList) {
            System.debug(p.Name);
            System.debug(p.UnitPrice);
        }
        
        return pwList;
    }
}