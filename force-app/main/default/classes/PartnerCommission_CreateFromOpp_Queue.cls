public class PartnerCommission_CreateFromOpp_Queue implements System.Queueable {
    private List<Opportunity> oppsList;  

    public PartnerCommission_CreateFromOpp_Queue(List<Opportunity> oppsList) {
        this.oppsList = oppsList;
    }
    
    public void execute(System.QueueableContext ctx) {
        List<Partner_Commission__c> newPartnerCommissionList = new List<Partner_Commission__c>();
        PartnerCommissionService pcService = new PartnerCommissionService();
        Map<Id, Account> accountsMap = getAccountsMap(oppsList);
        if(accountsMap.isEmpty()) return;
        for(Opportunity opp: oppsList){
            Partner_Commission__c newPartnerCommission = pcService.createPartnerCommissionRecord(accountsMap.get(opp.AccountId), accountsMap.get(opp.Channel_Partner__c), opp);
            newPartnerCommissionList.add(newPartnerCommission);
        }
        pcService.upsertPartnerCommissionInQueue(newPartnerCommissionList, 'PartnerCommission_CreateFromOpp_Queue');
    }

    private Map<Id, Account> getAccountsMap(List<Opportunity> oppsList){
        Set<Id> accountIds = new Set<Id>();
        Map<String, Schema.RecordTypeInfo> accountRecordTypesMap = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        Id partnerRecordTypeId = accountRecordTypesMap.get('Partner_Company').getRecordTypeId();
        Id mondayRecordTypeId = accountRecordTypesMap.get('Monday_Account').getRecordTypeId();

        for(Opportunity opp: oppsList){
            accountIds.add(opp.Channel_Partner__c);
            accountIds.add(opp.AccountId);
        }
        return new Map<Id, Account>([select Id, ARR__c, Name, Partner_Tier__c, Sign_Up_Date__c, Last_ARR_Update_Timestamp__c, Account_Source_Type__c, Partner_Type__c, primary_pulse_account_id__c, Partner_Commission_Model__c, Partner_Commission_Model__r.Commission_Model__r.Commission_Type__c, Partner_Commission_Model__r.Commission_Model__r.Period__c, Partner_Commission_Model__r.Commission_Model__r.Outbound_Percent__c, Partner_Commission_Model__r.Commission_Model__r.Inbound_Percent__c from Account where Id IN: accountIds and (RecordTypeId =: mondayRecordTypeId or (RecordTypeId =: partnerRecordTypeId and Partner_Commission_Model__c != null))]);
    }
}