public class OpportunityHelper {
    public static Id csRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
    public static Id internalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
  public static void beforeUpdate(List<Opportunity> opportunities, map <Id, Opportunity> oldMap){
        try{
            list<Opportunity> oppsWithMAChange= new list<Opportunity>();
            list<Opportunity> oppsWithOwnerChange= new list<Opportunity>();
            set<Id> maIds= new set<Id>();
            set<Id> userIds= new set<Id>();
            for(Opportunity opp : opportunities){
                Opportunity oldOpp = oldMap.get(opp.Id);
                
                if (oldOpp != null && oldOpp.AccountId != opp.AccountId && opp.AccountId!=null) { 
                    oppsWithMAChange.add(opp);
                    maIds.add(opp.AccountId);
                    //handleAccountIdChange(opp); 
                }
                if (oldOpp != null && (oldOpp.CurrencyIsoCode != opp.CurrencyIsoCode || opp.USD_exchange_rate__c == null)) { ExchangeRateService.apply(opp); }
                
                if(isManagedByDealhub(opp)){
                    opp.Expected_ARR__c = opp.Quote_ARR__c;

                    if(opp.Is_Primary_SO_Signed__c) {
                        opp.Claimed_ARR__c = opp.Product_ARR__c; 
                    } 
                    else if(opp.Co_Sell_Opportunity__c!=null&&opp.Main_Co_Sell_Opportunity__c==false){//secondary co-sell opp
                        opp.Expected_ARR__c = opp.Product_ARR__c;
                        opp.Claimed_ARR__c = opp.Product_ARR__c; 

                    }
                }

                if(opp.Claimed_ARR_Override__c!=null)
                    opp.Claimed_ARR__c =opp.Claimed_ARR_Override__c;
                
                try{
                    if(opp.Type!=null&&opp.Type.contains('Renewal')||opp.RecordTypeId==csRecordTypeId){
                        decimal totalDealARR=null;
                        decimal contractaRR=opp.Original_Contract_ARR__c==null?0:opp.Original_Contract_ARR__c;
                        if(opp.SyncedQuoteId==null){
                            totalDealARR=contractaRR+opp.Green_Bucket_ARR_V2__c;
                            
                        }else{
                            totalDealARR=opp.Total_License_ARR__c;
                        }
                        decimal retentionRate=contractaRR==0?0:totalDealARR/contractaRR;
                        opp.Total_Renewal_ARR__c=totalDealARR;
                        opp.Net_ARR_Retention__c=retentionRate*100;
                        opp.Gross_ARR_Retention__c=math.min(retentionRate,1)*100;
                    }
                }catch(exception e){
                    Utilities.sendDebugEmail('Error in OpportunityHelper: Renewal Metrics ',e,e.getMessage());   
                }
                
                if(opp.RecordTypeId==partnerRecordTypeId&&
                    (oldMap==null||opp.OwnerId!=oldMap.get(opp.Id).OwnerId)){
                        userIds.add(opp.OwnerId);
                        oppsWithOwnerChange.add(opp);
                }
            }
            if(!oppsWithMAChange.isEmpty())
                handleAccountIdChange(oppsWithMAChange,maIds);
            if(!oppsWithOwnerChange.isEmpty())
                setPartnerCompany(oppsWithOwnerChange,userIds);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in OpportunityHelper ',e,e.getMessage());   
        }


    }

