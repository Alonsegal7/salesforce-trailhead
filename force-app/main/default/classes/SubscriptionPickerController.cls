public without sharing class SubscriptionPickerController {
    public static boolean IsSandbox = [Select IsSandbox from Organization].IsSandbox;
    @AuraEnabled(cacheable=true)
    public static map<Id,Subscription__c> getSubscriptions(String oppId){
        Id CSRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CS_Opportunity').getRecordTypeId();
        try{
            Opportunity opp=[select id,Type,AccountId,RecordTypeId from Opportunity where id=:oppId][0];
            Id oppAccId=opp.AccountId;
            Id opptyId=opp.Id;
            //CS Renewal Opp will only take the renewal subscription for claiming
            string query='select id,name,Seats__c,ARR__c, Product_Code__c,Name_for_CC_Claim__c, Name_for_CC_Claim_Full_ARR__c,Claimed_On_Opportunity__r.Co_Sell_Opportunity__c,Is_Claimed__c,ARR_Gain__c,Period__c from Subscription__c where Monday_Account__c=:oppAccId';
            if (opp.RecordTypeId==CSRecordType && opp.Type.contains('Renewal')) {
                query+=' and Is_Claimed__c=false and Status__c=\'ACTIVE\'' + 'and Payment_Method__c like \'%BLUESNAP%\' order by Activation_Date__c';
            }
            else {
                query+=' and (Is_Claimed__c=false or (Claimed_On_Opportunity__r.Co_Sell_Opportunity__c=:opptyId AND Claimed_On_Opportunity_Co_Sell__c=NULL)) and Status__c!=\'DELETED\'' + 
                'and (Payment_Method__c like \'%BLUESNAP%\' or Include_In_CC_Claim__c=true) order by Activation_Date__c';
            }
            system.debug('query'+query);

                Map<Id, Subscription__c> subs = new Map<Id, Subscription__c>((List<Subscription__c>)Database.query(query));
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
            map<Id,Subscription__c> subs=new map<Id,Subscription__c>([select id,ARR__c, Name_for_CC_Claim_Full_ARR__c,name,Seats__c,Product_Code__c,Period__c,Name_for_CC_Claim__c,Is_Claimed__c,ARR_Gain__c,Tier__c
                                        from Subscription__c 
                                        where Monday_Account__c=:opp.AccountId And
                                        (Claimed_On_Opportunity__c=:oppId OR Claimed_On_Opportunity_Co_Sell__c=:oppId) And
                                        Is_Claimed__c=true
                                        order by Activation_Date__c]);
            system.debug('Raz Ben Ron currentCon from Controller, '+subs);
            return subs;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static list<Subscription__c> getMASubs(String oppId){
        try{
            Opportunity opp=[select id,AccountId from Opportunity where id=:oppId][0];
            //get all subscriptions from related monday account (regardless if they are related to the opportunity)
            list<Subscription__c> maSubs=new list<Subscription__c>([select id,name,Seats__c,Product_Code__c,Period__c,Name_for_CC_Claim__c,Is_Claimed__c,ARR_Gain__c,Tier__c
                                        from Subscription__c 
                                        where Monday_Account__c=:opp.AccountId
                                        order by Activation_Date__c]);
            return maSubs;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<opportunitylineitem> claimSubs(list<String> subsIdsToClaim, String oppId, list<String> productCodes){
        try{
            system.debug('Raz Ben Ron oppId from Controller, '+oppId);
            Opportunity opp=[select id,Pricebook2Id,Billing_Ids__c,CurrencyIsoCode,Expected_Plan_Tier__c,Expected_Plan_Period__c,Expected_Plan_Seats__c,
                                Is_Primary_SO_Signed__c,Last_Claimed_Subscription__c
                                from Opportunity where id=:oppId][0];
            List<Opportunitylineitem> olisToInsert= new List<Opportunitylineitem>();
            List<Subscription__c> subsToClaim = [select id,ARR__c,name,Seats__c,Unit_Price__c,Product_Code__c,ARR_Gain__c,Tier__c,Period__c,
                                                        Paid_Months__c,Discount__c,Free_Months__c,Billing_Ids__c,Activation_Date__c,Is_Claimed__c,
                                                        Claimed_On_Opportunity__c,Claimed_On_Opportunity__r.Co_Sell_Opportunity__c
                                                    from Subscription__c 
                                                    where id in: subsIdsToClaim
                                                    order by Activation_Date__c desc];
            Set<id> claimedSubsFromOlis = new Set<id>();
            for(Opportunitylineitem oli: [select id,Subscription__c
                                        from Opportunitylineitem 
                                        where OpportunityId=:oppId and CC_Claim_Product__c=true and Subscription__c!=null]){
                claimedSubsFromOlis.add(oli.Subscription__c);  
                system.debug('Raz Ben Ron oli.Subscription__c:'+ oli.Subscription__c);                                           
            }
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
            system.debug('Raz Ben Ron claimedSubsFromOlis:'+ claimedSubsFromOlis);
            
            //connect to lates claimed subscription
            Subscription__c latestSub=getLatestClaimedSub(oppId,subsIdsToClaim,null);
            if(opp.Last_Claimed_Subscription__c!=latestSub.Id)
                opp.Last_Claimed_Subscription__c=latestSub.Id;

            for(Subscription__c sub: subsToClaim){
                system.debug('Raz Ben Ron sub id:'+ sub.Id);
                if(!claimedSubsFromOlis.contains(sub.Id)){//prevent duplications subscription claiming, allow to create each sub only once
                    system.debug('Raz Ben Ron productByCode.get(sub.Product_Code__c):'+ productByCode.get(sub.Product_Code__c));
                    system.debug('Raz Ben Ron productByCode.get(sub.Product_Code__c-F):'+ productByCode.get(sub.Product_Code__c+'-F'));
                    sub.Paid_Months__c=sub.Paid_Months__c==null||sub.Paid_Months__c==0?1:sub.Paid_Months__c;
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
                            sub.Claimed_By_Co_Sell__c=UserInfo.getUserId();
                            sub.Claim_Date_Co_Sell__c=datetime.now();
                            oli.Co_Sell_Product__c=true;
                            if(freeOli!=null)
                                freeOli.Co_Sell_Product__c=true;
                        }
                    }else{
                        sub.Claimed_On_Opportunity__c=oppId;
                        sub.Claimed_By_Main__c=UserInfo.getUserId();
                        sub.Claim_Date_Main__c=datetime.now();
                    }
                    if(opp.Billing_Ids__c==null)
                        opp.Billing_Ids__c=sub.Billing_Ids__c;
                    else
                        opp.Billing_Ids__c+=','+sub.Billing_Ids__c;
                    //if(IsSandbox)//update from BB in production only
                    sub.Is_Claimed__c=true;
                }else{
                    system.debug('Raz Ben Ron duplication prevented for subscription:'+ sub.id);
                }
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
            Opportunity opp=[select id,Billing_Ids__c,Last_Claimed_Subscription__c from Opportunity where id=:oppId][0];
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
                    sub.Claimed_By_Main__c=null;
                    sub.Claim_Date_Main__c=null;
                }else if (sub.Claimed_On_Opportunity_Co_Sell__c==oppId){
                    sub.Claimed_On_Opportunity_Co_Sell__c=null;
                    sub.Claimed_By_Co_Sell__c=null;
                    sub.Claim_Date_Co_Sell__c=null;
                    
                }
                //mark as unclaimed only if not claimed on any opportunity (main or co-sell)
                if(sub.Claimed_On_Opportunity__c==null&&sub.Claimed_On_Opportunity_Co_Sell__c==null){
                    sub.Opportunity_Product_Id__c=null;
                    sub.Is_Claimed__c=false;
                }
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

            //connect to lates claimed subscription
            Subscription__c latestSub=getLatestClaimedSub(oppId,null,subsToUnclaim);
            if(latestSub==null)//if all subscriptions are unclaimed
                opp.Last_Claimed_Subscription__c=null;
            else if(opp.Last_Claimed_Subscription__c!=latestSub.Id)
                opp.Last_Claimed_Subscription__c=latestSub.Id;

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

    @AuraEnabled()
    public static Subscription__c getLatestPlan(list<String> subsIdsToClaim, String oppId){
        try{
            Opportunity opp=[select id,Expected_Plan_Tier__c,Expected_Plan_Period__c,Expected_Plan_Seats__c,Is_Primary_SO_Signed__c
                                from Opportunity where id=:oppId][0];
            List<Opportunitylineitem> olisToInsert= new List<Opportunitylineitem>();
            /*List<Subscription__c> subsToClaim = [select id,Plan_Name__c,Seats__c,Tier__c,Period__c,Activation_Date__c
                                                    from Subscription__c 
                                                    where id in: subsIdsToClaim or Claimed_On_Opportunity__c=:opp.Id or Claimed_On_Opportunity_Co_Sell__c=:opp.id
                                                    order by Activation_Date__c desc];

            Subscription__c latestSub=subsToClaim[0];//subs sorted by activation date*/
            Subscription__c latestSub=getLatestClaimedSub(oppId,subsIdsToClaim,null);
            system.debug('Raz Ben Ron latest sub Plan: '+latestSub.Tier__c+' '+latestSub.Seats__c+' '+latestSub.Period__c);
            system.debug('Raz Ben Ron opp Plan: '+opp.Expected_Plan_Tier__c+' '+opp.Expected_Plan_Seats__c+' '+opp.Expected_Plan_Period__c);
            if(!opp.Is_Primary_SO_Signed__c&&
                (opp.Expected_Plan_Tier__c==null||opp.Expected_Plan_Seats__c==null||opp.Expected_Plan_Period__c==null||
                latestSub.Tier__c.toLowercase()!=opp.Expected_Plan_Tier__c.toLowercase()||
                integer.valueof(latestSub.Seats__c)!=opp.Expected_Plan_Seats__c||
                latestSub.Period__c.toLowercase()!=opp.Expected_Plan_Period__c.toLowercase())){
                return latestSub;
            }else{
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled()
    public static void updateOppPlan(Subscription__c sub, String oppId){
        try{
            Opportunity opp=new Opportunity(Id=oppId,Expected_Plan_Tier__c=Utilities.setFirstLetterUpper(sub.Tier__c),
                                                        Expected_Plan_Seats__c=integer.valueof(sub.Seats__c),
                                                        Expected_Plan_Period__c=Utilities.setFirstLetterUpper(sub.Period__c),
                                                        Expected_Plan_Name__c=Utilities.setPlanName(sub.Tier__c,string.valueof(decimal.valueof(sub.Seats__c).round()),sub.Period__c),
                                                        Plan_Updated_From_Subscription__c=sub.id);
            update opp;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Subscription__c getLatestClaimedSub(String oppId, list<String> subsIdsToClaim, list<String> subsToUnclaim){
        string query='select id,Plan_Name__c,Seats__c,Tier__c,Period__c,Activation_Date__c from Subscription__c ';
        query+=' where (Claimed_On_Opportunity__c=:oppId or Claimed_On_Opportunity_Co_Sell__c=:oppid) ';
        if(subsIdsToClaim!=null)
            query+=' or id in: subsIdsToClaim ';
        if(subsToUnclaim!=null)
            query+=' and id not in: subsToUnclaim ';
        query+=' order by Activation_Date__c desc limit 1';

        List<Subscription__c> claimedSubs=Database.query(query);
        if(claimedSubs.size()>0)
            return claimedSubs[0];
        else
            return null;

    }
    
}