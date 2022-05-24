public class OpportunityHelper {

    public static Id internalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();

    public static void beforeUpdate(List<Opportunity> opportunities, map <Id, Opportunity> oldMap){
        try{
            list<Opportunity> oppsWithMAChange= new list<Opportunity>();
            set<Id> maIds= new set<Id>();
            set<Id> userIds= new set<Id>();
            for(Opportunity opp : opportunities){
                Opportunity oldOpp = oldMap.get(opp.Id);
                
                if (oldOpp != null && oldOpp.AccountId != opp.AccountId && opp.AccountId!=null) { 
                    oppsWithMAChange.add(opp);
                    maIds.add(opp.AccountId);
                }
                if (oldOpp != null && (oldOpp.CurrencyIsoCode != opp.CurrencyIsoCode || opp.USD_exchange_rate__c == null)) { 
                    ExchangeRateService.apply(opp); 
                }
            }
            if(!oppsWithMAChange.isEmpty())
                handleAccountIdChange(oppsWithMAChange,maIds);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in OpportunityHelper ',e,e.getMessage());   
        }
    }

    public static void beforeInsert(List<Opportunity> opportunities,Map<Id,Opportunity> oldOpps) {
        set<Id> userIds= new set<Id>();
        for(Opportunity opp : opportunities) { 
            ExchangeRateService.apply(opp); 
            if(Opp.Close_Date_from_Lead__c!=null){
                opp.Closedate=Opp.Close_Date_from_Lead__c;
            }
        }
    }

    public static void updateOppType(List<Opportunity> opportunities, Map<Id,Opportunity> oldOpps){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        if(oldOpps == null){ //for insert
            determineOppType(opportunities);
        }else{
            for(Opportunity opp : opportunities) { 
                if(opp.Is_Account_Green_Bucket_New__c != oldOpps.get(opp.Id).Is_Account_Green_Bucket_New__c){
                    oppsToUpdate.add(opp);
                }
            }
            if(!oppsToUpdate.isEmpty()){
                determineOppType(oppsToUpdate);
            } 
        }
    }

    public static void determineOppType(List<Opportunity> opportunities){
        for(Opportunity opp : opportunities) { 
            if(opp.Is_Account_Green_Bucket_New__c){
                opp.Opportunity_Type__c  = 'Expansion';
            }else{
                opp.Opportunity_Type__c  = 'New Business';
            }
        }
    } 

    public static void markQuotesSigned(List<Opportunity> opps, map <Id, Opportunity> oldMap){
        Set<Id> signedQuotesIds = new Set<Id>();
        for(Opportunity opp : opps){ 
            if (opp.Is_SO_Signed__c 
                && opp.Manual_Signature_Reason__c != 'Priority SO'
                && oldMap != null && opp.Is_SO_Signed__c != oldMap.get(opp.Id).Is_SO_Signed__c) { 
                signedQuotesIds.add(opp.SyncedQuoteId); 
            } 
        }
        if(!signedQuotesIds.isEmpty()) {
            List<Quote> quotesList = [SELECT Id,Opportunity.DH_Signer_Title__c,Opportunity.DH_Signer_Name_c__c,Opportunity.DH_Date_of_Signature__c,DH_Date_of_Signature__c,
                                    DH_Signer_Name__c,DH_Signer_Title__c, Is_Manually_Signed__c,Document_Type__c,Opportunity.Manual_Signature_Reason__c 
                                    FROM Quote 
                                    WHERE Id = :signedQuotesIds AND Is_Manually_Signed__c = false AND Document_Type__c='Sales Order' AND DH_Quote_Status__c='Approved'];
            for(Quote q :quotesList) { 
                q.Is_Manually_Signed__c = true;
                q.Manual_Signature_Reason__c=q.Opportunity.Manual_Signature_Reason__c;
                q.DH_Date_of_Signature__c=q.Opportunity.DH_Date_of_Signature__c;
                q.DH_Signer_Name__c=q.Opportunity.DH_Signer_Name_c__c;
                q.DH_Signer_Title__c=q.Opportunity.DH_Signer_Title__c;
            }
            if (!quotesList.isEmpty()) update quotesList;
        }
    }

    public static void cloneOlisForCoSell(List<Opportunity> opps,map <Id, Opportunity> oldMap){
        list<Opportunity> masterCosellOpps= new list<Opportunity>();
        for(Opportunity opp : opps){ 
            if(opp.Main_Co_Sell_Opportunity__c
                &&opp.StageName=='Closed Won'
                &&opp.Co_Sell_Request__c==null //prevent cloning the olis for co-sell opps with Co_Sell_Request__c (co-sell 2.0)
                && (opp.StageName!=oldMap.get(opp.Id).StageName
                    ||opp.Co_Sell_Opportunity__c!=oldMap.get(opp.Id).Co_Sell_Opportunity__c
                    ||opp.Main_Co_Sell_Opportunity__c!=oldMap.get(opp.Id).Main_Co_Sell_Opportunity__c)){
                masterCosellOpps.add(opp);
            }
        }
        if(!masterCosellOpps.isEmpty()){
            try{
                list<opportunitylineitem> olisToCreate= new list<opportunitylineitem>();
                map<Id,Opportunity> oppsToUpdate = new map<Id,Opportunity> ();
                Pricebook2 mainPB=Utilities.getMainPB();
                list<opportunitylineitem> olidToDelete=[select Id,Co_Sell_Product_Id__c 
                                                        from Opportunitylineitem
                                                        where Opportunity.Co_Sell_Opportunity__c in: masterCosellOpps and Co_Sell_Product_Id__c!=null]; 
                for(opportunity opp: [select id,Co_Sell_Opportunity__c,Pricebook2Id,Co_Sell_Opportunity__r.Pricebook2Id,Billing_Ids__c,
                                            Co_Sell_Opportunity__r.Billing_Ids__c,CurrencyIsoCode,Co_Sell_Opportunity__r.CurrencyIsoCode,Is_Primary_SO_Signed__c,Co_Sell_Opportunity__r.Main_Co_Sell_Opportunity__c,
                                            (select Id,Is_Primary__c,CC_Claim_Product__c,ARR__c,Discount,ListPrice,ServiceDate,CurrencyIsoCode,PricebookEntry.CurrencyIsoCode,
                                            Name,Plan_Period__c,Product2Id,Product_Type__c,Quantity,UnitPrice,Seats__c,Subtotal,Tier__c,PricebookentryId
                                            from Opportunitylineitems where Is_Primary__c=true and CC_Claim_Product__c=false) 
                                            from Opportunity where id in: masterCosellOpps]){
                    if(opp.Co_Sell_Opportunity__r.Pricebook2Id==null)
                        oppsToUpdate.put(opp.Co_Sell_Opportunity__c,new opportunity(id=opp.Co_Sell_Opportunity__c,Pricebook2Id=opp.Pricebook2Id!=null?opp.Pricebook2Id:mainPB.id));
                    system.debug('cloneOlisForCoSell opp.Co_Sell_Opportunity__r.CurrencyIsoCode: '+opp.Co_Sell_Opportunity__r.CurrencyIsoCode);
                    if(!opp.Opportunitylineitems.isEmpty()&&opp.Co_Sell_Opportunity__r.Main_Co_Sell_Opportunity__c==false){
                        if(opp.Is_Primary_SO_Signed__c){
                            for(opportunitylineitem oli: opp.Opportunitylineitems){//copy all primary wire products if SO signed
                                system.debug('cloneOlisForCoSell oli.id: '+oli.Id);
                                system.debug('cloneOlisForCoSell oli.PricebookEntry.CurrencyIsoCode: '+oli.PricebookEntry.CurrencyIsoCode);
                                opportunitylineitem oliCopy = oli.clone(false, true, true, false);
                                system.debug('cloneOlisForCoSell oliCopy.PricebookEntry.CurrencyIsoCode: '+oliCopy.PricebookEntry.CurrencyIsoCode);
                                oliCopy.OpportunityId=opp.Co_Sell_Opportunity__c;//co sells are always connected to each other in a bi-directional lookup
                                oliCopy.Co_Sell_Product_Id__c=oli.id;
                                oliCopy.Co_Sell_Product__c=true;
                                olisToCreate.add(oliCopy);
                                system.debug('cloneOlisForCoSell oliCopy: '+oliCopy);
                            }
                        }
                    }else {
                        if(opp.Billing_Ids__c!=null){//to handle claim that is made without a DealHub SO
                            if(oppsToUpdate.containskey(opp.Co_Sell_Opportunity__c))
                                oppsToUpdate.get(opp.Co_Sell_Opportunity__c).Billing_Ids__c=opp.Billing_Ids__c;
                            else {
                                oppsToUpdate.put(opp.Co_Sell_Opportunity__c,new opportunity(id=opp.Co_Sell_Opportunity__c,Billing_Ids__c=opp.Co_Sell_Opportunity__r.Billing_Ids__c!=null?opp.Co_Sell_Opportunity__r.Billing_Ids__c+','+opp.Billing_Ids__c:opp.Billing_Ids__c));
                            }
                        }
                    }
                }
                system.debug('cloneOlisForCoSell olidToDelete: '+olidToDelete);
                system.debug('cloneOlisForCoSell olisToCreate: '+olisToCreate);
                if(!olidToDelete.isEmpty()) { delete olidToDelete; }
                if(!oppsToUpdate.values().isEmpty()) { update oppsToUpdate.values(); }
                if(!olisToCreate.isEmpty()) { insert olisToCreate; }
            }catch(Exception e){
                Utilities.sendDebugEmail('Error in OpportunityHelper: cloneOlisForCoSell ',e,e.getMessage());   
            }
        }
    }
    
    //public static void handleAccountIdChange(Opportunity opportunity){
    public static void handleAccountIdChange(list<Opportunity> opportunities,Set<Id> maIds){ //can be deleted
        map<Id,Account> accountDetails= new map<Id,Account>([select id,RecordTypeId,Company__c
                                                                from Account where id in: maIds]);
        for(Opportunity opp: opportunities){
            Account acc=accountDetails.get(opp.AccountId);
            String recordTypeDevName = RecordTypeHelper.devName(acc.recordTypeId);
            system.debug('recordTypeDevName: '+recordTypeDevName);
            if (recordTypeDevName == 'Company') {
                opp.Company__c = acc.Id;
                opp.Monday_Account__c = null;
            } else if (recordTypeDevName == 'Monday_Account') {
                system.debug('opp.Account.Company__c: '+opp.Account.Company__c);
                opp.Company__c = acc.Company__c;
                opp.Monday_Account__c = acc.Id;
            }
        }
    }
}