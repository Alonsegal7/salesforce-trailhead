public without sharing class Batch_UpdateHiddenCommitments implements Database.Batchable<sObject>{
    List<Commission_Report__c> reportsList;
    
    public Batch_UpdateHiddenCommitments(List<Commission_Report__c> reportsList){
        this.reportsList = reportsList;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            Set<Id> reportIds = (new Map<Id,Commission_Report__c>(reportsList)).keySet();
            String query = 'select Id, Big_Brain_Id__c from Commission_Report__c where Id in: reportIds';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            Utilities.sendEmail('Error in Batch_UpdateHiddenCommitments start:',e.getMessage()+ ' ' + e.getStackTraceString(),new list<string>{'kseniasm@monday.com'});   
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, list<Commission_Report__c> scope){
        try{
            Map<String,Id> reportNumberToReportIdMap = new Map<String,Id>();
            for(Commission_Report__c report: scope){
                reportNumberToReportIdMap.put(report.Big_Brain_Id__c, report.Id);
            }
            List<Commission_Commitment__c> commitments = [select Id, External_Source_ID__c, Commission_Report__r.Id, Monday_Account__c, Report_Id__c, Commitment_Happened_At__c, Total_Commission_USD__c, is_Fix__c from Commission_Commitment__c where report_id__c IN: reportNumberToReportIdMap.keySet()];
            if(commitments.isEmpty()) return;

            Set<Id> commitmentsToSetHidden = new Set<Id>();
            Map<Id,Commission_Commitment__c> commitmentsMap = new Map<Id,Commission_Commitment__c>(commitments);
            Map<String,Commission_Commitment__c> fixCommitmentsMap = new Map<String,Commission_Commitment__c>();
            for(Commission_Commitment__c commitment: commitmentsMap.values()){
                String key = getCommitmentUniqueKey(commitment);
                if(fixCommitmentsMap.containsKey(key)){
                    Commission_Commitment__c existingCommitment = fixCommitmentsMap.get(key);
                    if(existingCommitment.Total_Commission_USD__c + commitment.Total_Commission_USD__c == 0 && existingCommitment.is_Fix__c != commitment.is_Fix__c){
                        commitment.Is_Hidden__c = true;
                        fixCommitmentsMap.get(key).Is_Hidden__c = true;
                    }
                } else {
                    fixCommitmentsMap.put(key, commitment);
                } 
            }
            Database.update(commitmentsMap.values());
        }catch(Exception e){
            Utilities.sendEmail('Error in Batch_UpdateHiddenCommitments execute:',e.getMessage()+ ' ' + e.getStackTraceString(),new list<string>{'kseniasm@monday.com'});   
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }

    private static String getCommitmentUniqueKey(Commission_Commitment__c commitment){
        Decimal absoluteAmount = commitment.Total_Commission_USD__c; 
        if(absoluteAmount < 0) absoluteAmount = -absoluteAmount;
        return commitment.Commission_Report__r.Id + String.valueOf(commitment.Monday_Account__c) + String.valueOf(commitment.Commitment_Happened_At__c) + String.valueOf(absoluteAmount) + commitment.External_Source_ID__c;
    }
}