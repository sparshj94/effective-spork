public with sharing class ShopEaseTriggerHandler {
    
    class EmailWrapper{
        String customerName;
        Decimal pointsEarned;
        Decimal pointsRedeemed;
        Decimal pointBalance;

        EmailWrapper(String customerName, Decimal pointsEarned , Decimal pointsRedeemed , Decimal pointBalance){
            this.customerName = customerName;
            this.pointsEarned = pointsEarned;
            this.pointBalance = pointBalance;
            this.pointsRedeemed = pointsRedeemed;
        }
    }
    // Before insert on Customerr
    public static void setDefaultMembershipTier(List<Customerr__c> newList){
        for (Customerr__c cs : newList) {
            cs.Membership_Tier__c = 'Bronze';
        }
    }

    // before insert on purchase
    public static void pointsEarnedonPurchase(List<Purchase__c> newList){
        for (Purchase__c pur : newList) {
            Decimal points = pur.Total_Amount__c*0.25;
            pur.Points_Earned__c = points;
        }
    }

    // after insert on purchase
    public static void totalPointsCCustomer(List<Purchase__c> newList){
        Set<Id> customerId = new Set<Id>();
        for (Purchase__c ps : newList) {
            if(ps.Customerr__c!=null){
                customerId.add(ps.Customerr__c);
            }
        }
        
        Map<ID, Customerr__c> customerMap = new Map<iD, Customerr__c>([SELECT ID, Name__c, Loyalty_Points__c FROM Customerr__c WHERE Id IN :customerId]);
        List<Customerr__c> customerUpdated = new List<Customerr__c>();
        for (Purchase__c ps : newList) {
            if(customerMap.containsKey(ps.Customerr__c)){
                Customerr__c customer = customerMap.get(ps.Customerr__c);
                Decimal totalPoints = customer.Loyalty_Points__c + ps.Points_Earned__c;
                Customerr__c upCustomer = new Customerr__c(Id=customer.Id, Loyalty_Points__c = totalPoints);
                customerUpdated.add(upCustomer);
            }
        }
        Database.update(customerUpdated);
    }

    // after insert on redemption
    public static void redeemCustomerPoints(List<Redemption__c> newList){
        Set<Id> customerId = new Set<Id>();
        for (Redemption__c ps : newList) {
            if(ps.Customerr__c!=null){
                customerId.add(ps.Customerr__c);
            }
        }
        Map<ID, Customerr__c> customerMap = new Map<iD, Customerr__c>([SELECT ID, Name__c, Loyalty_Points__c FROM Customerr__c WHERE Id IN :customerId]);
        List<Customerr__c> customerUpdated = new List<Customerr__c>();
        for (Redemption__c ps : newList) {
            if(customerMap.containsKey(ps.Customerr__c)){
                Customerr__c customer = customerMap.get(ps.Customerr__c);
                Decimal redeemPoints = ps.Points_Redeem__c!=null ? ps.Points_Redeem__c : 0;
                Decimal totalPoints = customer.Loyalty_Points__c - redeemPoints;
                Customerr__c upCustomer = new Customerr__c(Id=customer.Id, Loyalty_Points__c = totalPoints);
                customerUpdated.add(upCustomer);
            }
        }
        Database.update(customerUpdated);
    }

    // before insert on redemption
    public static void validateRedeemPointsCustomer(List<Redemption__c> newList){
        Set<Id> customerId = new Set<Id>();
        for (Redemption__c ps : newList) {
            if(ps.Customerr__c!=null){
                customerId.add(ps.Customerr__c);
            }
        }
        Map<ID, Customerr__c> customerMap = new Map<iD, Customerr__c>([SELECT ID, Name__c, Loyalty_Points__c FROM Customerr__c WHERE Id IN :customerId]);
        for (Redemption__c ps : newList) {
            if(customerMap.containsKey(ps.Customerr__c)){
                Customerr__c customer = customerMap.get(ps.Customerr__c);
                Decimal redeemPoints = ps.Points_Redeem__c!=null ? ps.Points_Redeem__c : 0;
                if(customer.Loyalty_Points__c < redeemPoints){
                    ps.addError('Customer Dont have enough points to redeem...');
                }
            }
        }
    }

    // before update  on customer - loyalty point change only
    public static void updateMembershipTier(List<Customerr__c> newList, Map<Id,Customerr__c> oldMap){
        for (Customerr__c cs : newList) {
            Customerr__c oldCustomer = oldMap.get(cs.Id);
            if(cs.Loyalty_Points__c!=oldCustomer.Loyalty_Points__c){
                if(cs.Loyalty_Points__c < 1000){
                    cs.Membership_Tier__c = 'Bronze';
                }
                else if(cs.Loyalty_Points__c < 5000){
                    cs.Membership_Tier__c = 'Silver';
                }
                else if(cs.Loyalty_Points__c < 10000){
                    cs.Membership_Tier__c = 'Gold';
                }
                else{
                    cs.Membership_Tier__c = 'Platinum';
                }
            }
        }
    }


    public static void sendMonthlyEmailAdmin(){
        Map<Id, Decimal> earnedMap = new Map<Id, Decimal>();
        Map<Id, Decimal> redeemedMap = new Map<Id, Decimal>();
        
        for (AggregateResult ags : [SELECT Customerr__c csId, SUM(Points_Earned__c) totalEarned FROM Purchase__c group by Customerr__c]) {
            earnedMap.put((Id)ags.get('csId'), (Decimal)ags.get('totalEarned'));
        }
        for (AggregateResult ags : [SELECT Customerr__c csId, SUM(Points_Redeem__c) totalRedeem FROM Redemption__c group BY Customerr__c]) {
            redeemedMap.put((Id)ags.get('csId'), (Decimal)ags.get('totalRedeem'));
        }
        List<EmailWrapper> emailTabledata = new List<EmailWrapper>();
        for (Customerr__c cs : [SELECT Id, Name__c, Loyalty_Points__c FROM Customerr__c]) {
            Decimal pointsEarned = earnedMap.containsKey(cs.Id) ? earnedMap.get(cs.Id) : 0;
            Decimal pointsRedeem = redeemedMap.containsKey(cs.Id) ? redeemedMap.get(cs.Id) : 0;
            Decimal total = cs.Loyalty_Points__c!=null ? cs.Loyalty_Points__c : 0;

            emailTabledata.add(new EmailWrapper(cs.Name__c, pointsEarned, pointsRedeem, total));
        }

        String tableHTML = generatepdf(emailTabledata);


        String emailBody =
        'Dear Loyalty Admin,<br/><br/>' +
        'Please find below the monthly statement detailing loyalty points earned, redeemed, and current balance for each customer.<br/><br/>' +
        tableHTML +
        '<br/><br/>Best Regards,<br/>ShopEase Loyalty Program Team';

        // generate pdf
        String pdfHTML =
            '<html><body>' +
            emailBody +
            '</body></html>';
        // Blob htmlBlob = Blob.valueOf(pdfHTML);
        Blob pdfBlob = Blob.toPdf(pdfHTML);

        // attachement
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
            file.setFileName('MonthlyUsersData.pdf');
            file.setBody(pdfBlob);
            file.setContentType('application/pdf');

        // email
        mail.setToAddresses(new String[]{'sparshjain@cyntexa.com'});
        mail.setSubject('ShopEase Loyalty Monthly Statement');
        mail.setHtmlBody(emailBody); // TABLE IN EMAIL BODY
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{file}); // PDF ATTACHMENT
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }


    public static String generatepdf(List<EmailWrapper> emailData){
        Decimal totalEarned = 0;
        Decimal totalRedeemed = 0;
        Decimal totalBalance = 0;

        String html =
        '<h2>ShopEase Loyalty Program - Monthly Statement</h2>' +
        '<table border="1" style="border-collapse:collapse;width:100%;">' +
        '<tr>' +
        '<th>Customer Name</th>' +
        '<th>Points Earned</th>' +
        '<th>Points Redeemed</th>' +
        '<th>Current Points</th>' +
        '</tr>';

        for(EmailWrapper emp : emailData){

            totalEarned += emp.pointsEarned;
            totalRedeemed += emp.pointsRedeemed;
            totalBalance += emp.pointBalance;

            html += '<tr>';
            html += '<td>' + emp.customerName + '</td>';
            html += '<td>' + emp.pointsEarned + '</td>';
            html += '<td>' + emp.pointsRedeemed + '</td>';
            html += '<td>' + emp.pointBalance + '</td>';
            html += '</tr>';
        }

        html +=
        '<tr style="font-weight:bold;background:#f2f2f2;">' +
        '<td>Total</td>' +
        '<td>' + totalEarned + '</td>' +
        '<td>' + totalRedeemed + '</td>' +
        '<td>' + totalBalance + '</td>' +
        '</tr>';

        html += '</table>';

        return html;
    }
}