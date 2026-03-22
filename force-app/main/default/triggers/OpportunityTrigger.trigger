trigger OpportunityTrigger on Opportunity (after update) {

    /*
    List<Id> oppId = new List<Id>();

    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        if(opp.StageName=='Closed Won' && oldOpp.StageName!='Closed Won' && opp.Amount!=null && opp.payment_link__c==null){
            oppId.add(opp.Id);
        }
        if(!oppId.isEmpty()){
            StripePaymentService.makePayment(oppId);
        }
    }
	*/
    PracticePaper2Account.mm(Trigger.oldMap, Trigger.newMap);

}