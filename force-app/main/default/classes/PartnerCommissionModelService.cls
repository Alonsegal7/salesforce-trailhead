public class PartnerCommissionModelService {

    public class partnerCommissionException extends Exception {}

    public void updatePartnerAccount(List<Partner_Commission_Model__c> newPartnerCommissionModelList){
        List<Account> accountsToUpdate = new List<Account>();
        for(Partner_Commission_Model__c partnerCommissionModel: newPartnerCommissionModelList){
            accountsToUpdate.add(new Account(Id = partnerCommissionModel.Partner_Company__c, Partner_Commission_Model__c = partnerCommissionModel.Id));
        }
        if(!accountsToUpdate.isEmpty()) Database.update(accountsToUpdate);
    }

    public void checkIfExistingPcmDatesOverlap(List<Partner_Commission_Model__c> newPcmList, Map<Id,Partner_Commission_Model__c> oldPcmMap){
        Set<Id> partnerCompanyIds = new Set<Id>();
        for(Partner_Commission_Model__c pcm : newPcmList){
            if(oldPcmMap == null || pcm.Start_Date__c != oldPcmMap.get(pcm.Id).Start_Date__c || pcm.End_Date__c != oldPcmMap.get(pcm.Id).End_Date__c){
                partnerCompanyIds.add(pcm.Partner_Company__c);
            }
        }
        Map<Id,Account> partnerCompaniesMap = new Map<Id,Account>([select Id, (select Id, Start_Date__c, End_Date__c from Partner_Commission_Models__r) from Account where Id IN: partnerCompanyIds]);
        for(Partner_Commission_Model__c newPcm : newPcmList){
            for(Partner_Commission_Model__c existingPcm: partnerCompaniesMap.get(newPcm.Partner_Company__c).Partner_Commission_Models__r){
                if(oldPcmMap != null && oldPcmMap.containsKey(existingPcm.Id)) continue;
                if((newPcm.Start_Date__c >= existingPcm.Start_Date__c && (existingPcm.End_Date__c == null || newPcm.Start_Date__c <= existingPcm.End_Date__c)) 
                || (existingPcm.Start_Date__c >= newPcm.Start_Date__c && (newPcm.End_Date__c == null || existingPcm.Start_Date__c <= newPcm.End_Date__c))){
                    throw new partnerCommissionException('PCM dates overlap detected. PCM Id: '+newPcm.Id);
                }
            }
        }
    }
}