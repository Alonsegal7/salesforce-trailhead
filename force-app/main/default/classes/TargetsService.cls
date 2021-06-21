public class TargetsService {
    public void updateSalesOnTargetCreation(list<Target__c> targets){
        try{
            set<Id> usersIds= new set<Id>();
            set<Integer> monthsSet= new set<Integer>();
            set<Integer> yearsSet= new set<Integer>();
            set<Id> partnerCompanyIds= new set<Id>();
            for(Target__c target : targets){
                usersIds.add(target.User__c);
                monthsSet.add(target.Target_Date__c.month());
                yearsSet.add(target.Target_Date__c.year());
                if(target.Partner_Company__c!=null)
                    partnerCompanyIds.add(target.Partner_Company__c);
            }
            system.debug('Raz Ben Ron usersIds: '+usersIds);
            system.debug('Raz Ben Ron partnerCompanyIds: '+partnerCompanyIds);
            system.debug('Raz Ben Ron monthsSet: '+monthsSet);
            system.debug('Raz Ben Ron yearsSet: '+yearsSet);
            list<Sale__c> allSales=[select Id,Owner__c,RecordTypeId,Owner_s_Manager__c,Close_Date__c
                                    from Sale__c 
                                    WHERE Target__c = null AND 
                                    ((RecordTypeId='0121t000000IQYOAA4' AND Owner__c in: usersIds) or /*internal*/
                                    (RecordTypeId='0121t000000IQYTAA4' AND Owner_s_Manager__c in: usersIds)) /*partners*/
                                        AND CALENDAR_MONTH(Close_Date__c) in: monthsSet
                                        AND CALENDAR_YEAR(Close_Date__c) in:yearsSet];
            list<Opportunity> allOpps=[select Id,OwnerId,RecordTypeId,Owner_s_Manager__c,CloseDate,Owner.Contact.AccountId
                                        from Opportunity 
                                        WHERE Target__c = null AND 
                                        ((RecordTypeId='0121t000000LucvAAC' AND OwnerId in: usersIds ) or /*internal*/
                                        (RecordTypeId='0121t000000IQUbAAO' AND Owner.Contact.AccountId in: partnerCompanyIds) or /*partners */
                                        (RecordTypeId='0121t000000IQUbAAO' AND Owner_s_Manager__c in: usersIds)) /*cpms*/
                                            AND CALENDAR_MONTH(CloseDate) in: monthsSet
                                            AND CALENDAR_YEAR(CloseDate) in:yearsSet];
            system.debug('Raz Ben Ron allSales: '+allSales.size());
            system.debug('Raz Ben Ron allOpps: '+allOpps.size());
            list<Sale__c> salesToUpdate=new list<Sale__c>();
            map<Id,Opportunity> oppsToUpdate=new map<Id,Opportunity>();
            for(Target__c target : targets){
                if(target.User__c != null && target.Target_Date__c != null){
                    for(Sale__c sale: allSales){
                        if(((sale.RecordTypeId=='0121t000000IQYOAA4' && sale.Owner__c==target.User__c ) || /*internal*/
                        (sale.RecordTypeId=='0121t000000IQYTAA4' && sale.Owner_s_Manager__c==target.User__c)) /*partners*/
                            && sale.Close_Date__c.month() == target.Target_Date__c.month()
                            && sale.Close_Date__c.year() == target.Target_Date__c.year()){
                            sale.Target__c=target.Id;
                            salesToUpdate.add(sale);
                        }
                    }
                }
                for(Opportunity opp: allOpps){
                    system.debug('Raz Ben Ron target.Target_Date__c.month(): '+target.Target_Date__c.month());
                    system.debug('Raz Ben Ron target.Target_Date__c.year(): '+target.Target_Date__c.year());
                    if(opp.CloseDate.month() == target.Target_Date__c.month()
                    && opp.CloseDate.year() == target.Target_Date__c.year()){
                        system.debug('Raz Ben Ron in dates condition');
                        if((target.Partner_Company__c==null&&
                        opp.RecordTypeId=='0121t000000LucvAAC' && opp.OwnerId==target.User__c ) || /*internal*/
                            (opp.RecordTypeId=='0121t000000IQUbAAO' && opp.Owner_s_Manager__c==target.User__c)){
                            if(oppsToUpdate.containskey(opp.Id)){
                                oppsToUpdate.get(opp.Id).Target__c=target.Id;
                            }else{
                                oppsToUpdate.put(opp.Id,new Opportunity(id=opp.id,Target__c=target.Id));
                            }
                        }
                        system.debug('Raz Ben Ron target.Partner_Company__c: '+target.Partner_Company__c);
                        system.debug('Raz Ben Ron opp.Owner.Contact.AccountId: '+opp.Owner.Contact.AccountId);
                        system.debug('Raz Ben Ron opp.RecordTypeId: '+opp.RecordTypeId);
                        if(target.Partner_Company__c!=null&&
                            opp.RecordTypeId=='0121t000000IQUbAAO' && opp.Owner.Contact.AccountId == target.Partner_Company__c){
                            system.debug('Raz Ben Ron in partners condition');
                            if(oppsToUpdate.containskey(opp.Id)){
                                oppsToUpdate.get(opp.Id).CP_Target__c=target.Id;
                            }else{
                                oppsToUpdate.put(opp.Id,new Opportunity(id=opp.id,CP_Target__c=target.Id));
                            }
                        }
                    }   
                }
            }
            if(salesToUpdate.size() > 0){
                update salesToUpdate;    
            }
            system.debug('Raz Ben Ron oppsToUpdate: '+oppsToUpdate.values());
            if(oppsToUpdate.values().size() > 0){
                update oppsToUpdate.values();    
            }
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in updateSalesOnTargetCreation ',e,e.getMessage());   
        }
    }

    public void TargetsServiceOnSales(List<Sale__c> newSales, map <Id, Sale__c> oldSales){
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

    public void TargetsServiceOnOpps(List<Opportunity> newOpps, map <Id, Opportunity> oldOpps){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Set<Id> userIds = new Set<Id>();
        Map<Id,Date> userIdsForPartnerCompanyQuery = new Map<Id,Date>();
        Map<Id,Id> userIdToPartnerCompanyMap = new Map<Id,Id>();
        Set<Integer> yearsSet = new Set<Integer>();
        Set<Integer> monthsSet = new Set<Integer>();
        Set<String> userIdDateTargetKeys = new Set<String>();
        Set<String> partnerCompanyDateTargetKeys = new Set<String>();
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();

        try{
            String key = '';
            for(Opportunity opp : newOpps){
                if(oldOpps == null || oldOpps.get(opp.Id).CloseDate != opp.CloseDate || oldOpps.get(opp.Id).OwnerId != opp.OwnerId || oldOpps.get(opp.Id).Owner_s_Manager__c != opp.Owner_s_Manager__c){
                    if(opp.CloseDate == null || opp.OwnerId == null){
                        opp.Target__c = null;
                        opp.CP_Target__c = null;
                        continue;
                    }
                    if(opp.RecordTypeId == oppPartnerCompanyRtId){
                        if(opp.Owner_s_Manager__c != null) {
                            key = getUniqueueKey(opp.Owner_s_Manager__c, opp.CloseDate);
                        } else {
                            key = getUniqueueKey(opp.OwnerId, opp.CloseDate);
                        }
                        userIdsForPartnerCompanyQuery.put(opp.OwnerId, opp.CloseDate);
                    } else {
                        key = getUniqueueKey(opp.OwnerId, opp.CloseDate);
                    }
                    userIdDateTargetKeys.add(key);
                    oppsToUpdate.add(opp);
                }
            }
            if(oppsToUpdate.isEmpty()) return;
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
            }
        } catch(Exception e){
            Utilities.sendDebugEmail('Error in TargetsServiceOnOpps: ', e, e.getMessage());   
        }
    }

    public void setTargetUniqueKeys(List<Target__c> newTargets, map <Id, Target__c> oldTargetsMap){
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

    private String getUniqueueKey(Id objectId, Date closeDate){
        String res = objectId + String.valueOf(closeDate.year()) + String.valueOf(closeDate.month());
        return res;
    }
}