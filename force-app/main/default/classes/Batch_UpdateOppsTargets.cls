public class Batch_UpdateOppsTargets implements Database.Batchable<sObject>{
    
    public static Boolean firstRun = true;
    private Set<Id> oppIds;
    private Map<String,Id> targetsMap;
    
    public Batch_UpdateOppsTargets(Set<Id> oppIds, Map<String,Id> targetsMap) {
        this.oppIds = oppIds;
        this.targetsMap = targetsMap;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select Id, OwnerId, RecordTypeId, Owner_s_Manager__c, CloseDate, Owner.Contact.AccountId, CP_Target__c from Opportunity where Id IN: oppIds';
        return Database.getQueryLocator(query);
     }

    public void execute(Database.BatchableContext BC, list<Opportunity> scope){
        TargetsService helper = new TargetsService();
        Id oppPartnerCompanyRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Partner_Opportunity').getRecordTypeId();
        Map<Id,Opportunity> oppsToUpdate = new Map<Id,Opportunity>();
        String key = '';
        for(Opportunity opp: scope){
            //target
            if(opp.RecordTypeId == oppPartnerCompanyRtId && opp.Owner_s_Manager__c != null){
                key = helper.getUniqueueKey(opp.Owner_s_Manager__c, opp.CloseDate);
            } else {
                key = helper.getUniqueueKey(opp.OwnerId, opp.CloseDate);
            }
            if(targetsMap.containsKey(key)){
                oppsToUpdate.put(opp.Id, new Opportunity(Id = opp.Id, Target__c = targetsMap.get(key)));
            }
            //cp target
            if(opp.RecordTypeId == oppPartnerCompanyRtId){
                key = helper.getUniqueueKey(opp.Owner.Contact.AccountId, opp.CloseDate);
                if(targetsMap.containsKey(key)){
                    opp.CP_Target__c = targetsMap.get(key);
                    if(oppsToUpdate.containsKey(opp.Id)){
                        oppsToUpdate.get(opp.Id).CP_Target__c = targetsMap.get(key);
                    } else {
                        oppsToUpdate.put(opp.Id, new Opportunity(Id = opp.Id, CP_Target__c = targetsMap.get(key)));
                    }
                }
            }
        }
        if(!oppsToUpdate.isEmpty()){
            Database.update(oppsToUpdate.values());    
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}