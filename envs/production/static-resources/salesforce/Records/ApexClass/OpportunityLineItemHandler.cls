public class OpportunityLineItemHandler {
    public static Boolean isTriggerFire = true;
    
    public static void sync(map<Id,OpportunityLineItem> NewOlis ){
        List<OpportunityLineItem> lstQLIUpdate = new List<OpportunityLineItem>();
        set<Id> oliIds= new set<Id>();
        system.debug('Raz Ben Ron OLIH NewOlis.values(): '+NewOlis.values());
        for(OpportunityLineItem oli: NewOlis.values()){
            if(!oli.CC_Claim_Product__c)
                oliIds.add(oli.Id);
        }
        system.debug('Raz Ben Ron OLIH oliIds: '+oliIds);
        //set<Id> oliIds=NewOlis.keySet();
        for(QuoteLineItem qli: [Select id, ARR__c, Tier__c, Product_Type__c, Opportunity_Line_Item_Id__c,Plan_Period__c,Seats__c 
                                from QuoteLineItem WHERE Opportunity_Line_Item_ID__c= :oliIds]){
            lstQLIUpdate.add(new OpportunityLineItem(
                Id = qli.Opportunity_Line_Item_ID__c,
                ARR__c = qli.ARR__c,
               	Tier__c = qli.Tier__c,
                Product_Type__c = qli.Product_Type__c,
                Plan_Period__c = qli.Plan_Period__c,
                Seats__c = qli.Seats__c
            ));
        }
        system.debug('Raz Ben Ron OLIH lstQLIUpdate: '+lstQLIUpdate);
        if(!lstQLIUpdate.isEmpty()){
            isTriggerFire = false;
            update lstQLIUpdate;
            isTriggerFire = true;
        }
    }
}