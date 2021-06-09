public without sharing class SubscriptionPickerController {
    public static boolean IsSandbox = [Select IsSandbox from Organization].IsSandbox;
    @AuraEnabled(cacheable=true)
    public static map<Id,Subscription__c> getSubscriptions(String oppId){
        try{
            Opportunity opp=[select id,AccountId from Opportunity where id=:oppId][0];
            map<Id,Subscription__c> subs=new map<Id,Subscription__c>([select id,name,Seats__c,Product_Code__c,Name_for_CC_Claim__c,
                                        Claimed_On_Opportunity__r.Co_Sell_Opportunity__c,Is_Claimed__c,ARR_Gain__c
                                        from Subscription__c 
                                        where Monday_Account__c=:opp.AccountId and 
                                        (Is_Claimed__c=false OR (Claimed_On_Opportunity__r.Co_Sell_Opportunity__c=:Opp.Id AND Claimed_On_Opportunity_Co_Sell__c=NULL)) 
                                        and Status__c!='DELETED' and (Payment_Method__c LIKE '%BLUESNAP%' or Include_In_CC_Claim__c=true)
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
            map<Id,Subscription__c> subs=new map<Id,Subscription__c>([select id,name,Seats__c,Product_Code__c,Period__c,Name_for_CC_Claim__c,Is_Claimed__c,ARR_Gain__c
                                        from Subscription__c 
                                        where Monday_Account__c=:opp.AccountId And
                                        (Claimed_On_Opportunity__c=:oppId OR Claimed_On_Opportunity_Co_Sell__c=:oppId) And
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
                                                        Paid_Months__c,Discount__c,Free_Months__c,Billing_Ids__c,Activation_Date__c,Is_Claimed__c,
                                                        Claimed_On_Opportunity__c,Claimed_On_Opportunity__r.Co_Sell_Opportunity__c
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
                
                opportunitylineitem oli=Utilities.createOLIfromSubscription(oppId,sub,productByCode.get(sub.Product_Code__c),false);
                olisToInsert.add(oli);
                opportunitylineitem freeOli=null;
                if(sub.Free_Months__c!=0&&sub.Free_Months__c!=null){
                    freeOli=Utilities.createOLIfromSubscription(oppId,sub,productByCode.get(sub.Product_Code__c+'-F'),true);
                    olisToInsert.add(freeOli);
                }
                sub.Opportunity_Product_Id__c='Claimed';
                if(sub.Claimed_On_Opportunity__c!=null){//already claimed on another opp, connect to co sell opp
                    if(sub.Claimed_On_Opportunity__r.Co_Sell_Opportunity__c==Opp.Id){
                        sub.Claimed_On_Opportunity_Co_Sell__c=oppId;
                        oli.Co_Sell_Product__c=true;
                        if(freeOli!=null)
                            freeOli.Co_Sell_Product__c=true;
                    }
                }else{
                    sub.Claimed_On_Opportunity__c=oppId;
                }
                if(opp.Billing_Ids__c==null)
                    opp.Billing_Ids__c=sub.Billing_Ids__c;
                else
                    opp.Billing_Ids__c+=','+sub.Billing_Ids__c;
                if(IsSandbox)//update from BB in production only
                    sub.Is_Claimed__c=true;
            }
            system.debug('Raz Ben Ron opp.Billing_Ids__c on claim:'+ opp.Billing_Ids__c);
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

    @AuraEnabled()
    public static map<Id,Subscription__c> uncliamSubscriptions(list<String> subsToUnclaim,String oppId){
        try{
            system.debug('Raz Ben Ron subsToUnclaim from Controller, '+subsToUnclaim);
            Opportunity opp=[select id,Billing_Ids__c from Opportunity where id=:oppId][0];
            list<Subscription__c> subs=[select id,Billing_Ids__c,Claimed_On_Opportunity__c,Claimed_On_Opportunity_Co_Sell__c,ARR_Gain__c,Name_for_CC_Claim__c from Subscription__c where Id in: subsToUnclaim];
            system.debug('Raz Ben Ron subs from Controller, '+subs);
            ///handle delete OLIs
            list<Opportunitylineitem> olis= [select id from Opportunitylineitem where Subscription__c in: subs];
            for(Opportunitylineitem oli: olis){
                oli.Force_Delete__c=true;
            }
            system.debug('Raz Ben Ron opp.Billing_Ids__c: '+opp.Billing_Ids__c);
            String billingIdsTemp=opp.Billing_Ids__c;
            for(Subscription__c sub: subs){
                ///disconnect subscription from opportunity
                if(sub.Claimed_On_Opportunity__c==oppId){
                    sub.Claimed_On_Opportunity__c=null;
                }else if (sub.Claimed_On_Opportunity_Co_Sell__c==oppId){
                    sub.Claimed_On_Opportunity_Co_Sell__c=null;
                }
                sub.Opportunity_Product_Id__c=null;
                sub.Is_Claimed__c=false;
                ///remove id from Billing ids on oppotunity
                list<string> billIds=sub.Billing_Ids__c.split(',');
                if(billingIdsTemp!=null){
                    for(String bId: billIds){
                        integer index=billingIdsTemp.indexof(bId);
                        if(index>=0){//if id found
                            integer idLen=bId.length();
                            integer fullBillingIdsLen=billingIdsTemp.length();
                            billingIdsTemp=billingIdsTemp.substring(0,index)+billingIdsTemp.substring(math.min(index+idlen+1,fullBillingIdsLen),fullBillingIdsLen);
                        }
                    }
                }
            }
            system.debug('Raz Ben Ron olis: '+olis);
            opp.Billing_Ids__c=billingIdsTemp;
            if(!olis.isEmpty()){
                update olis;
                delete olis;
            }
            if(!subs.isEmpty()){
                update subs;
            }
            update opp;
            Utilities.sendEmail('Finished Subscription Removal in SubscriptionPickerController ','Subscriptions: '+subs+'<br/> Opp Id: '+opp.Id,new list<String>{label.SystemNotificationsDL});
            //preformUpdatesInFuture(Json.serialize(olis),Json.serialize(opp),Json.serialize(subs));
            return getClaimed(oppId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static User getUserDetails(String userId){
        try{
            User user=[select id,ProfileId,Profile.Name,IsPortalEnabled from User where id=:userId limit 1][0];
            return user;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled()
    public static Account updateMondayAccount(String maId){
        try{
            system.debug('Raz Ben Ron maId: '+maId);
            Account ma=[select id from Account where id=:maId];
            if(ma!=null){
                ma.Force_Subscriptions_Sync__c=true;
                update ma;
                return ma;
            }else {
                return null;
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*@future
    public static void preformUpdatesInFuture(String olisToDelete, String oppToUpdate, String subsToUpdate){
        list<Opportunitylineitem>  olis = (list<Opportunitylineitem> ) JSON.deserialize(olisToDelete, list<Opportunitylineitem>.class);
        update olis;
        delete olis;
        list<Subscription__c>  subs = (list<Subscription__c> ) JSON.deserialize(subsToUpdate, list<Subscription__c>.class);
        update subs;
        Opportunity  opp = (Opportunity) JSON.deserialize(oppToUpdate, Opportunity.class);
        update opp;
        Utilities.sendEmail('Finished Subscription Removal in SubscriptionPickerController ','Subscriptions: '+subs+'<br/> Opp Id: '+opp.Id,new list<String>{label.SystemNotificationsDL});
   

    }*/
}