public without sharing class Lead_Cap_CalcOpenLeads implements Database.Batchable<Id>, Database.Stateful{
    public list<string> closedLeadsStatuses=new list<string>{'Qualified','Unqualified','Nurturing'};
    public list<string> partnerLeadsChannels=new list<string>{'Signup','Contact Sales'};
    public list<string> excludedLeadsChannels=new list<string>{'Outbound'};
    public list<string> excludedLeadsSubSources=new list<string>{'Manual Sync'};
    public list<string> excludedDistReasons=new list<string>{'Duplicate'};
    public Integer updatedLCs=0;

    private String ownerField;
    private Id recordTypeId;
    private map<Id,Leads_Cap__c> lcById;

    public Lead_Cap_CalcOpenLeads(String field, Id rt, map<Id,Leads_Cap__c> lcbyid){
        this.ownerField=field;
        this.recordTypeId=rt;
        this.lcById=lcbyid; 
    }

    public Iterable<Id> start(Database.BatchableContext bc){
        return new List<Id>(lcById.keyset());
    }

    public void execute(Database.BatchableContext bc, List<Id> scope) {
        system.debug('LCCOL Raz Ben Ron scope: '+scope);
        system.debug('LCCOL Raz Ben Ron lcById: '+lcById);
        list<Leads_Cap__c> lcToUpdate= new list<Leads_Cap__c>();
        lcToUpdate.addAll(getLCsToUpdate(ownerField,recordTypeId,scope));
        if(!lcToUpdate.isEmpty()){
            updatedLCs+=lcToUpdate.size();
            update lcToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        system.debug('LCCOL Raz Ben Ron Finished updatedLCs: '+updatedLCs);
        Utilities.sendEmail('Finished Lead_Cap_CalcOpenLeads Run','# of lead caps updated: '+updatedLCs,new list<String>{'razbe@monday.com'});   
    }

    public list<Leads_Cap__c> getLCsToUpdate(String key, Id recordTypeId, List<Id> idsScope){
        map<Id,Leads_Cap__c> updateList= new map<Id,Leads_Cap__c>();
        List<Id> ownersList =  idsScope;

        string queryString='select '+key+' , COUNT(Id) leadCount from Lead where status NOT IN: closedLeadsStatuses and Channel_Lead_Source__c NOT IN: excludedLeadsChannels and Sub_source__c NOT IN: excludedLeadsSubSources and Distribution_reason__c NOT IN: excludedDistReasons and';
        queryString+='(RecordType.DeveloperName != \'Partner_Lead\' or Channel_Lead_Source__c IN: partnerLeadsChannels) and '; //for partners leads (by RT) the channel must be Contact Sales or Signup
        queryString+='recordTypeId =\''+recordTypeId +'\' and ';
        queryString+='(OwnerId in: ownersList or Partner_Company__c in: ownersList) ';
        queryString+='group by '+key;
        list<AggregateResult>  ars=Database.Query(queryString);

        map<id,AggregateResult> resultByOwnerId= new map<id,AggregateResult>();
        if(!ars.isempty()){
            for(AggregateResult ar: ars){
                resultByOwnerId.put((id)ar.get(key),ar);
            }
        }
        for(Id ownerId: ownersList){
            if(lcById.containsKey(ownerId)){
                Leads_Cap__c lc=lcById.get(ownerId);
                if(resultByOwnerId.containsKey(ownerId)){//owner has open leads
                    AggregateResult ar=resultByOwnerId.get(ownerId);
                    system.debug('LCCOL Raz Ben Ron resultByOwnerId.get(ownerId): '+resultByOwnerId.get(ownerId));
                    if(lc.Open_Leads_Actual__c==null||lc.Open_Leads_Actual__c!=(decimal)ar.get('leadCount')){
                        lc.Open_Leads_Actual__c=(decimal)ar.get('leadCount');
                        lc.Actual_Open_Leads_Last_Update__c=datetime.now();
                        updateList.put(lc.id,lc);
                    }
                    
                }else{//owner has 0 open leads
                    if(lc.Open_Leads_Actual__c==null||lc.Open_Leads_Actual__c!=0){
                        lc.Open_Leads_Actual__c=0;
                        lc.Actual_Open_Leads_Last_Update__c=datetime.now();
                        updateList.put(lc.id,lc);
                    }
                }
                boolean isAvailable= lc.Open_Leads_Actual__c<lc.Open_Leads_Limit__c?true:false;
                if(lc.Available_for_Distribution__c!=isAvailable){
                    lc.Available_for_Distribution__c=isAvailable;
                    updateList.put(lc.id,lc);
                }
            }
        }
        return updateList.values();
        
    }
}