    public static void beforeInsert(List<Opportunity> opportunities,Map<Id,Opportunity> oldOpps) {
        list<Opportunity> oppsWithOwnerChange= new list<Opportunity>();
        set<Id> userIds= new set<Id>();
        for(Opportunity opp : opportunities) { 
            ExchangeRateService.apply(opp); 
            if(opp.RecordTypeId==partnerRecordTypeId){
                userIds.add(opp.OwnerId);
                oppsWithOwnerChange.add(opp);
            }
            if(Opp.Close_Date_from_Lead__c!=null){
                opp.Closedate=Opp.Close_Date_from_Lead__c;
            }
        }
        if(!oppsWithOwnerChange.isEmpty()){
            setPartnerCompany(oppsWithOwnerChange,userIds);
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

    
    public static void afterUpdate(List<Opportunity> opps,map <Id, Opportunity> oldMap){
        try{
        Set<Id> SignedQuotes = new Set<Id>();
        list<Opportunity> masterCosellOpps= new list<Opportunity>();
        for(Opportunity opp : opps){ 
            if (opp.Is_SO_Signed__c&&opp.Manual_Signature_Reason__c!='Priority SO') { 
                SignedQuotes.add(opp.SyncedQuoteId); 
            } 
            if(opp.StageName!=oldMap.get(opp.Id).StageName&&opp.StageName=='Closed Won'&&opp.Main_Co_Sell_Opportunity__c){
                masterCosellOpps.add(opp);
            }
        }
        if(!SignedQuotes.isEmpty())
            MarkQuotesSigned(SignedQuotes);
        if(!masterCosellOpps.isEmpty())
            cloneOlisForCoSell(masterCosellOpps);
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in OpportunityHelper ',e,e.getMessage());   
        }
    }

    public static boolean isManagedByDealhub(Opportunity opp){
        return (opp.Quote_Count__c != null && opp.Quote_Count__c != 0) || (opp.Product_Count__c != null && opp.Product_Count__c != 0);
    }

    public static void cloneOlisForCoSell(list<Opportunity> masterCosellOpps){
        try{
            list<opportunitylineitem> olisToCreate= new list<opportunitylineitem>();
            map<Id,Opportunity> oppsToUpdate = new map<Id,Opportunity> ();
            Pricebook2 mainPB=Utilities.getMainPB();
            list<opportunitylineitem> olidToDelete=[select Id,Co_Sell_Product_Id__c 
                                                    from Opportunitylineitem
                                                    where Opportunity.Co_Sell_Opportunity__c in: masterCosellOpps and Co_Sell_Product_Id__c!=null]; 
            
            for(opportunity opp: [select id,Co_Sell_Opportunity__c,Pricebook2Id,Co_Sell_Opportunity__r.Pricebook2Id,Billing_Ids__c,
                                        Co_Sell_Opportunity__r.Billing_Ids__c,CurrencyIsoCode,Co_Sell_Opportunity__r.CurrencyIsoCode,Is_Primary_SO_Signed__c,
                                        (select Id,Is_Primary__c,CC_Claim_Product__c,ARR__c,Discount,ListPrice,ServiceDate,CurrencyIsoCode,PricebookEntry.CurrencyIsoCode,
                                        Name,Plan_Period__c,Product2Id,Product_Type__c,Quantity,UnitPrice,Seats__c,Subtotal,Tier__c,PricebookentryId
                                        from Opportunitylineitems where Is_Primary__c=true and CC_Claim_Product__c=false) 
                                        from Opportunity where id in: masterCosellOpps]){
                if(opp.Co_Sell_Opportunity__r.Pricebook2Id==null)
                    oppsToUpdate.put(opp.Co_Sell_Opportunity__c,new opportunity(id=opp.Co_Sell_Opportunity__c,Pricebook2Id=opp.Pricebook2Id!=null?opp.Pricebook2Id:mainPB.id));
                system.debug('Raz Ben Ron cosc master opp.Co_Sell_Opportunity__r.CurrencyIsoCode: '+opp.Co_Sell_Opportunity__r.CurrencyIsoCode);
                if(!opp.Opportunitylineitems.isEmpty()){
                    if(opp.Is_Primary_SO_Signed__c){
                        for(opportunitylineitem oli: opp.Opportunitylineitems){//copy all primary wire products if SO signed
                            system.debug('Raz Ben Ron cosc master oli.id: '+oli.Id);
                            system.debug('Raz Ben Ron cosc master oli.PricebookEntry.CurrencyIsoCode: '+oli.PricebookEntry.CurrencyIsoCode);
                            opportunitylineitem oliCopy = oli.clone(false, true, true, false);
                            system.debug('Raz Ben Ron cosc master oliCopy.PricebookEntry.CurrencyIsoCode: '+oliCopy.PricebookEntry.CurrencyIsoCode);
                            oliCopy.OpportunityId=opp.Co_Sell_Opportunity__c;//co sells are always connected to each other in a bi-directional lookup
                            oliCopy.Co_Sell_Product_Id__c=oli.id;
                            oliCopy.Co_Sell_Product__c=true;
                            olisToCreate.add(oliCopy);
                            system.debug('Raz Ben Ron cosc oliCopy: '+oliCopy);
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
            system.debug('Raz Ben Ron cosc olidToDelete: '+olidToDelete);
            system.debug('Raz Ben Ron cosc olisToCreate: '+olisToCreate);
            if(!olidToDelete.isEmpty()) { delete olidToDelete; }
            if(!oppsToUpdate.values().isEmpty()) { update oppsToUpdate.values(); }
            if(!olisToCreate.isEmpty()) { insert olisToCreate; }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in OpportunityHelper: cloneOlisForCoSell ',e,e.getMessage());   
        }
    }

    public static void MarkQuotesSigned(Set<Id> quoteIds){
        if(quoteIds.size() > 0){
            List<Quote> quotesList = [SELECT Id,Opportunity.DH_Signer_Title__c,Opportunity.DH_Signer_Name_c__c,Opportunity.DH_Date_of_Signature__c,DH_Date_of_Signature__c,DH_Signer_Name__c,DH_Signer_Title__c, Is_Manually_Signed__c,Document_Type__c,Opportunity.Manual_Signature_Reason__c FROM Quote WHERE Id = :quoteIds AND Is_Manually_Signed__c = false AND Document_Type__c='Sales Order' AND DH_Quote_Status__c='Approved'];
            for(Quote q :quotesList) { 
                q.Is_Manually_Signed__c = true;
                q.Manual_Signature_Reason__c=q.Opportunity.Manual_Signature_Reason__c;
                q.DH_Date_of_Signature__c=q.Opportunity.DH_Date_of_Signature__c;
                q.DH_Signer_Name__c=q.Opportunity.DH_Signer_Name_c__c;
                q.DH_Signer_Title__c=q.Opportunity.DH_Signer_Title__c;
            }
            if ( !quotesList.isEmpty() ) { update quotesList; }
        }
    }
    
    //public static void handleAccountIdChange(Opportunity opportunity){
    public static void handleAccountIdChange(list<Opportunity> opportunities,Set<Id> maIds){
        map<Id,Account> accountDetails= new map<Id,Account>([select id,RecordTypeId,Company__c
                                                                from Account where id in: maIds]);
        for(Opportunity opp: opportunities){
            Account acc=accountDetails.get(opp.AccountId);
            String recordTypeDevName = RecordTypeHelper.devName(acc.recordTypeId);
            system.debug('Raz Ben Ron recordTypeDevName: '+recordTypeDevName);
            if (recordTypeDevName == 'Company') {
                opp.Company__c = acc.Id;
                opp.Monday_Account__c = null;
            } else if (recordTypeDevName == 'Monday_Account') {
                system.debug('Raz Ben Ron opp.Account.Company__c: '+opp.Account.Company__c);
                opp.Company__c = acc.Company__c;
                opp.Monday_Account__c = acc.Id;
            }
        }
    /*if (opportunity.AccountId == null) { return; } 
                
        Account account = [SELECT Id, RecordTypeId, Company__c FROM Account WHERE Id=:opportunity.AccountId LIMIT 1];
        String recordTypeDevName = RecordTypeHelper.devName(account.recordTypeID);
        
        if (recordTypeDevName == 'Company') {
      opportunity.Company__c = account.Id;
      opportunity.Monday_Account__c = null;
        } else if (recordTypeDevName == 'Monday_Account') {
          opportunity.Company__c = account.Company__c;
            opportunity.Monday_Account__c = account.Id;
        }*/
    }
    public static void setPartnerCompany(list<Opportunity> relevantOpps, set<Id> relevantUsers){
        try{
            map<Id,User> usersWithDetails= new map<Id,User>([select id,Contact.AccountId from User where id in:relevantUsers]);
            for(Opportunity opp: relevantOpps){
                if(usersWithDetails.containskey(opp.OwnerId)&&usersWithDetails.get(opp.OwnerId).Contact.AccountId!=null)
                    opp.Channel_Partner__c=usersWithDetails.get(opp.OwnerId).Contact.AccountId;
                else{
                    opp.Channel_Partner__c=null;
                }
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in OpportunityHelper: setPartnerCompany ',e,e.getMessage());   
        }
    }
}