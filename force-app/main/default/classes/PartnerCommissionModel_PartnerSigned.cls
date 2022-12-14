public class PartnerCommissionModel_PartnerSigned {

    public static Boolean firstRun = true;

    public void updatePcmForSignedPartners(List<Account> newAccList, Map<Id,Account> oldAccMap){
        Map<Id,String> partnerCompanyAccounts = new Map<Id,String>();
        Id partnerCompanyAccountId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Company').getRecordTypeId();
        for(Account acc:newAccList){
            if(acc.Partner_Commission_Model__c == null && acc.RecordTypeId == partnerCompanyAccountId && acc.Partner_Company_Status__c == 'Signed' && oldAccMap.get(acc.Id).Partner_Company_Status__c != acc.Partner_Company_Status__c){
                partnerCompanyAccounts.put(acc.Id, acc.Name);
            }
        }
        if(partnerCompanyAccounts.isEmpty()) return;
        firstRun = false;
        System.enqueueJob(new createPcmForSignedPartners(partnerCompanyAccounts));
    }

    private class createPcmForSignedPartners implements System.Queueable {
        private Map<Id,String> partnerCompanyAccounts;

        public createPcmForSignedPartners(Map<Id,String> partnerCompanyAccounts) {
            this.partnerCompanyAccounts = partnerCompanyAccounts;
        }

        public void execute(System.QueueableContext ctx) {
            List<Commission_Model__c> silverComModelList = [select Id from Commission_Model__c where Partner_Tier__c = 'Silver' limit 1];
            if(silverComModelList.isEmpty()) return;
            Id silverComModel = silverComModelList.get(0).Id;
            List<Partner_Commission_Model__c> existingPcms = [select Id, Partner_Company__c from Partner_Commission_Model__c where Commission_Model__c =: silverComModel and Partner_Company__c IN:  partnerCompanyAccounts.keySet() and (End_Date__c = null or End_Date__c >: Datetime.now())];
            for(Partner_Commission_Model__c existingPcm: existingPcms){
                partnerCompanyAccounts.remove(existingPcm.Partner_Company__c);
            }
            if(partnerCompanyAccounts.isEmpty()) return;
            List<Partner_Commission_Model__c> newPcmList = new List<Partner_Commission_Model__c>();
            for(Id accId: partnerCompanyAccounts.keySet()){
                newPcmList.add(new Partner_Commission_Model__c(Name = partnerCompanyAccounts.get(accId) + ' - Silver', Partner_Company__c = accId, Commission_Model__c = silverComModel, Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), 1)));
            }
            if(!newPcmList.isEmpty()) Database.insert(newPcmList);
        }
    }
}