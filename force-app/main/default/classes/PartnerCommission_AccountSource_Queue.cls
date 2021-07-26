public without sharing class PartnerCommission_AccountSource_Queue implements System.Queueable {
    private Map<Id,String> mondayAccSourceTypeMap;

    public PartnerCommission_AccountSource_Queue(Map<Id,String> mondayAccSourceTypeMap) {
        this.mondayAccSourceTypeMap = mondayAccSourceTypeMap;
    }

    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> pcList = [select Id, Monday_Account__c, Partner_Commission_Model__r.Commission_Model__r.Inbound_Percent__c, Partner_Commission_Model__r.Commission_Model__r.Outbound_Percent__c from Partner_Commission__c where Monday_Account__c IN: mondayAccSourceTypeMap.keySet()];
        if(pcList.isEmpty()) return;

        for(Partner_Commission__c pc: pcList){
            if(mondayAccSourceTypeMap.containsKey(pc.Monday_Account__c)){
                if(mondayAccSourceTypeMap.get(pc.Monday_Account__c) == 'Inbound'){
                    pc.Percentage__c = pc.Partner_Commission_Model__r.Commission_Model__r.Inbound_Percent__c;
                    pc.Account_Source__c = 'Inbound';
                } else if(mondayAccSourceTypeMap.get(pc.Monday_Account__c) == 'Outbound'){
                    pc.Percentage__c = pc.Partner_Commission_Model__r.Commission_Model__r.Outbound_Percent__c;
                    pc.Account_Source__c = 'Outbound';
                }
            }
        }

        Database.update(pcList);
    }
}
