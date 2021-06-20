public class OpportunityLineItemHandler {
    public static Boolean isTriggerFire = true;
    
    public static void sync(Map<Id,OpportunityLineItem> NewOlis ){
        List<OpportunityLineItem> lstQLIUpdate = new List<OpportunityLineItem>();
        Set<Id> oliIds = new Set<Id>();
        system.debug('Raz Ben Ron OLIH NewOlis.values(): '+NewOlis.values());
        for(OpportunityLineItem oli : NewOlis.values()){
            if(!oli.CC_Claim_Product__c && !oli.Co_Sell_Product__c){
                oliIds.add(oli.Id);
            }
        }
        system.debug('Raz Ben Ron OLIH oliIds: '+oliIds);
        //set<Id> oliIds=NewOlis.keySet();
        for(QuoteLineItem qli : [SELECT Id, ARR__c, Tier__c, Product_Type__c, Opportunity_Line_Item_Id__c, Plan_Period__c, Seats__c,
                                Training_Hours__c, Is_Primary__c, Added_Seats__c, Hours__c, Expiration_Date__c, ServiceDate
                                FROM QuoteLineItem WHERE Opportunity_Line_Item_ID__c =: oliIds]){
            lstQLIUpdate.add(new OpportunityLineItem(
                Id = qli.Opportunity_Line_Item_ID__c,
                ARR__c = qli.ARR__c,
                 Tier__c = qli.Tier__c,
                Product_Type__c = qli.Product_Type__c,
                Plan_Period__c = qli.Plan_Period__c,
                Seats__c = qli.Seats__c,
                Training_Hours__c = qli.Training_Hours__c,
                Is_Primary__c = qli.Is_Primary__c,
                Added_Seats__c = qli.Added_Seats__c,
                PS_Hours__c = qli.Hours__c,
                Expiration_Date__c = qli.Expiration_Date__c,
                PS_Start_Date__C = qli.ServiceDate
            ));
        }
        system.debug('Raz Ben Ron OLIH lstQLIUpdate: '+lstQLIUpdate);
        if(!lstQLIUpdate.isEmpty()){
            isTriggerFire = false;
            update lstQLIUpdate;
            isTriggerFire = true;
        }
    }
    public static void restoreCreditCardOlis(map<Id,Opportunitylineitem> oldOLIs) {
        list<Opportunitylineitem> olisToInsert= new list<Opportunitylineitem>();
        for(Opportunitylineitem oli: oldOLIs.values()){
            //restore CC opportunity products that are being deleted when a quote is synced.
            if(oli.CC_Claim_Product__c&&!oli.Force_Delete__c){
                Opportunitylineitem newOli=oli.clone(false, true, true, false);
                newOli.TotalPrice=null;
                olisToInsert.add(newOli);
            }
        }
        system.debug('Raz Ben Ron olisToInsert: '+olisToInsert);
        if(!olisToInsert.isEmpty())
            insert olisToInsert;

    }
}