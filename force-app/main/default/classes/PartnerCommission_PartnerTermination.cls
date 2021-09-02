public class PartnerCommission_PartnerTermination {
    public static Boolean firstRun = true;
    private static final String CLASS_NAME_CONST = 'PartnerCommission_PartnerTermination';

    public void updatePcAfterPartnerTermination(List<Account> newAccList, Map<Id,Account> oldAccMap){
        Set<Id> partnerCompanyAccountIds = new Set<Id>();
        Id partnerCompanyAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        for(Account acc:newAccList){
            if(acc.RecordTypeId == partnerCompanyAccountId && acc.Partner_Company_Status__c == 'Terminated' && oldAccMap.get(acc.Id).Partner_Company_Status__c != acc.Partner_Company_Status__c){
                partnerCompanyAccountIds.add(acc.Id);
            }
        }
        if(partnerCompanyAccountIds.isEmpty()) return;
        firstRun = false;
        System.enqueueJob(new partnerCompanyTermination(partnerCompanyAccountIds));
    }

    private class partnerCompanyTermination implements System.Queueable {
        private Set<Id> partnerCompanyAccountIds;

        public partnerCompanyTermination(Set<Id> partnerCompanyAccountIds) {
            this.partnerCompanyAccountIds = partnerCompanyAccountIds;
        }

        public void execute(System.QueueableContext ctx) {
            PartnerCommissionService pcService = new PartnerCommissionService();
            try {
                List<Partner_Commission__c> pcList = [select Id, End_Date__c from Partner_Commission__c where Partner_Company__c IN: partnerCompanyAccountIds and is_Last__c = true and Renewable__c = true];
                if(!pcList.isEmpty()){
                    for(Partner_Commission__c pc: pcList){
                        pc.Renewable__c = false;
                        if(pc.End_Date__c == null || pc.End_Date__c > Datetime.now()) {
                            pc.End_Date__c = Datetime.now();
                            pc.Close_Reason__c = 'Partners Termination';
                        }
                    }
                    pcService.upsertPartnerCommissionInQueue(pcList, CLASS_NAME_CONST);
                }
                List<Partner_Commission_Model__c> pcmList = [select Id from Partner_Commission_Model__c where Partner_Company__c IN: partnerCompanyAccountIds and (End_Date__c = null or End_Date__c >: Datetime.now())];
                if(!pcmList.isEmpty()){
                    for(Partner_Commission_Model__c pcm: pcmList){
                        pcm.End_Date__c = Datetime.now();
                    }
                    Database.update(pcmList);
                }
            } catch (Exception ex){
                pcService.sendErrorEmail(CLASS_NAME_CONST, ex.getMessage());
                throw ex;
            }
        }
    }
}