public without sharing class CommissionCommitmentCollectionService {

    public void setMondayAcc(List<sObject> sobjectList, Map<Id,sObject> oldSobjectMap){
        List<sObject> relevantObjs = new List<sObject>();
        Set<String> bigBrainIds = new Set<String>();
        for(sObject obj: sobjectList){
            if(oldSobjectMap == null || obj.get('Pulse_Account_Id__c') != oldSobjectMap.get(String.valueOf(obj.get('Id'))).get('Pulse_Account_Id__c')){
                if(obj.get('Pulse_Account_Id__c') == null){
                    obj.put('Monday_Account__c',null);
                    continue;
                }
                relevantObjs.add(obj);
                bigBrainIds.add(String.valueOf(obj.get('Pulse_Account_Id__c'))); 
            }
        }
        if(relevantObjs.isEmpty()) return;
        Map<String,Id> accountsMap = getAccounts(bigBrainIds);
        for(sObject obj: relevantObjs){
            if(accountsMap.containsKey(String.valueOf(obj.get('Pulse_Account_Id__c')))){
                obj.put('Monday_Account__c',accountsMap.get(String.valueOf(obj.get('Pulse_Account_Id__c'))));
            }
        }
    }

    public void setOpportunity(List<sObject> sobjectList, Map<Id,sObject> oldSobjectMap){
        List<sObject> relevantObjs = new List<sObject>();
        Set<Id> pcIds = new Set<Id>();
        for(sObject obj: sobjectList){
            if(oldSobjectMap == null || obj.get('Partner_Commission__c') != oldSobjectMap.get(String.valueOf(obj.get('Id'))).get('Partner_Commission__c')){
                if(obj.get('Partner_Commission__c') == null){
                    obj.put('Opportunity__c',null);
                    continue;
                }
                relevantObjs.add(obj);
                pcIds.add(String.valueOf(obj.get('Partner_Commission__c'))); 
            }
        }
        if(relevantObjs.isEmpty()) return;
        Map<Id,Id> pcsMap = getOpps(pcIds);
        for(sObject obj: relevantObjs){
            if(pcsMap.containsKey(String.valueOf(obj.get('Partner_Commission__c')))){
                obj.put('Opportunity__c',pcsMap.get(String.valueOf(obj.get('Partner_Commission__c'))));
            }
        }
    }
    
    private Map<String,Id> getAccounts(Set<String> bigBrainIds){
        Map<String,Id> res = new Map<String,Id>();
        if(bigBrainIds.isEmpty()) return res;
        List<Account> accList = [select Id, primary_pulse_account_id__c from Account where primary_pulse_account_id__c IN: bigBrainIds order by CreatedDate ASC];
        for(Account acc: accList){
            res.put(acc.primary_pulse_account_id__c, acc.Id);
        }
        return res;
    }

    private Map<Id,Id> getOpps(Set<Id> pcIds){
        Map<Id,Id> res = new Map<Id,Id>();
        if(pcIds.isEmpty()) return res;
        List<Partner_Commission__c> pcList = [select Id, Opportunity__c from Partner_Commission__c where Id IN: pcIds];
        for(Partner_Commission__c pc: pcList){
            res.put(pc.Id, pc.Opportunity__c);
        }
        return res;
    }
}
