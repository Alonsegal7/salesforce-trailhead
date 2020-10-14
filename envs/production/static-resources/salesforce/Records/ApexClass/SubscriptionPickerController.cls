public with sharing class SubscriptionPickerController {
    @AuraEnabled(cacheable=true)
    public static map<Id,Subscription__c> getSubscriptions(String oppId){
        try{
            Opportunity opp=[select id,AccountId from Opportunity where id=:oppId][0];
            map<Id,Subscription__c> subs=new map<Id,Subscription__c>([select id,name,Seats__c,Product_Code__c,Name_for_CC_Claim__c
                                        from Subscription__c 
                                        where Monday_Account__c=:opp.AccountId and 
                                        Is_Claimed__c=false and Status__c!='DELETED' and (Payment_Method__c='BLUESNAP_CC' or Include_In_CC_Claim__c=true)
                                        order by createddate desc]);
            system.debug('Raz Ben Ron currentCon from Controller, '+subs);
            return subs;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static map<Id,Subscription__c> getClaimed(String oppId){
        try{
            Opportunity opp=[select id,AccountId from Opportunity where id=:oppId][0];
            map<Id,Subscription__c> subs=new map<Id,Subscription__c>([select id,name,Seats__c,Product_Code__c,Period__c,Name_for_CC_Claim__c
                                        from Subscription__c 
                                        where Monday_Account__c=:opp.AccountId And
                                        Claimed_On_Opportunity__c=:oppId And
                                        Is_Claimed__c=true
                                        order by createddate desc]);
            system.debug('Raz Ben Ron currentCon from Controller, '+subs);
            return subs;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<opportunitylineitem> claimSubs(list<String> subsIdsToClaim, String oppId, list<String> productCodes){
        try{
            system.debug('Raz Ben Ron oppId from Controller, '+oppId);
            Opportunity opp=[select id,Pricebook2Id,Billing_Ids__c,CurrencyIsoCode from Opportunity where id=:oppId][0];
            List<Opportunitylineitem> olisToInsert= new List<Opportunitylineitem>();
            List<Subscription__c> subsToClaim = [select id,name,Seats__c,Unit_Price__c,Product_Code__c,ARR_Gain__c,Tier__c,Period__c,
                                                        Paid_Months__c,Discount__c,Free_Months__c,Billing_Ids__c,Activation_Date__c
                                                    from Subscription__c 
                                                    where id in: subsIdsToClaim];
            map<String,PricebookEntry> productByCode= new map<String,PricebookEntry>();
            Id priceBook=null;
            list<String> codesWithFree=new list<String>();
            for(String code: productCodes){
                codesWithFree.add(code);
                codesWithFree.add(code+'-F');
            }
            if(opp.Pricebook2Id!=null)
                priceBook=opp.Pricebook2Id;
            system.debug('Raz Ben Ron codesWithFree:'+ codesWithFree); 

            string query='select id,name,Product2.ProductCode,Product2id,Pricebook2Id from PricebookEntry ';
            query+=' where IsActive=true and Product2.IsActive=true and Product2.ProductCode in: codesWithFree and Pricebook2.Is_Main__c=true and CurrencyIsoCode=\''+opp.CurrencyIsoCode+'\'';
            if(priceBook!=null)
                query+=' and Pricebook2Id=:priceBook';
            list<PricebookEntry> PBEs=Database.query(query);
            for(PricebookEntry pbe: PBEs){    
                productByCode.put(pbe.Product2.ProductCode,pbe);
                if(priceBook==null)
                    priceBook=pbe.Pricebook2Id;
            }
            if(opp.Pricebook2Id==null)
                opp.Pricebook2Id=priceBook;
            system.debug('Raz Ben Ron productByCode:'+ productByCode);
            for(Subscription__c sub: subsToClaim){
                system.debug('Raz Ben Ron productByCode.get(sub.Product_Code__c):'+ productByCode.get(sub.Product_Code__c));
                system.debug('Raz Ben Ron productByCode.get(sub.Product_Code__c-F):'+ productByCode.get(sub.Product_Code__c+'-F'));
                sub.Paid_Months__c=sub.Paid_Months__c==null?1:sub.Paid_Months__c;
                opportunitylineitem oli= new opportunitylineitem(Subscription__c=sub.Id,
                                                                OpportunityId=oppId,
                                                                Quantity=sub.Paid_Months__c*integer.valueof(sub.Seats__c),
                                                                Seats__c=integer.valueof(sub.Seats__c),
                                                                ARR__c=sub.ARR_Gain__c,
                                                                Tier__c=sub.Tier__c,
                                                                Plan_Period__c=sub.Period__c,
                                                                Product_Type__c='License',
                                                                PriceBookEntry=productByCode.get(sub.Product_Code__c),
                                                                PricebookEntryId=productByCode.get(sub.Product_Code__c).id,
                                                                CC_Claim_Product__c=true);
                oli.ServiceDate=sub.Activation_Date__c!=null?sub.Activation_Date__c:null;
                oli.UnitPrice=sub.Unit_Price__c!=null?sub.Unit_Price__c:0;                                                  
                oli.Discount=sub.Discount__c!=null&&sub.Discount__c>=0?sub.Discount__c:0; 
                olisToInsert.add(oli);
                opportunitylineitem freeOli=null;
                if(sub.Free_Months__c!=0&&sub.Free_Months__c!=null){
                    freeOli= new opportunitylineitem(Subscription__c=sub.Id,
                                                                OpportunityId=oppId,
                                                                Quantity=sub.Free_Months__c*integer.valueof(sub.Seats__c),
                                                                Seats__c=integer.valueof(sub.Seats__c),
                                                                ARR__c=0,
                                                                Tier__c=sub.Tier__c,
                                                                Plan_Period__c=sub.Period__c,
                                                                Product_Type__c='Free',
                                                                PriceBookEntry=productByCode.get(sub.Product_Code__c+'-F'),
                                                                PricebookEntryId=productByCode.get(sub.Product_Code__c+'-F').id,
                                                                CC_Claim_Product__c=true);
                    freeOli.ServiceDate=sub.Activation_Date__c!=null?sub.Activation_Date__c:null;
                    freeOli.UnitPrice=sub.Unit_Price__c!=null?sub.Unit_Price__c:0;                                                  
                    freeOli.Discount=sub.Discount__c!=null&&sub.Discount__c>=0?sub.Discount__c:0; 
                    olisToInsert.add(freeOli);
                }
                sub.Opportunity_Product_Id__c='Claimed';
                sub.Claimed_On_Opportunity__c=oppId;
                //sub.Is_Claimed__c=true;
                if(opp.Billing_Ids__c==null)
                    opp.Billing_Ids__c=sub.Billing_Ids__c;
                else
                    opp.Billing_Ids__c+=','+sub.Billing_Ids__c;
            }
            system.debug('Raz Ben Ron olisToInsert:'+ olisToInsert);
            system.debug('Raz Ben Ron subsToClaim:'+ subsToClaim);
            if(!test.isRunningTest()){
                if(!subsToClaim.isempty()){
                    update subsToClaim;
                    update opp;
                }
                if(!olisToInsert.isempty())
                    insert olisToInsert;
            }
            system.debug('Raz Ben Ron subsToClaim from Controller, '+subsToClaim);
            return olisToInsert;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

}