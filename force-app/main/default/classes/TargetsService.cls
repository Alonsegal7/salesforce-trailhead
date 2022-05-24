public class TargetsService {

    public static Boolean firstRunUpdateTargetsFromAcc = true;

    public void updateTargetOnAccSourceTypeChange(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        Set<Id> accountIds = new Set<Id>();
        for(Account acc: newAccounts){
            if(acc.Account_Source_Type__c != oldAccountsMap.get(acc.Id).Account_Source_Type__c){
                accountIds.add(acc.Id);
            }
        }
        if(accountIds.isEmpty()) return;
        List<Opportunity> oppsList = [select CP_Target__c from Opportunity where AccountId IN: accountIds and CP_Target__c != null and StageName = 'Closed Won' and (Transition_to_GB__c=true or Is_Potential_GB_Opportunity__c=true)];
        Set<Id> cpTargetsIds = new Set<Id>();
        for (Opportunity opp: oppsList){
            cpTargetsIds.add(opp.CP_Target__c);
        }
        if(cpTargetsIds.isEmpty()) return;
        firstRunUpdateTargetsFromAcc = false;
        System.enqueueJob(new updateTargetsArrSumQueue(cpTargetsIds));
    }

    public void updateTargetOnClosedWonOppChange(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        Set<Id> targetIds = new Set<Id>();
        Decimal arrToAdd = 0;
        for(Opportunity opp: newOpps){
            if((((opp.StageName == 'Closed Won' || oldOpps.get(opp.Id).StageName == 'Closed Won') && opp.StageName != oldOpps.get(opp.Id).StageName) 
                    || (opp.StageName == 'Closed Won' && (opp.Expected_ARR__c != oldOpps.get(opp.Id).Expected_ARR__c || opp.Claimed_ARR__c != oldOpps.get(opp.Id).Claimed_ARR__c || opp.Target__c != oldOpps.get(opp.Id).Target__c || opp.CP_Target__c != oldOpps.get(opp.Id).CP_Target__c || opp.GSI_Target__c != oldOpps.get(opp.Id).GSI_Target__c || opp.Is_Potential_GB_Opportunity__c != oldOpps.get(opp.Id).Is_Potential_GB_Opportunity__c || opp.Transition_to_GB__c != oldOpps.get(opp.Id).Transition_to_GB__c)))
                && (opp.Transition_to_GB__c || opp.Is_Potential_GB_Opportunity__c || oldOpps.get(opp.Id).Transition_to_GB__c || oldOpps.get(opp.Id).Is_Potential_GB_Opportunity__c)){
                    //update targets
                    if(opp.Target__c != null) targetIds.add(opp.Target__c);
                    if(opp.CP_Target__c != null) targetIds.add(opp.CP_Target__c);
                    if(opp.GSI_Target__c != null) targetIds.add(opp.GSI_Target__c);
                    //if target changed not from null - update old targets too
                    if(opp.Target__c != oldOpps.get(opp.Id).Target__c && oldOpps.get(opp.Id).Target__c != null){
                        targetIds.add(oldOpps.get(opp.Id).Target__c);
                    }
                    if(opp.CP_Target__c != oldOpps.get(opp.Id).CP_Target__c && oldOpps.get(opp.Id).CP_Target__c != null){
                        targetIds.add(oldOpps.get(opp.Id).CP_Target__c);
                    }
                    if(opp.GSI_Target__c != oldOpps.get(opp.Id).GSI_Target__c && oldOpps.get(opp.Id).GSI_Target__c != null){
                        targetIds.add(oldOpps.get(opp.Id).GSI_Target__c);
                    }
            }
        }
        if(targetIds.isEmpty()) return;
        if(!ApexLimits.queueableLimitReached()) System.enqueueJob(new updateTargetsArrSumQueue(targetIds));
        else updateTargetsArrSum(targetIds); //if we reached the queueable limit f.e running from batch and limit is 1 -> try to run it from same transaction (real-time)
    }

    public void updateTargetsArrSum(Set<Id> targetIds){
        Map<Id,Target__c> targetIdToAddedArrMap = new Map<Id,Target__c>();
        for(Id targetId: targetIds){
            targetIdToAddedArrMap.put(targetId, new Target__c(Id = targetId,Closed_Won_Arr__c = 0, Actual_ARR_Inbound_LIVE__c = 0, Actual_ARR_Outbound_LIVE__c = 0, Actual_ARR_Sourced_LIVE__c = 0, Actual_ARR_Influenced_LIVE__c = 0));
        }
        // query all GB closed won opps
        List<Opportunity> oppsList = [select Target__c, CP_Target__c, CP_Target__r.Partner_Company__c, GSI_Target__c, Opportunity_Origin__c, Channel_Partner__c, Green_Bucket_ARR_V2__c, Account.Account_Source_Type__c from Opportunity where (Target__c IN: targetIds or CP_Target__c IN: targetIds or GSI_Target__c IN: targetIds) and StageName = 'Closed Won' and Green_Bucket_ARR_V2__c != null and (Transition_to_GB__c = true or Is_Potential_GB_Opportunity__c=true)];
        if(!oppsList.isEmpty()) {
            for(Opportunity opp: oppsList){
                if(opp.Target__c != null && targetIdToAddedArrMap.containsKey(opp.Target__c)){
                    targetIdToAddedArrMap.get(opp.Target__c).Closed_Won_Arr__c += opp.Green_Bucket_ARR_V2__c;
                    if(opp.Account.Account_Source_Type__c == 'Inbound'){
                        targetIdToAddedArrMap.get(opp.Target__c).Actual_ARR_Inbound_LIVE__c += opp.Green_Bucket_ARR_V2__c;
                    } else if (opp.Account.Account_Source_Type__c == 'Outbound'){
                        targetIdToAddedArrMap.get(opp.Target__c).Actual_ARR_Outbound_LIVE__c += opp.Green_Bucket_ARR_V2__c; 
                    }
                }
                if(opp.CP_Target__c != null && targetIdToAddedArrMap.containsKey(opp.CP_Target__c) && opp.CP_Target__r.Partner_Company__c == opp.Channel_Partner__c){
                    targetIdToAddedArrMap.get(opp.CP_Target__c).Closed_Won_Arr__c += opp.Green_Bucket_ARR_V2__c;
                    if(opp.Account.Account_Source_Type__c == 'Inbound'){
                        targetIdToAddedArrMap.get(opp.CP_Target__c).Actual_ARR_Inbound_LIVE__c += opp.Green_Bucket_ARR_V2__c;
                    } else if (opp.Account.Account_Source_Type__c == 'Outbound'){
                        targetIdToAddedArrMap.get(opp.CP_Target__c).Actual_ARR_Outbound_LIVE__c += opp.Green_Bucket_ARR_V2__c; 
                    }
                }
                if(opp.GSI_Target__c != null && targetIdToAddedArrMap.containsKey(opp.GSI_Target__c)){
                    targetIdToAddedArrMap.get(opp.GSI_Target__c).Closed_Won_Arr__c += opp.Green_Bucket_ARR_V2__c;
                    if(opp.Opportunity_Origin__c == 'Sourced'){
                        targetIdToAddedArrMap.get(opp.GSI_Target__c).Actual_ARR_Sourced_LIVE__c += opp.Green_Bucket_ARR_V2__c;
                    } else if (opp.Opportunity_Origin__c == 'Enabled'){
                        targetIdToAddedArrMap.get(opp.GSI_Target__c).Actual_ARR_Influenced_LIVE__c += opp.Green_Bucket_ARR_V2__c; 
                    }
                }
            }
        }
        //get targtes to ignore for locked arr sum
        Datetime nowTime = Datetime.now();
        Datetime startOfMonth10UTC = Date.today().toStartOfMonth();
        startOfMonth10UTC = startOfMonth10UTC.addHours(10);
        Date startOfMonth = Date.today().toStartOfMonth();
        if(nowTime < startOfMonth10UTC) startOfMonth = startOfMonth.addMonths(-1);
        Map<Id,Target__c> targetsValidForLockedArrSum = new Map<Id,Target__c>([select Id from Target__c where Id IN: targetIds and Target_Date__c >=: startOfMonth]);
        for(Id targetId: targetIds){
            if(targetsValidForLockedArrSum.containsKey(targetId)){
                targetIdToAddedArrMap.get(targetId).Actual_ARR_Locked__c = targetIdToAddedArrMap.get(targetId).Closed_Won_Arr__c;
            }
        }
        Database.update(targetIdToAddedArrMap.values());
    }

    public class updateTargetsArrSumQueue implements Queueable{
        private Set<Id> targetIds;
    
        public updateTargetsArrSumQueue(Set<Id> targetIds){
            this.targetIds = targetIds;
        }
        public void execute(System.QueueableContext ctx) {
            TargetsService targetsServ = new TargetsService();
            targetsServ.updateTargetsArrSum(targetIds);
        }
    }

    public void updateOppsOnTargetCreation(List<Target__c> newTargets){
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Id internalOppRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Internal_Opportunity').getRecordTypeId();
        Set<Id> usersIds= new Set<Id>();
        Set<Integer> monthsSet= new Set<Integer>();
        Set<Integer> yearsSet= new Set<Integer>();
        Set<Id> partnerCompanyIds= new Set<Id>();
        Map<String,Id> targetsMap = filterTargets(newTargets, usersIds, monthsSet, yearsSet, partnerCompanyIds);
        if(targetsMap.isEmpty()) return;
        List<Opportunity> allOpps=[select Id,OwnerId,RecordTypeId,Owner_s_Manager__c,CloseDate,Owner.Contact.AccountId,GSI__c
                                    from Opportunity 
                                    WHERE (Target__c = null OR GSI_Target__c = null) AND 
                                    ((RecordTypeId =: internalOppRtId AND OwnerId in: usersIds ) or /*internal*/
                                    (RecordTypeId =: oppPartnerCompanyRtId AND Owner.Contact.AccountId in: partnerCompanyIds) or /*partners */
                                    (GSI__c in: partnerCompanyIds) or /*GSIs */
                                    (RecordTypeId =: oppPartnerCompanyRtId AND Owner_s_Manager__c in: usersIds)) /*cpms*/
                                        AND CALENDAR_MONTH(CloseDate) in: monthsSet
                                        AND CALENDAR_YEAR(CloseDate) in:yearsSet];

        if(!allOpps.isEmpty() && Batch_UpdateOppsTargets.firstRun){
            Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>(allOpps);
            Batch_UpdateOppsTargets.firstRun = false;
            Utilities.cleanFlexQueue();
            Database.executeBatch(new Batch_UpdateOppsTargets(oppsMap.keySet(), targetsMap), 20);
        }
    }
    public void updateSalesOnTargetCreation(List<Target__c> newTargets){
        try{
            Id partnerSaleRtId = Schema.SObjectType.Sale__c.getRecordTypeInfosByDeveloperName().get('Partner_Sale').getRecordTypeId();
            Id internalSaleRtId = Schema.SObjectType.Sale__c.getRecordTypeInfosByDeveloperName().get('Internal_Sale').getRecordTypeId();
            Set<Id> usersIds= new Set<Id>();
            Set<Integer> monthsSet= new Set<Integer>();
            Set<Integer> yearsSet= new Set<Integer>();
            Set<Id> partnerCompanyIds= new Set<Id>();
            Map<String,Id> targetsMap = filterTargets(newTargets, usersIds, monthsSet, yearsSet, partnerCompanyIds);
            if(targetsMap.isEmpty()) return;

            List<Sale__c> allSales=[select Id,Owner__c,RecordTypeId,Owner_s_Manager__c,Close_Date__c
                                    from Sale__c 
                                    WHERE Target__c = null AND 
                                    ((RecordTypeId=:internalSaleRtId AND Owner__c in: usersIds) or /*internal*/
                                    (RecordTypeId=:partnerSaleRtId AND Owner_s_Manager__c in: usersIds)) /*partners*/
                                        AND CALENDAR_MONTH(Close_Date__c) in: monthsSet
                                        AND CALENDAR_YEAR(Close_Date__c) in:yearsSet];

            if(!allSales.isEmpty() && Batch_UpdateSalesTargets.firstRun){
                Map<Id,Sale__c> salesMap = new Map<Id,Sale__c>(allSales);
                Batch_UpdateSalesTargets.firstRun = false;
                Utilities.cleanFlexQueue();
                Database.executeBatch(new Batch_UpdateSalesTargets(salesMap.keySet(), targetsMap), 20);
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in updateSalesOnTargetCreation ',e,e.getMessage());   
        }
    }

    public void TargetsServiceOnSales(List<Sale__c> newSales, Map<Id, Sale__c> oldSales){
        List<Sale__c> salesToUpdate = new List<Sale__c>();
        Set<String> userIdDateTargetKeys = new Set<String>();
        Id salePartnerRecordId = Schema.SObjectType.Sale__c.getRecordTypeInfosByDeveloperName().get('Partner_Sale').getRecordTypeId();
        try{
            String key = '';
            for(Sale__c sale : newSales){
                if(oldSales == null || oldSales.get(sale.Id).Close_Date__c != sale.Close_Date__c || oldSales.get(sale.Id).Owner__c != sale.Owner__c|| oldSales.get(sale.Id).Owner_s_Manager__c != sale.Owner_s_Manager__c){
                    if(sale.Close_Date__c == null || sale.Owner__c == null){
                        sale.Target__c = null;
                        continue;
                    }
                    if(sale.RecordTypeId == salePartnerRecordId && sale.Owner_s_Manager__c != null){ 
                        key = getUniqueueKey(sale.Owner_s_Manager__c, sale.Close_Date__c);
                    } else {
                        key = getUniqueueKey(sale.Owner__c, sale.Close_Date__c);
                    }
                    userIdDateTargetKeys.add(key);
                    salesToUpdate.add(sale);
                }
            }
            Map<String,Id> targetsMap = getTargetsMap(userIdDateTargetKeys, null);
            for(Sale__c sale : salesToUpdate){
                if(sale.RecordTypeId == salePartnerRecordId && sale.Owner_s_Manager__c != null){
                    key = getUniqueueKey(sale.Owner_s_Manager__c, sale.Close_Date__c);
                } else {
                    key = getUniqueueKey(sale.Owner__c, sale.Close_Date__c);
                }
                if(targetsMap.containsKey(key)){
                    sale.Target__c = targetsMap.get(key);
                } else {
                    sale.Target__c = null;
                }
            }
        } catch(Exception e){
            Utilities.sendDebugEmail('Error in TargetsServiceOnSales: ', e, e.getMessage());   
        }
    }

    public void TargetsServiceOnOpps(List<Opportunity> newOpps, Map<Id, Opportunity> oldOpps){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<Id,Date> userIdsForPartnerCompanyQuery = new Map<Id,Date>();
        Map<Id,Id> userIdToPartnerCompanyMap = new Map<Id,Id>();
        Set<String> userIdDateTargetKeys = new Set<String>();
        Set<String> partnerCompanyDateTargetKeys = new Set<String>();
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();

        try{
            String key = '';
            for(Opportunity opp : newOpps){
                if(
                    oldOpps == null || 
                    oldOpps.get(opp.Id).CloseDate != opp.CloseDate || //close date change
                    oldOpps.get(opp.Id).OwnerId != opp.OwnerId || //owner change
                    oldOpps.get(opp.Id).Owner_s_Manager__c != opp.Owner_s_Manager__c || //cpm change
                    (oldOpps.get(opp.Id).GSI__c == null && opp.GSI__c != null) || //GSI assignment
                    oldOpps.get(opp.Id).GSI__c != opp.GSI__c || //GSI change
                    (opp.Manual_Trigger__c == 'Link Target' && oldOpps.get(opp.Id).Manual_Trigger__c != opp.Manual_Trigger__c)) //manual trigger
                    {
                        //is the opportunity valid for target?
                        if(opp.CloseDate == null || opp.OwnerId == null){
                            opp.Target__c = null;
                            opp.CP_Target__c = null;
                            continue;
                        }
                        //partner opportunity
                        if(opp.RecordTypeId == oppPartnerCompanyRtId){
                            if(opp.Owner_s_Manager__c != null) {
                                key = getUniqueueKey(opp.Owner_s_Manager__c, opp.CloseDate);
                            } else {
                                key = getUniqueueKey(opp.OwnerId, opp.CloseDate);
                            }
                            userIdsForPartnerCompanyQuery.put(opp.OwnerId, opp.CloseDate);
                        } 
                        //internal opportunity
                        else {
                            key = getUniqueueKey(opp.OwnerId, opp.CloseDate);
                        }
                        userIdDateTargetKeys.add(key);
                        oppsToUpdate.add(opp);
                        if(opp.Manual_Trigger__c == 'Link Target') opp.Manual_Trigger__c = '';
                        
                        //GSI target
                        if (opp.GSI__C != null) {
                            partnerCompanyDateTargetKeys.add(getUniqueueKey(opp.GSI__c, opp.CloseDate));
                        }
                    }
            }
            if(oppsToUpdate.isEmpty()) return;
            //map users to partner companies and create a map of the company id to the target date
            if(!userIdsForPartnerCompanyQuery.isEmpty()){
                for(User userRec: [select Contact.AccountId from User where Id IN: userIdsForPartnerCompanyQuery.keySet()]){
                    if(userRec.Contact.AccountId != null) {
                        userIdToPartnerCompanyMap.put(userRec.Id, userRec.Contact.AccountId);
                        partnerCompanyDateTargetKeys.add(getUniqueueKey(userRec.Contact.AccountId, userIdsForPartnerCompanyQuery.get(userRec.Id)));
                    }
                }
            }
            
            Map<String,Id> targetsMap = getTargetsMap(userIdDateTargetKeys, partnerCompanyDateTargetKeys);
    
            for(Opportunity opp: oppsToUpdate){
                //target
                if(opp.RecordTypeId == oppPartnerCompanyRtId && opp.Owner_s_Manager__c != null){
                    key = getUniqueueKey(opp.Owner_s_Manager__c, opp.CloseDate);
                } else {
                    key = getUniqueueKey(opp.OwnerId, opp.CloseDate);
                }
                if(targetsMap.containsKey(key)){
                    opp.Target__c = targetsMap.get(key);
                } else {
                    opp.Target__c = null;
                }
                //cp target
                if(opp.RecordTypeId == oppPartnerCompanyRtId && userIdToPartnerCompanyMap.containsKey(opp.OwnerId)){
                    key = getUniqueueKey(userIdToPartnerCompanyMap.get(opp.OwnerId), opp.CloseDate);
                    if(targetsMap.containsKey(key)){
                        opp.CP_Target__c = targetsMap.get(key);
                    } else {
                        opp.CP_Target__c = null;
                    }
                } else if (opp.CP_Target__c != null){
                    opp.CP_Target__c = null;
                }
                //GSI target
                if(opp.GSI__c != null){
                    key = getUniqueueKey(opp.GSI__c, opp.CloseDate);
                    if(targetsMap.containsKey(key)){
                        opp.GSI_Target__c = targetsMap.get(key);
                    } else {
                        opp.GSI_Target__c = null;
                    }
                } else if (opp.GSI_Target__c != null){
                    opp.GSI_Target__c = null;
                }
            }
        } catch(Exception e){
            Utilities.sendDebugEmail('Error in TargetsServiceOnOpps: ', e, e.getMessage());   
        }
    }

    public void setTargetUniqueKeys(List<Target__c> newTargets, Map<Id, Target__c> oldTargetsMap){
        for(Target__c targetRec: newTargets){
            if(targetRec.Target_Date__c != null && (targetRec.User__c != null || targetRec.Partner_Company__c != null) && (oldTargetsMap == null || targetRec.Target_Date__c != oldTargetsMap.get(targetRec.Id).Target_Date__c || targetRec.User__c != oldTargetsMap.get(targetRec.Id).User__c || targetRec.Partner_Company__c != oldTargetsMap.get(targetRec.Id).Partner_Company__c)){
                if(targetRec.User__c != null){
                    targetRec.User_Id_Date_Unique_Key__c = getUniqueueKey(targetRec.User__c, targetRec.Target_Date__c);
                }
                if(targetRec.Partner_Company__c != null){
                    targetRec.Partner_Company_Date_Unique_Key__c = getUniqueueKey(targetRec.Partner_Company__c, targetRec.Target_Date__c);
                }
            }
        }
    }

    private Map<String,Id> getTargetsMap(Set<String> userIdDateTargetKeys, Set<String> partnerCompanyDateTargetKeys){
        String query = 'select Id, User__c, Partner_Company__c, Target_Date__c, User_Id_Date_Unique_Key__c, Partner_Company_Date_Unique_Key__c from Target__c where User_Id_Date_Unique_Key__c IN: userIdDateTargetKeys';
        if(partnerCompanyDateTargetKeys != null && !partnerCompanyDateTargetKeys.isEmpty()){
            query += ' or Partner_Company_Date_Unique_Key__c IN: partnerCompanyDateTargetKeys';
        }
        List<Target__c> targetsList = Database.query(query);
        Map<String,Id> targetsMap = new Map<String,Id>();
        for(Target__c targetRec: targetsList){
            if(targetRec.User_Id_Date_Unique_Key__c != null) targetsMap.put(targetRec.User_Id_Date_Unique_Key__c, targetRec.Id);
            if(targetRec.Partner_Company_Date_Unique_Key__c != null) targetsMap.put(targetRec.Partner_Company_Date_Unique_Key__c, targetRec.Id);
        }
        return targetsMap;
    }

    public String getUniqueueKey(Id objectId, Date closeDate){
        String res = objectId + String.valueOf(closeDate.year()) + String.valueOf(closeDate.month());
        return res;
    }

    private Map<String,Id> filterTargets(List<Target__c> newTargets, Set<Id> usersIds, Set<Integer> monthsSet, Set<Integer> yearsSet, Set<Id> partnerCompanyIds){
        Map<String,Id> targetsMap = new Map<String,Id>();
        String key = '';
        for(Target__c targetRec : newTargets){
            if((targetRec.User__c != null || targetRec.Partner_Company__c != null) && targetRec.Target_Date__c != null){
                monthsSet.add(targetRec.Target_Date__c.month());
                yearsSet.add(targetRec.Target_Date__c.year());
                if(targetRec.User__c != null){
                    usersIds.add(targetRec.User__c);
                    key = getUniqueueKey(targetRec.User__c, targetRec.Target_Date__c);
                }
                if(targetRec.Partner_Company__c != null){
                    partnerCompanyIds.add(targetRec.Partner_Company__c);
                    key = getUniqueueKey(targetRec.Partner_Company__c, targetRec.Target_Date__c);
                }
                targetsMap.put(key, targetRec.Id);
            }
        }
        return targetsMap;
    }
}