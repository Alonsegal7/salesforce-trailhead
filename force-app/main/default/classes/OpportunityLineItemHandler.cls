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
        for(QuoteLineItem qli : [SELECT Id, Sales_Order_Primary_Line__c, ARR__c, Tier__c, Product_Type__c, Opportunity_Line_Item_Id__c, Plan_Period__c, Seats__c,
                                Training_Hours__c, Is_Primary__c, Added_Seats__c, Hours__c, Expiration_Date__c, ServiceDate, DealHub_Net_Price_USD__c
                                FROM QuoteLineItem WHERE Opportunity_Line_Item_ID__c =: oliIds]){
            lstQLIUpdate.add(new OpportunityLineItem(
                Id = qli.Opportunity_Line_Item_ID__c,
                ARR__c = qli.ARR__c,
                Tier__c = qli.Tier__c,
                Product_Type__c = qli.Product_Type__c,
                Plan_Period__c = qli.Plan_Period__c,
                Seats__c = qli.Seats__c,
                Training_Hours__c = qli.Training_Hours__c,
                Sales_Order_Primary_Line__c = qli.Sales_Order_Primary_Line__c,
                Is_Primary__c = qli.Is_Primary__c,
                Added_Seats__c = qli.Added_Seats__c,
                PS_Hours__c = qli.Hours__c,
                Expiration_Date__c = qli.Expiration_Date__c,
                PS_Start_Date__C = qli.ServiceDate,
                Service_Revenue__c=qli.DealHub_Net_Price_USD__c
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

    /*  Only After Insert
        Transfer PB logic to Code:
            Process Builder Name: Opportunity Line Item Created
        Related Magic 2.0 item:
            https://monday.monday.com/boards/2016847993/pulses/2949048428
        Object: OpportunityLineItem
            Update Opportunity fields while a new OLI is created
    */
    public static void populateOpportunityFields(Map<Id, OpportunityLineItem> newOlisMap){
        Set<Id> parentOppIds = new Set<Id>();
        List<Opportunity> oppUpdate = new List <Opportunity>();
        for(OpportunityLineItem oli : newOlisMap.values()){
            if(oli.ListPrice != null){
                parentOppIds.add(oli.OpportunityId);
            }
        }
        
        if(!parentOppIds.isEmpty()){
            for(Opportunity opp : [SELECT Id, Name, Expiration_Date__c, PS_Start_Date__c, Price_Per_Hour__c,
                                    (SELECT Id, Name, Expiration_Date__c, OpportunityId, PS_Start_Date__c, ListPrice FROM OpportunityLineItems) 
                                    FROM Opportunity WHERE Id IN: parentOppIds]){
                for(OpportunityLineItem oli : opp.Opportunitylineitems){
                    if(oli.OpportunityId == opp.Id){
                        opp.Expiration_Date__c = oli.Expiration_Date__c;
                        opp.PS_Start_Date__c = oli.PS_Start_Date__c;
                        opp.Price_Per_Hour__c = oli.ListPrice;
                        oppUpdate.add(opp);
                    }
                }
            }
        }

        if(!oppUpdate.isEmpty()){
            isTriggerFire = false;
            update oppUpdate;
            isTriggerFire = true;
        }
    }
}