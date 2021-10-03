public without sharing class CommissionCommitmentCollectionService {

    public void setPartnerCommissionReport(List<sObject> sobjectList, Map<Id,sObject> oldSobjectMap){
        List<sObject> relevantObjs = new List<sObject>();
        Set<String> reportIds = new Set<String>();
        for(sObject obj: sobjectList){
            if(oldSobjectMap == null || obj.get('Report_Id__c') != oldSobjectMap.get(String.valueOf(obj.get('Id'))).get('Report_Id__c')){
                if(obj.get('Report_Id__c') == null){
                    obj.put('Commission_Report__c',null);
                    continue;
                }
                relevantObjs.add(obj);
                reportIds.add(String.valueOf(obj.get('Report_Id__c'))); 
            }
        }
        if(relevantObjs.isEmpty()) return;
        Map<String,Id> reportsMap = getReports(reportIds);
        for(sObject obj: relevantObjs){
            if(reportsMap.containsKey(String.valueOf(obj.get('Report_Id__c')))){
                obj.put('Commission_Report__c',reportsMap.get(String.valueOf(obj.get('Report_Id__c'))));
            }
        }
    }

    public void setPartnerCommissionCommitment(List<Commission_Collection__c> collectionList, Map<Id,Commission_Collection__c> oldCollectionMap){
        List<Commission_Collection__c> relevantCollections = new List<Commission_Collection__c>();
        Set<String> commitmentsIds = new Set<String>();
        for(Commission_Collection__c collection: collectionList){
            if(oldCollectionMap == null || collection.get('Commitment_Big_Brain_Id__c') != oldCollectionMap.get(String.valueOf(collection.get('Id'))).get('Commitment_Big_Brain_Id__c')){
                if(collection.get('Commitment_Big_Brain_Id__c') == null){
                    collection.put('Commission_Commitment__c',null);
                    continue;
                }
                relevantCollections.add(collection);
                commitmentsIds.add(String.valueOf(collection.get('Commitment_Big_Brain_Id__c'))); 
            }
        }
        if(relevantCollections.isEmpty()) return;
        Map<String,Id> commitmentsMap = getCommitments(commitmentsIds);
        for(Commission_Collection__c collection: relevantCollections){
            if(commitmentsMap.containsKey(String.valueOf(collection.get('Commitment_Big_Brain_Id__c')))){
                collection.put('Commission_Commitment__c',commitmentsMap.get(String.valueOf(collection.get('Commitment_Big_Brain_Id__c'))));
            }
        }
    }

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
        List<sObject> sobjPulseIdNotMatchAM = new List<sObject>();
        Set<String> pcsIds = new Set<String>();
        for(sObject obj: relevantObjs){
            if(accountsMap.containsKey(String.valueOf(obj.get('Pulse_Account_Id__c')))){
                obj.put('Monday_Account__c',accountsMap.get(String.valueOf(obj.get('Pulse_Account_Id__c'))));
            } else {
                sobjPulseIdNotMatchAM.add(obj);
                pcsIds.add(String.valueOf(obj.get('Partner_Commission__c')));
            }
        }
        if(!sobjPulseIdNotMatchAM.isEmpty()){
            Map<Id,Partner_Commission__c> pcsMap = new Map<Id,Partner_Commission__c>([select Id, Monday_Account__c from Partner_Commission__c where Id in: pcsIds]);
            for(sObject obj: sobjPulseIdNotMatchAM){
                if(pcsMap.containsKey(String.valueOf(obj.get('Partner_Commission__c')))){
                    obj.put('Monday_Account__c',pcsMap.get(String.valueOf(obj.get('Partner_Commission__c'))).Monday_Account__c);
                }
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

    private Map<String,Id> getReports(Set<String> reportIds){
        Map<String,Id> res = new Map<String,Id>();
        if(reportIds.isEmpty()) return res;
        List<Commission_Report__c> reportList = [select Id, Big_Brain_Id__c from Commission_Report__c where Big_Brain_Id__c IN: reportIds];
        for(Commission_Report__c report: reportList){
            res.put(report.Big_Brain_Id__c, report.Id);
        }
        return res;
    }

    private Map<String,Id> getCommitments(Set<String> commitmentsIds){
        Map<String,Id> res = new Map<String,Id>();
        if(commitmentsIds.isEmpty()) return res;
        List<Commission_Commitment__c> commitmentList = [select Id, Big_Brain_Id__c from Commission_Commitment__c where Big_Brain_Id__c IN: commitmentsIds];
        for(Commission_Commitment__c commitment: commitmentList){
            res.put(commitment.Big_Brain_Id__c, commitment.Id);
        }
        return res;
    }
}