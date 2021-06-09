public class TargetsService {
    public static void updateSalesOnTargetCreation(list<Target__c> targets){
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
                //if(target.Partner_Company__c==null){//AEs/AMs/CPMs
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
                        //boolean tobeupdated=false;
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
                    /*Sale__c[] sales = [select Id 
                                        from Sale__c 
                                        WHERE Target__c = null AND 
                                        ((RecordTypeId='0121t000000IQYOAA4' AND Owner__c=:target.User__c ) or /*internal*/
                                        /*(RecordTypeId='0121t000000IQYTAA4' AND Owner_s_Manager__c=:target.User__c)) /*partners*/
                                            /*AND CALENDAR_MONTH(Close_Date__c) = :target.Target_Date__c.month()
                                            AND CALENDAR_YEAR(Close_Date__c) = :target.Target_Date__c.year()];*/
                    
                    /*if(sales.size() > 0){
                        for(Sale__c sale : sales){
                            sale.Target__c = target.Id;    
                        }
                        update sales;    
                    }*/
                    /*Opportunity[] opps = [select Id 
                                        from Opportunity 
                                        WHERE Target__c = null AND 
                                        ((RecordTypeId='0121t000000LucvAAC' AND OwnerId=:target.User__c ) or /*internal*/
                                        /*(RecordTypeId='0121t000000IQUbAAO' AND Owner_s_Manager__c=:target.User__c)) /*partners*/
                                            /*AND CALENDAR_MONTH(CloseDate) = :target.Target_Date__c.month()
                                            AND CALENDAR_YEAR(CloseDate) = :target.Target_Date__c.year()];*/
                    
                    /*if(opps.size() > 0){
                        for(Opportunity opp : opps){
                            opp.Target__c = target.Id;    
                        }
                        update opps;    
                    }*/
                /*}else{//Partners
                    Opportunity[] CPOpps = [select Id 
                                        from Opportunity 
                                        WHERE CP_Target__c = null AND 
                                        RecordTypeId='0121t000000IQUbAAO' AND  /*partners*/
                                        /*Owner.Contact.AccountId=:target.Partner_Company__c AND
                                        CALENDAR_MONTH(CloseDate) = :target.Target_Date__c.month() AND
                                        CALENDAR_YEAR(CloseDate) = :target.Target_Date__c.year()];
                    
                    if(CPOpps.size() > 0){
                        for(Opportunity opp : CPOpps){
                            opp.CP_Target__c = target.Id;    
                        }
                        update CPOpps;    
                    }
                }*/
                
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
    public static void TargetsService(List<Sale__c> newSales, map <Id, Sale__c> oldSales){
        for(Sale__c sale : newSales){
            if(sale.Id!=null){
                if(oldSales.get(sale.Id) == null || oldSales.get(sale.Id).Close_Date__c != sale.Close_Date__c || oldSales.get(sale.Id).Owner__c != sale.Owner__c|| oldSales.get(sale.Id).Owner_s_Manager__c != sale.Owner_s_Manager__c){
                    system.debug('Raz Ben Ron TarSer sale: '+sale.id);
                    TargetsService.updateSaleTarget(sale);
                }
            }
        }
        
    }
    public static void updateSaleTarget(Sale__c sale){
        try{
            if(sale == null) return;
            list<Target__c> targets=new list<Target__c>();
            if(sale.Close_Date__c == null || sale.Owner__c == null){
                sale.Target__c = null;
                return;
            }
            string query='select Id from Target__c where ';
            //partners 
            if(sale.RecordTypeId=='0121t000000IQYTAA4'&&sale.Owner_s_Manager__c!=null){ 
                query+=' User__c=\''+sale.Owner_s_Manager__c+'\'';
            //internal
            }else{
                query+=' User__c=\''+sale.Owner__c+'\'';
            }
            query+=' AND CALENDAR_MONTH(Target_Date__c)='+sale.Close_Date__c.month();
            query+=' AND CALENDAR_YEAR(Target_Date__c)='+sale.Close_Date__c.year();
            targets=Database.query(query);

            if(targets.size() > 0){
                sale.Target__c = targets[0].Id;
            }else{
                sale.Target__c = null;
            }
            
        }catch(Exception e){
            Utilities.sendDebugEmail('Error in updateSaleTarget ',e,e.getMessage());   
        }
    }
    public static void TargetsServiceOnOpps(List<Opportunity> newOpps, map <Id, Opportunity> oldOpps){
        for(Opportunity opp : newOpps){
            if(opp.Id!=null){
                if(oldOpps.get(opp.Id) == null || oldOpps.get(opp.Id).CloseDate != opp.CloseDate || oldOpps.get(opp.Id).OwnerId != opp.OwnerId||oldOpps.get(opp.Id).Owner_s_Manager__c != opp.Owner_s_Manager__c){
                    system.debug('Raz Ben Ron TarSer opp: '+opp.id);
                    TargetsService.updateOppTarget(opp);
                }
            }
        }
        
    }
    public static void updateOppTarget(Opportunity opp){
        try{
            if(opp == null) return;
            list<Target__c> targets=new list<Target__c>();
            list<Target__c> CPtargets=new list<Target__c>();
            if(opp.CloseDate == null || opp.OwnerId == null){
                opp.Target__c = null;
                opp.CP_Target__c = null;
                return;
            }

            string query='select Id from Target__c where ';
            //CPMs 
            if(opp.RecordTypeId=='0121t000000IQUbAAO'&&opp.Owner_s_Manager__c!=null){ 
                query+=' User__c=\''+opp.Owner_s_Manager__c+'\'';
            //internal
            }else{
                query+=' User__c=\''+opp.OwnerId+'\'';
            }
            query+=' AND CALENDAR_MONTH(Target_Date__c)='+opp.CloseDate.month();
            query+=' AND CALENDAR_YEAR(Target_Date__c)='+opp.CloseDate.year();
            targets=Database.query(query);

            if(targets.size() > 0){
                opp.Target__c = targets[0].Id;
            }else{
                opp.Target__c = null;
            }

            //partners
            system.debug('Raz Ben Ron TarSer opp.RecordTypeId: '+opp.RecordTypeId);
            if(opp.RecordTypeId=='0121t000000IQUbAAO'){//partners
                User pc= [select id,Contact.AccountId from User where id=:opp.OwnerId];
                if(pc.Contact.AccountId!=null){
                    string cpQuery='select Id from Target__c where ';
                    cpQuery+=' Partner_Company__c=\''+pc.Contact.AccountId+'\'';
                    cpQuery+=' AND CALENDAR_MONTH(Target_Date__c)='+opp.CloseDate.month();
                    cpQuery+=' AND CALENDAR_YEAR(Target_Date__c)='+opp.CloseDate.year();
                    CPtargets=Database.query(cpQuery);
                    system.debug('Raz Ben Ron TarSer CPtargets: '+CPtargets);
                    if(!CPtargets.isEmpty()){
                        opp.CP_Target__c=CPtargets[0].Id;
                    }else{
                        opp.CP_Target__c=null;
                    }
                }else{
                    opp.CP_Target__c=null;
                }
            }else if(opp.CP_Target__c!=null){
                opp.CP_Target__c=null;
            }

        }catch(Exception e){
            Utilities.sendDebugEmail('Error in updateOppTarget ',e,e.getMessage());   
        }
    }
}