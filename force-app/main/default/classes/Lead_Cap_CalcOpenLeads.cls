public without sharing class Lead_Cap_CalcOpenLeads implements Database.Batchable<Id>, Database.Stateful, Schedulable{
    public static Id internalRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Internal_Lead').getRecordTypeId();
    public static Id partnerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();
    public map<Id,Leads_Cap__c> lcByOwner= new  map<Id,Leads_Cap__c>();
    public list<string> closedLeadsStatuses=new list<string>{'Qualified','Unqualified','Nurturing'};
    public Integer updatedLCs=0;
    public Lead_Cap_CalcOpenLeads() {}
    
    public void execute(SchedulableContext sc) {
        Utilities.cleanFlexQueue();
        Database.executeBatch(this,20);
    }

    public Iterable<Id> start(Database.BatchableContext bc){
        for(Leads_Cap__c lc: [select id,User__c,Channel_Partner__c,Open_Leads_Actual__c,Open_Leads_Limit__c,Available_for_Distribution__c
                                from Leads_Cap__c 
                                where (User__c != null and User__r.IsActive=true and User__r.should_get_leads_from_BigBrain__c=true) or 
                                    (Channel_Partner__c != null and (Channel_Partner__r.Partner_Company_Status__c='Signed' or Channel_Partner__r.Partner_Signed_Timestamp__c!=null ))]){
            if(lc.User__c!=null){
                lcByOwner.put(lc.User__c,lc);
            }else if(lc.Channel_Partner__c!=null){
                lcByOwner.put(lc.Channel_Partner__c,lc);
            }
        } 
        system.debug('LCCOL Raz Ben Ron lcByOwner in start: '+lcByOwner);
        return new List<Id>(lcByOwner.keyset()); 
    }

    public void execute(Database.BatchableContext bc, List<Id> scope) {
        system.debug('LCCOL Raz Ben Ron scope: '+scope);
        list<Leads_Cap__c> lcToUpdate= new list<Leads_Cap__c>();
        lcToUpdate.addAll(getLCsToUpdate('ownerId',internalRecordTypeId,scope));
        lcToUpdate.addAll(getLCsToUpdate('Partner_Company__c',partnerRecordTypeId,scope));
        if(!lcToUpdate.isEmpty()){
            updatedLCs+=lcToUpdate.size();
            update lcToUpdate;
        }
        system.debug('LCCOL Raz Ben Ron total updatedLCs: '+updatedLCs+' lcToUpdate: '+lcToUpdate);
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('LCCOL Raz Ben Ron Finished updatedLCs: '+updatedLCs);
        Utilities.sendEmail('Finished Lead_Cap_CalcOpenLeads Run','# of lead caps updated: '+updatedLCs,new list<String>{'razbe@monday.com'});   
    }

    public list<Leads_Cap__c> getLCsToUpdate(String key, Id recordTypeId, List<Id> idsScope){
        map<Id,Leads_Cap__c> updateList= new map<Id,Leads_Cap__c>();
        //List<Id> ownersList=  new List<Id>(lcByOwner.keyset());
        List<Id> ownersList =  idsScope;

        string queryString='select '+key+' , COUNT(Id) leadCount from Lead where status NOT IN: closedLeadsStatuses and ';
        queryString+='recordTypeId =\''+recordTypeId +'\' and ';
        queryString+='(OwnerId in: ownersList or Partner_Company__c in: ownersList) ';
        queryString+='group by '+key;
        list<AggregateResult>  ars=Database.Query(queryString);
        
        system.debug('LCCOL Raz Ben Ron ownersList: '+ownersList);
        system.debug('LCCOL Raz Ben Ron queryString: '+queryString);
        system.debug('LCCOL Raz Ben Ron ars: '+ars);
        system.debug('LCCOL Raz Ben Ron lcByOwner in function: '+lcByOwner);

        if(!ars.isempty()){
            for(AggregateResult ar: ars){
                system.debug('LCCOL Raz Ben Ron ar: '+ar);
                if(lcByOwner.containsKey((id)ar.get(key))){
                    Leads_Cap__c lc=lcByOwner.get((id)ar.get(key));
                    if(lc.Open_Leads_Actual__c==null||lc.Open_Leads_Actual__c!=(decimal)ar.get('leadCount')){
                        lc.Open_Leads_Actual__c=(decimal)ar.get('leadCount');
                        lc.Actual_Open_Leads_Last_Update__c=datetime.now();
                        updateList.put(lc.id,lc);
                    }
                    boolean isAvailable= lc.Open_Leads_Actual__c<lc.Open_Leads_Limit__c?true:false;
                    if(lc.Available_for_Distribution__c!=isAvailable){
                        lc.Available_for_Distribution__c=isAvailable;
                        updateList.put(lc.id,lc);
                    }
                }
            }
        }
        return updateList.values();
    }
}